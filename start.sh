#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="claude-java"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REBUILD=false
START_CLAUDE=false
[[ "${1:-}" == "--rebuild" ]] && { REBUILD=true; shift; }
[[ "${1:-}" == "--start-claude" ]] && { START_CLAUDE=true; shift; }

if $REBUILD || ! podman image exists "$IMAGE_NAME"; then
    podman build -t "$IMAGE_NAME" "$SCRIPT_DIR"
fi

CMD="bash"
$START_CLAUDE && CMD="claude --dangerously-skip-permissions"

podman run -it --rm \
    --name claude-java \
    --cap-add=NET_ADMIN \
    --userns=keep-id \
    -v "${1:-$(pwd)}:/workspace:z" \
    -v "$HOME/.claude:/home/dev/.claude:z" \
    -v "$HOME/.claude.json:/home/dev/.claude.json:z" \
    "$IMAGE_NAME" $CMD
