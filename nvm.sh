#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive
export NVM_DIR="$HOME/.nvm"
NODE_VERSION="--lts"

prepare_system() {
    sudo apt-get update -y
    sudo apt-get upgrade -y
    sudo apt-get install -y curl wget build-essential libssl-dev python3-pip
}

setup_swap() {
    if [ ! -f /swapfile ]; then
        sudo fallocate -l 2G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    fi
}

install_nvm() {
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    cat <<EOF >> "$HOME/.bashrc"
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"
EOF
}

configure_node() {
    source "$NVM_DIR/nvm.sh"
    nvm install $NODE_VERSION
    nvm use $NODE_VERSION
    nvm alias default 'lts/*'
    
    npm install -g npm@latest
    npm install -g pm2 yarn
}

optimize_network() {
    sudo ufw allow ssh
    sudo ufw allow http
    sudo ufw allow https
    sudo ufw --force enable
}

cleanup() {
    sudo apt-get autoremove -y
    sudo apt-get clean
}

main() {
    prepare_system
    setup_swap
    install_nvm
    configure_node
    optimize_network
    cleanup
    
    echo "------------------------------------------"
    echo "Environment Setup Complete"
    echo "Node version: $(node -v)"
    echo "NPM version: $(npm -v)"
    echo "PM2 version: $(pm2 -v)"
    echo "------------------------------------------"
}

main "$@"
