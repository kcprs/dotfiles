/**
 * Provider-specific auto routers.
 *
 * Based on jev-router: https://github.com/earendil-works/pi/blob/main/packages/coding-agent/examples/extensions/jev-router.ts
 */
import type { ExtensionAPI, ExtensionContext, ModelRouteRequest, VirtualModelStateData } from "@earendil-works/pi-coding-agent";

const EDIT_TOOLS = new Set(["edit", "write"]);
const COMPLEXITY_QUESTION = {
	type: "choice",
	instructions: "How demanding is the software engineering work requested in the prompt?",
	criteria: {
		standard: "Routine features, fixes, reviews, or questions",
		complex: "Subtle design, cross-cutting changes, or hard debugging",
	},
} as const;

type RouterConfig = {
	provider: string;
	name: string;
	sol: string;
	terra: string;
	luna: string;
	classifier: {
		url: string;
		deployment: string;
		apiKeyEnv: string;
		auth: "api-key" | "bearer";
	};
};

type RouterState = { model: string };
type Request = ModelRouteRequest<RouterState>;

const ROUTERS: RouterConfig[] = [
	{
		provider: "fhgenie",
		name: "FhGenie Auto",
		sol: "gpt-6.1-sol",
		terra: "gpt-6.1-terra",
		luna: "gpt-6-luna",
		classifier: {
			url: "https://fhgenie-api-iis-general.openai.azure.com/providers/microsoft/v1/systemone",
			deployment: "ms-decision-1.1",
			apiKeyEnv: "FHGENIE_API_KEY",
			auth: "api-key",
		},
	},
	{
		provider: "ame-litellm",
		name: "AME LiteLLM Auto",
		sol: "gpt-6.2-sol",
		terra: "gpt-6.1-terra",
		luna: "gpt-6-luna",
		classifier: {
			// LiteLLM translates System One requests to its configured Decision-1.1 backend.
			url: "https://litellm.ame-services.iis.fhg.de/v1/systemone",
			deployment: "Decision-1.1",
			apiKeyEnv: "AME_LITELLM_API_KEY",
			auth: "bearer",
		},
	},
];

function chooseRoute(request: Request, ctx: ExtensionContext, config: RouterConfig, id: string, state?: RouterState) {
	const model = ctx.modelRegistry.find(config.provider, id);
	if (!model) throw new Error(`Model ${config.provider}/${id} is not in the Pi catalog`);
	return { model, thinkingLevel: request.thinkingLevel, state };
}

function promptText(request: Request): string {
	const content = request.messages.findLast((message) => message.role === "user")?.content ?? "";
	return (typeof content === "string" ? content : content.flatMap((block) =>
		block.type === "text" ? [block.text] : [],
	).join("\n")).slice(0, 16_000);
}

async function choosePlanner(request: Request, ctx: ExtensionContext, config: RouterConfig): Promise<string> {
	const previous = request.previous?.model;
	if (previous?.provider === config.provider && (previous.id === config.sol || previous.id === config.terra)) {
		return previous.id;
	}

	const prompt = promptText(request);
	const key = process.env[config.classifier.apiKeyEnv];
	if (!key || !prompt.trim()) return config.terra;

	// Both services accept the System One decision shape, but they use different API-key headers.
	// Keep this request bounded so routing failures quickly fall back to the standard planner.
	const headers = new Headers({ "Content-Type": "application/json" });
	if (config.classifier.auth === "api-key") headers.set("api-key", key);
	else headers.set("Authorization", `Bearer ${key}`);
	const timeout = AbortSignal.timeout(4_000);
	try {
		const response = await fetch(config.classifier.url, {
			method: "POST",
			redirect: "error",
			headers,
			signal: request.signal ? AbortSignal.any([request.signal, timeout]) : timeout,
			body: JSON.stringify({
				model: config.classifier.deployment,
				state: { prompt },
				questions: { complexity: COMPLEXITY_QUESTION },
			}),
		});
		if (!response.ok) throw new Error(`HTTP ${response.status}`);
		const result = await response.json();
		const answer = result?.answers?.complexity;
		if (answer?.type !== "choice" || (answer.choice !== "standard" && answer.choice !== "complex")) {
			throw new Error("Unexpected classifier response");
		}
		return answer.choice === "complex" ? config.sol : config.terra;
	} catch (error) {
		// A failed classifier should not block planning, but cancellation should.
		request.signal?.throwIfAborted();
		if (ctx.hasUI) {
			const detail = error instanceof Error ? `: ${error.message}` : "";
			ctx.ui.notify(`${config.name} classifier unavailable${detail}; using ${config.terra}.`, "warning");
		}
		return config.terra;
	}
}

function registerRouter(pi: ExtensionAPI, config: RouterConfig): void {
	pi.registerVirtualModel<RouterState>({
		provider: config.provider,
		id: "auto",
		name: config.name,
		thinkingLevels: ["low", "medium", "high", "xhigh"],
		// All candidate chat models share these limits before the first response.
		contextWindow: 922_000,
		maxTokens: 128_000,
		async route(request, ctx) {
			if (request.reason === "direct") return chooseRoute(request, ctx, config, config.luna);
			if (request.reason === "retry" && request.failed) {
				return { model: request.failed.model, thinkingLevel: request.failed.thinkingLevel ?? request.thinkingLevel };
			}
			const state = request.state;
			if (!state) {
				const model = await choosePlanner(request, ctx, config);
				return chooseRoute(request, ctx, config, model, { model });
			}

			// Scan the branch since planning began, rather than since the last user message:
			// steering can arrive after an edit, and compaction can remove it from the context.
			// TODO: Recognize edits made via shell commands or tools other than edit/write.
			const branch = ctx.sessionManager.getBranch();
			const stateIndex = branch.findLastIndex((entry) => {
				if (entry.type !== "custom" || entry.customType !== "pi.virtual-model-state") return false;
				const data = entry.data as VirtualModelStateData | undefined;
				return data?.provider === config.provider && data.modelId === "auto";
			});
			const edited = state.model !== config.luna && stateIndex !== -1 && branch.slice(stateIndex + 1).some((entry) =>
				entry.type === "message" && entry.message.role === "toolResult" &&
				EDIT_TOOLS.has(entry.message.toolName) && !entry.message.isError,
			);
			// Store the handoff on the branch, so later turns don't pay another cache miss.
			return edited
				? chooseRoute(request, ctx, config, config.luna, { model: config.luna })
				: chooseRoute(request, ctx, config, state.model);
		},
	});
}

export default function (pi: ExtensionAPI) {
	for (const config of ROUTERS) registerRouter(pi, config);
}
