FROM docker.io/library/maven:3.9-eclipse-temurin-25

ARG TZ
ENV TZ="$TZ"

# Install development tools and firewall utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    less \
    procps \
    sudo \
    gh \
    iptables \
    iproute2 \
    dnsutils \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV DEVCONTAINER=true

ARG USERNAME=dev

# Create non-root user
RUN userdel -r ubuntu && \
    useradd -m -s /bin/bash $USERNAME && \
    mkdir -p /workspace /home/$USERNAME/.claude /home/$USERNAME/.m2 && \
    chown -R $USERNAME:$USERNAME /workspace /home/$USERNAME/.claude /home/$USERNAME/.m2

WORKDIR /workspace

# Install Claude Code CLI as the non-root user
USER $USERNAME
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/dev/.local/bin:${PATH}"

# Bake managed settings into the image
USER root
RUN mkdir -p /etc/claude-code
COPY managed-settings.json /etc/claude-code/managed-settings.json

# Copy and set up firewall script and entrypoint
COPY init-firewall.sh /usr/local/bin/init-firewall.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/entrypoint.sh && \
    echo "$USERNAME ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" \
        > /etc/sudoers.d/$USERNAME-firewall && \
    chmod 0440 /etc/sudoers.d/$USERNAME-firewall

USER $USERNAME

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
