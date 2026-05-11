function oc --description 'Run opencode in a container for current workspace'
    set -gx OPENCODE_WORKSPACE_PATH (pwd)
    set -gx OPENCODE_WORKSPACE_NAME (basename "$OPENCODE_WORKSPACE_PATH")

    # Stop if AI not allowed
    if test "$AI_FEATURES_ENABLED" != "true"
        echo "Error: AI features are not enabled. Set AI_FEATURES_ENABLED=true to use opencode."
        return 1
    end

    # Need to know which Docker image to use
    if not set -q OPENCODE_DOCKER_IMAGE
        echo "Error: OPENCODE_DOCKER_IMAGE is not set. Set it to the name of a Docker image with opencode preinstalled to continue."
        return 1
    end

    # Need to know which Docker platform to use
    if not set -q OPENCODE_DOCKER_PLATFORM
        echo "Error: OPENCODE_DOCKER_PLATFORM is not set. Set it to use opencode."
        return 1
    end

    # The core compose file
    set compose_args -f ~/.config/opencode-docker/compose.yaml

    # If in a worktree, also mount the main repo for full git functionality
    set git_dir (git -C "$OPENCODE_WORKSPACE_PATH" rev-parse --path-format=absolute --git-dir 2>/dev/null)
    set git_common_dir (git -C "$OPENCODE_WORKSPACE_PATH" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)
    if test -n "$git_dir"; and test -n "$git_common_dir"; and test "$git_dir" != "$git_common_dir"
        set -gx OPENCODE_MAIN_REPO_PATH (path dirname "$git_common_dir")
        set -gx OPENCODE_MAIN_REPO_NAME (basename "$OPENCODE_MAIN_REPO_PATH")
        set compose_args $compose_args -f ~/.config/opencode-docker/compose.worktree.yaml
    end

    # Run the container
    podman compose $compose_args run --rm opencode
end
