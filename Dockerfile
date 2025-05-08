# Use a lightweight Ubuntu base image
FROM ubuntu:latest
SHELL ["/bin/bash", "-c"]
RUN ln -sf /bin/bash /bin/sh
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
    ca-certificates \
    jq \
    git \
    sudo && \
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
    rm -rf awscliv2.zip ./aws

# Install doctl
RUN curl -LO "https://github.com/digitalocean/doctl/releases/download/v1.104.0/doctl-1.104.0-linux-amd64.tar.gz" && \
    tar xzf doctl-1.104.0-linux-amd64.tar.gz && \
    mv doctl /usr/local/bin && \
    rm doctl-1.104.0-linux-amd64.tar.gz

# Install Argo CD CLI
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    chmod +x argocd-linux-amd64 && mv argocd-linux-amd64 /usr/local/bin/argocd

# Install Argo CLI
RUN curl -sSL -o argo https://github.com/argoproj/argo-workflows/releases/latest/download/argo-linux-amd64 && \
    chmod +x argo && mv argo /usr/local/bin/argo

# Install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod +x /usr/local/bin/yq

# Install GitHub Actions Runner
ENV RUNNER_VERSION=2.323.0
RUN curl -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    -o actions-runner.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz

# Add entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# No user switching to non-root user is needed; continue with root user
USER root

# Set the working directory
WORKDIR /home/runner

# Set the entrypoint to the script
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

# Ensure the runner's home directory exists
RUN mkdir -p /home/runner

# Default command
CMD ["/bin/bash"]
