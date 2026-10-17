# pi in a container: the pi-box sandbox. Built by llm/pi/install.sh as
# pi-box:<version>. Only the current project directory is mounted at run time.
FROM node:24-bookworm-slim

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       bash ca-certificates git ripgrep fd-find less jq make python3 \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && rm -rf /var/lib/apt/lists/*

ARG PI_VERSION
RUN npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@${PI_VERSION}"

# llama-server listens on the docker0 bridge address, which containers on the
# default bridge network reach directly.
ENV LLAMA_BASE_URL=http://172.17.0.1:8012 \
    PI_SKIP_VERSION_CHECK=1 \
    PI_TELEMETRY=0 \
    PI_CODING_AGENT_DIR=/pi/agent \
    HOME=/pi/home

ENTRYPOINT ["pi"]
