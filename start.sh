#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="claude-java"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REBUILD=false
[[ "${1:-}" == "--rebuild" ]] && { REBUILD=true; shift; }

if $REBUILD || ! podman image exists "$IMAGE_NAME"; then
    podman build -t "$IMAGE_NAME" "$SCRIPT_DIR"
fi

GH_TOKEN=$(gh auth token 2>/dev/null || true)

podman run -it --rm \
    --name "claude-java-$$" \
    --cap-add=NET_ADMIN \
    --userns=keep-id \
    -v "${1:-$(pwd)}:/workspace:z" \
    -v "$HOME/.claude:/home/dev/.claude:z" \
    -v "$HOME/.claude.json:/home/dev/.claude.json:z" \
    -v "$HOME/.gitconfig:/home/dev/.gitconfig:ro,z" \
    -v "$HOME/.ssh:/home/dev/.ssh:ro,z" \
    ${GH_TOKEN:+-e GH_TOKEN="$GH_TOKEN"} \
    "$IMAGE_NAME"
