# Use Jenkins base image for amd64 architecture
FROM --platform=linux/amd64 jenkins/jenkins:latest-jdk21

# Switch to root user
USER root

# Update package lists, install necessary tools, and the lsb-release utility, gettext-base (For Env substitution)
RUN apt-get update && \
    apt-get install -y sudo vim curl wget lsb-release gnupg software-properties-common gettext-base && \
    rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://get.docker.com | sh

# Install Docker Compose
RUN DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")') && \
    curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

#Install Mozilla SOPS
RUN LATEST_VERSION=$(curl -sL https://api.github.com/repos/mozilla/sops/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') && \
    curl -L https://github.com/mozilla/sops/releases/download/v${LATEST_VERSION}/sops-v${LATEST_VERSION}.linux.amd64 -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins user to sudoers
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add Jenkins user to Docker group
RUN usermod -aG docker jenkins

# Switch back to the Jenkins user
USER jenkins
