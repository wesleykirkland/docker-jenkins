# Use Jenkins base image for amd64 architecture
FROM --platform=linux/amd64 jenkins/jenkins:latest

# Switch to root user
USER root

# Update package lists, install necessary tools, and the lsb-release utility
RUN apt-get update && \
    apt-get install -y sudo vim curl wget lsb-release gnupg software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Set root password
# RUN echo 'root:abc123' | chpasswd

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# Add Jenkins user to sudoers
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Docker CLI
RUN curl -fsSL https://get.docker.com | sh

# Add Jenkins user to Docker
RUN usermod -aG docker jenkins

# Switch back to the Jenkins user
USER jenkins