# Local LLM stack

Runs language models locally on the TUXEDO InfinityBook Pro (Ryzen AI 9 HX 370,
124 GiB RAM, Radeon 890M) with [Odysseus](https://github.com/odysseus-dev/odysseus)
as the web UI.

```
browser ── http://localhost:7000 ── Odysseus (Docker)
                                        │  discovers host.docker.internal:8000-8020
                                        ▼
                       llama-server 172.17.0.1:8012 (systemd --user, Vulkan)
                                        │
                                   ~/.cache/llama.cpp/*.gguf
```

Odysseus does not serve the models itself. Its built-in Cookbook serving and
the AMD Docker overlay are ROCm-oriented and a poor fit for the iGPU, so the
models run on the host with llama.cpp's Vulkan backend instead.

llama-server binds to the docker0 bridge address (172.17.0.1) rather than
loopback, because that is what `host.docker.internal` resolves to inside the
container. The bridge is not reachable from the LAN, so no API key is needed.

## Install

```sh
sudo pacman -S --needed llama-cpp ggml-vulkan   # also in arch/packages
./install.sh
```

The first start of `llama-server.service` downloads the default model
(Qwen3-30B-A3B, about 18 GB) into `~/.cache/llama.cpp`.

Then register llama-server in Odysseus once (it lives in Odysseus' own
database, not in this repo): log in as admin, Settings -> Models -> add a
LOCAL endpoint with URL `http://host.docker.internal:8012/v1`. Or from a shell:

```sh
curl -s -c cj -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"..."}' localhost:7000/api/auth/login
curl -s -b cj -X POST localhost:7000/api/model-endpoints \
  -F name=llama-server -F base_url=http://host.docker.internal:8012/v1
# enable native tool calling for the id returned above (no UI toggle yet)
curl -s -b cj -X PATCH localhost:7000/api/model-endpoints/<id> \
  -H 'Content-Type: application/json' -d '{"supports_tools": true}'
rm cj
```

`GET /api/discover` shows what Odysseus can see on the host if the endpoint
does not show up.

## Files

| File | Installed as | Purpose |
|---|---|---|
| `llama-server.service` | `~/.config/systemd/user/llama-server.service` | llama-server in router mode on the docker0 address, port 8012 |
| `models.ini` | `~/.config/llm/models.ini` | Model presets and global options (GPU layers, context) |
| `odysseus/env` | `~/.local/share/odysseus/.env` | Odysseus configuration |
| `odysseus/docker-compose.override.yml` | `~/.local/share/odysseus/docker-compose.override.yml` | Use the prebuilt image |

## Models

`llama-server` runs in router mode: every GGUF in `~/.cache/llama.cpp` and every
preset in `models.ini` is listed on `/v1/models` and loaded on first request.
Only one model is kept loaded at a time (`--models-max 1`).

Add a model with any of:

```sh
# Download now, listed after the next restart of llama-server
llama-server -hf unsloth/Qwen3-8B-GGUF:Q4_K_M --port 0   # Ctrl-C once "server is listening"
# Or add a [section] with hf-repo = ... to models.ini
```

Measured on this laptop with Qwen3-30B-A3B Q4_K_M on Vulkan: about 33 tok/s
generation, 73 tok/s prompt processing, 19 GiB of GPU (GTT) memory.

Rules of thumb for this laptop: speed is memory bandwidth divided by model
size. Mixture-of-experts models (Qwen3-30B-A3B, gpt-oss) are fast. Dense
models above ~14B are slow. Anything over ~110 GB on disk does not fit.

## Day to day

```sh
systemctl --user status llama-server
journalctl --user -fu llama-server
curl -s 172.17.0.1:8012/v1/models | jq '.data[].id'

cd ~/.local/share/odysseus
docker compose logs -f odysseus
docker compose pull && docker compose up -d      # update Odysseus
git pull                                         # update compose files
```

Odysseus login: user `admin`, the password is printed in the container log on
first boot (`docker compose logs odysseus | grep -i password`). Keep
`AUTH_ENABLED=true` and the loopback bind unless you deliberately expose it.
