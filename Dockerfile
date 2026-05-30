# syntax=docker/dockerfile:1

# extend the remotely published base controller image from GHCR.
ARG CONTROLLER_BASE_IMAGE=ghcr.io/burava-public/1stline-ai-escalation-controller:latest
FROM ${CONTROLLER_BASE_IMAGE}

USER root

# Example tooling only. Replace with your required tools and pinned versions.
RUN apt-get update \
	&& apt-get install -y --no-install-recommends ca-certificates curl wget unzip jq ripgrep python3 python3-venv python3-pip \
	&& rm -rf /var/lib/apt/lists/*

# Install OpenCode
RUN npm install -g opencode-ai \
	&& npm rebuild -g opencode-ai

# Install Context7 and GitHub MCP servers
RUN npm install -g @upstash/context7-mcp@latest @modelcontextprotocol/server-github@latest

# Install UV to run MCP servers such as grafana mcp server
RUN curl -LsSf https://astral.sh/uv/0.11.17/install.sh | sh \
	&& install -m 0755 /home/node/.local/bin/uv /usr/local/bin/uv \
	&& install -m 0755 /home/node/.local/bin/uvx /usr/local/bin/uvx

# Install Grafana Loki's logcli for log querying in diagnostics SKILLs
RUN wget -O /tmp/logcli-linux-amd64.zip https://github.com/grafana/loki/releases/download/v3.7.2/logcli-linux-amd64.zip \
	&& unzip /tmp/logcli-linux-amd64.zip -d /tmp \
	&& install -m 0755 /tmp/logcli-linux-amd64 /usr/local/bin/logcli \
	&& rm -f /tmp/logcli-linux-amd64.zip /tmp/logcli-linux-amd64

# Install kubectl for Kubernetes diagnostics in SKILLs
RUN curl -fsSLo /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
	&& install -m 0755 /tmp/kubectl /usr/local/bin/kubectl \
	&& rm -f /tmp/kubectl

# Copy default context enrichments suggested by 1stLine
COPY example/opencode/agents /home/node/.config/opencode/agents
COPY example/opencode/skills /home/node/.config/opencode/skills
COPY example/opencode/agents /opencode/agents
COPY example/opencode/skills /opencode/skills

RUN chown -R node:node /home/node /opencode

USER node

RUN command -v firstline-ai-controller \
	&& command -v firstline-ai-controller-ready \
	&& command -v opencode
