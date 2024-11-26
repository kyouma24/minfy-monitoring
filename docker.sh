#!/bin/bash

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "Unable to detect OS."
    exit 1
fi

install_docker_ubuntu() {
    echo "Installing Docker on Ubuntu..."
    sudo apt-get update || { echo "Failed to update package list"; exit 1; }
    sudo apt-get install ca-certificates curl -y || { echo "Failed to install prerequisites"; exit 1; }
    sudo install -m 0755 -d /etc/apt/keyrings || { echo "Failed to create keyrings directory"; exit 1; }
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc || { echo "Failed to download Docker GPG key"; exit 1; }
    sudo chmod a+r /etc/apt/keyrings/docker.asc || { echo "Failed to set permissions on Docker GPG key"; exit 1; }
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null || { echo "Failed to add Docker repository"; exit 1; }
    sudo apt-get update || { echo "Failed to update package list after adding repository"; exit 1; }
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y || { echo "Failed to install Docker"; exit 1; }
}

install_docker_amazon_linux() {
    echo "Installing Docker on Amazon Linux..."
    sudo yum install docker -y || { echo "Failed to install Docker"; exit 1; }
    sudo service docker start || { echo "Failed to start Docker service"; exit 1; }
    sudo chkconfig docker on || { echo "Failed to configure Docker to start on boot"; exit 1; }
    
    echo "Installing Docker Compose on Amazon Linux..."
    sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose || { echo "Failed to download Docker Compose"; exit 1; }
    sudo chmod +x /usr/local/bin/docker-compose || { echo "Failed to set permissions on Docker Compose"; exit 1; }
    docker-compose --version || { echo "Docker Compose installation verification failed"; exit 1; }
}

# Check OS and install Docker
if [ "$OS" == "ubuntu" ]; then
    install_docker_ubuntu
elif [ "$OS" == "amzn" ]; then
    install_docker_amazon_linux
else
    echo "Unsupported OS"
    exit 1
fi

# Verify Docker installation
docker --version || { echo "Docker installation verification failed"; exit 1; }

echo "Docker and Docker Compose installation completed successfully."

sudo chmod 777 data/ 
sudo chmod 777 -r ./reportgen/reports ./reportgen/templates ./reportgen/templates/images ./reportgen/themes