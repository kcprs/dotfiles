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

    podman compose -f ~/.config/opencode-docker/compose.yaml run --rm opencode
end
