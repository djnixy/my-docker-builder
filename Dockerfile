# Use a lightweight Ubuntu base image
FROM ubuntu:latest

# Set noninteractive mode to avoid prompts during installation
ARG DEBIAN_FRONTEND=noninteractive

# Install essential tools and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    software-properties-common \
    wget \
    zip \
    unzip \
    apt-transport-https \
    ca-certificates && \ # Add ca-certificates
    rm -rf /var/lib/apt/lists/*

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends docker.io && \
    rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip && \
    rm -rf ./aws

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/kubectl

# Install doctl (DigitalOcean CLI)
RUN curl -LO "https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz" && \
    tar xzf doctl-1.104.0-linux-amd64.tar.gz && \
    mv doctl /usr/local/bin && \
    rm -rf doctl-1.104.0-linux-amd64.tar.gz

# Install Argo CD CLI
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x argocd-linux-amd64 && \
    mv argocd-linux-amd64 /usr/local/bin/argocd

# Install Argo CLI
RUN curl -sSL -o argo https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64 && \
    chmod +x argo && \
    mv argo /usr/local/bin/argo

# Install yq (YAML processor)
RUN wget -qO- https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install jq (JSON processor)
RUN apt-get update && apt-get install -y jq && rm -rf /var/lib/apt/lists/*

# Install git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Install NVM (Node Version Manager)
ENV NVM_DIR=/home/node/.nvm
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \
    . "$NVM_DIR/nvm.sh" && \
    nvm install --lts && \
    ln -s /home/node/.nvm/versions/node/v$(nvm --lts)/bin/node /usr/local/bin/node && \
    ln -s /home/node/.nvm/versions/node/v$(nvm --lts)/bin/npm /usr/local/bin/npm

# Add a non-root user for security best practices (IMPORTANT for Docker)
RUN adduser node --disabled-password --gecos ""
USER node
ENV HOME=/home/node
WORKDIR $HOME

# Switch back to root for any remaining installations
USER root
# Set the working directory
WORKDIR /github/workspace

# Define the entrypoint (optional, depending on your needs)
# ENTRYPOINT ["/usr/bin/env", "sh"]
