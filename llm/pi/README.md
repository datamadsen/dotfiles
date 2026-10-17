# pi

[pi](https://pi.dev) is a minimal terminal coding agent. Here it runs against
the local llama-server only: no cloud providers, no telemetry, no version
check.

```
pi      ── host, your user's permissions ──┐
pi-box  ── Docker, only $PWD mounted ──────┴── llama-server 172.17.0.1:8012
```

pi has no permission prompts: it runs whatever commands the model decides
on. Use `pi` for your own repos while you watch, and `pi-box` for anything
untrusted or unattended.

## Install

```sh
sudo pacman -S --needed nodejs npm ripgrep fd   # also in arch/packages
./install.sh                                    # or ../install.sh for the whole stack
```

The pinned version is in `version`. To update, change it and rerun
`install.sh` (don't use `pi update`; it would install outside ~/.local/lib/pi).

## Files

| File | Installed as | Purpose |
|---|---|---|
| `pi` | `~/.local/bin/pi` | Wrapper: sets `LLAMA_BASE_URL`, turns off telemetry and update checks, runs `~/.local/lib/pi/bin/pi` |
| `pi-box` | `~/.local/bin/pi-box` | Runs pi in the `pi-box:<version>` container with only the current directory mounted |
| `Dockerfile` | image `pi-box:<version>` | node + git, ripgrep, fd and pi |
| `settings.json` | `~/.pi/agent/settings.json` | Default model, telemetry off, compaction tuned for a 32k context |
| `AGENTS.md` | `~/.pi/agent/AGENTS.md` | Global instructions for every project |
| `version` | | Pinned pi version for both installs |

`settings.json` is a symlink, so changes made with `/settings` land in this
repo. In pi-box it is mounted read-only. Login credentials (`auth.json`) and
sessions stay in `~/.pi/agent` and are not tracked; pi-box keeps its own in
`~/.local/share/pi-box` and never sees the host's.

## Models

pi's built-in `llama.cpp` provider reads the router's model list, so every
preset in `models.<hostname>.ini` shows up in `/model`, and its context window
comes from the preset's `ctx-size`. Inside pi:

- `/model` switches model; `/llama` loads, unloads or downloads models.
- `/tree` branches or rewinds a session; `/settings` for preferences.

`qwen3-30b-a3b` is the default. Local models of this size are fine for
focused edits and shell work but lose track on long multi-file tasks; keep
tasks small.

## pi-box details

- Runs as your uid, `--cap-drop ALL`, `no-new-privileges`.
- Mounts `$PWD` at the same path, read-write. Refuses to run in `~` or `/`.
- `~/.gitconfig` is mounted read-only; no SSH keys or other credentials.
- Network: the default bridge, which reaches llama-server but also the
  internet. `PI_BOX_NETWORK=<name> pi-box` picks another Docker network.
