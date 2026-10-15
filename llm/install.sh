#!/usr/bin/env bash
#
# Local LLM stack: llama-server (llama.cpp + Vulkan) as a user service, and
# Odysseus as the web UI in Docker.
#
# Prerequisites (from arch/packages): llama-cpp ggml-vulkan docker docker-compose
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ODYSSEUS_DIR="$HOME/.local/share/odysseus"
ODYSSEUS_REPO="https://github.com/odysseus-dev/odysseus"

echo "[llm] llama-server"
if ! command -v llama-server >/dev/null; then
  echo "[llm]   llama-server not found. Install it first:"
  echo "[llm]     sudo pacman -S --needed llama-cpp ggml-vulkan"
  exit 1
fi
mkdir -p ~/.config/llm ~/.config/systemd/user ~/.cache/llama.cpp
ln -sf "$SCRIPT_DIR/models.ini" ~/.config/llm/models.ini
ln -sf "$SCRIPT_DIR/llama-server.service" ~/.config/systemd/user/llama-server.service
systemctl --user daemon-reload
systemctl --user enable --now llama-server.service
echo "[llm]   enabled llama-server.service (http://172.17.0.1:8012, needs Docker running)"
echo "[llm]   first start downloads the default model to ~/.cache/llama.cpp;"
echo "[llm]   follow it with: journalctl --user -fu llama-server"

echo "[llm] Odysseus"
if [[ ! -d "$ODYSSEUS_DIR/.git" ]]; then
  git clone --depth 1 --branch main "$ODYSSEUS_REPO" "$ODYSSEUS_DIR"
fi
ln -sf "$SCRIPT_DIR/odysseus/env" "$ODYSSEUS_DIR/.env"
ln -sf "$SCRIPT_DIR/odysseus/docker-compose.override.yml" "$ODYSSEUS_DIR/docker-compose.override.yml"
# Keep the symlinks out of the upstream checkout's git status.
grep -qx 'docker-compose.override.yml' "$ODYSSEUS_DIR/.git/info/exclude" 2>/dev/null \
  || printf '.env\ndocker-compose.override.yml\n' >> "$ODYSSEUS_DIR/.git/info/exclude"
docker compose --project-directory "$ODYSSEUS_DIR" pull odysseus
docker compose --project-directory "$ODYSSEUS_DIR" up -d
echo "[llm]   Odysseus is at http://localhost:7000"
echo "[llm]   first-boot admin password:"
echo "[llm]     docker compose --project-directory $ODYSSEUS_DIR logs odysseus | grep -i password"

echo "[llm] Done."
