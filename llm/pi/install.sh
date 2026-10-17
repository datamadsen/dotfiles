#!/usr/bin/env bash
#
# pi coding agent (https://pi.dev): host install in ~/.local and the pi-box
# Docker sandbox. Both use the local llama-server; see llm/pi/README.md.
#
# Prerequisites (from arch/packages): nodejs npm ripgrep fd docker docker-buildx
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_VERSION="$(cat "$SCRIPT_DIR/version")"
PI_PREFIX="$HOME/.local/lib/pi"
PI_PACKAGE="@earendil-works/pi-coding-agent"

echo "[pi] host install ($PI_PACKAGE@$PI_VERSION)"
if ! command -v npm >/dev/null; then
  echo "[pi]   npm not found. Install it first:"
  echo "[pi]     sudo pacman -S --needed nodejs npm"
  exit 1
fi
if ! node -e 'const [a,b]=process.versions.node.split(".").map(Number); process.exit(a>22||(a===22&&b>=19)?0:1)'; then
  echo "[pi]   pi needs Node.js 22.19 or newer (have $(node --version))."
  exit 1
fi
npm install --global --ignore-scripts --no-fund --no-audit \
  --prefix "$PI_PREFIX" "$PI_PACKAGE@$PI_VERSION"

mkdir -p ~/.local/bin ~/.pi/agent
ln -sf "$SCRIPT_DIR/pi" ~/.local/bin/pi
ln -sf "$SCRIPT_DIR/pi-box" ~/.local/bin/pi-box
# pi writes /settings changes through the symlink, i.e. into this repo.
for f in settings.json AGENTS.md; do
  if [[ -e ~/.pi/agent/$f && ! -L ~/.pi/agent/$f ]]; then
    mv ~/.pi/agent/$f ~/.pi/agent/$f.bak
    echo "[pi]   kept the existing ~/.pi/agent/$f as $f.bak"
  fi
  ln -sf "$SCRIPT_DIR/$f" ~/.pi/agent/$f
done
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) echo "[pi]   note: ~/.local/bin is not on PATH" ;;
esac
for tool in rg fd; do
  command -v $tool >/dev/null || echo "[pi]   note: $tool missing; pi downloads its own copy (sudo pacman -S ripgrep fd)"
done

echo "[pi] pi-box sandbox image"
if command -v docker >/dev/null && docker info >/dev/null 2>&1; then
  docker build --quiet --tag "pi-box:$PI_VERSION" \
    --build-arg PI_VERSION="$PI_VERSION" "$SCRIPT_DIR"
  mkdir -p ~/.local/share/pi-box/agent ~/.local/share/pi-box/home
else
  echo "[pi]   Docker is not running; skipped. Rerun this script once it is."
fi

echo "[pi] Done. Run 'pi' (host) or 'pi-box' (sandboxed) inside a project."
