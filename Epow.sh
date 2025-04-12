#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global Variables
KEYPAIR_PATH="$HOME/.config/solana/id.json"

# Function to display a header
display_header() {
    echo -e "${CYAN}"
    echo -e " ${BLUE} ██████╗ ██╗  ██╗    ██████╗ ███████╗███╗   ██╗ █████╗ ███╗   ██╗${NC}"
    echo -e " ${BLUE}██╔═████╗╚██╗██╔╝    ██╔══██╗██╔════╝████╗  ██║██╔══██╗████╗  ██║${NC}"
    echo -e " ${BLUE}██║██╔██║ ╚███╔╝     ██████╔╝█████╗  ██╔██╗ ██║███████║██╔██╗ ██║${NC}"
    echo -e " ${BLUE}████╔╝██║ ██╔██╗     ██╔══██╗██╔══╝  ██║╚██╗██║██╔══██║██║╚██╗██║${NC}"
    echo -e " ${BLUE}╚██████╔╝██╔╝ ██╗    ██║  ██║███████╗██║ ╚████║██║  ██║██║ ╚████║${NC}"
    echo -e " ${BLUE}╚═════╝ ╚═╝  ╚═╝    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═══╝${NC}"
    echo -e "${BLUE}=======================================================${NC}"
    echo -e "${GREEN}       ✨ Bitz Setup Script ⛏️  ✨${NC}"
    echo -e "${BLUE}=======================================================${NC}"
}

# Function to ensure the script is run as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo -e "${RED}This script must be run as root.${NC}"
        exit 1
    fi
}

# Function to install necessary dependencies
install_dependencies() {
    echo -e "${CYAN}Installing dependencies...${NC}"
    apt update
    apt -qy install curl git jq lz4 build-essential screen
}

# Function to install Rust
install_rust() {
    echo -e "${YELLOW}Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${GREEN}Rust installed!${NC}"
}

# Function to install Solana CLI
install_solana_cli() {
    echo -e "${YELLOW}Installing Solana CLI...${NC}"
    curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    echo -e "${GREEN}Solana CLI installed!${NC}"
}

# Function to set Solana cluster
set_solana_cluster() {
    echo -e "${CYAN}🌐 Setting Solana CLI cluster to mainnet-beta...${NC}"
    solana config set --url "https://api.mainnet-beta.solana.com" >/dev/null 2>&1
}

# Function to generate the wallet and display keys
generate_wallet() {
    display_header
    echo -e "${CYAN}🔐 Generating new Solana wallet...${NC}"

    SOLANA_KEYGEN_OUTPUT=$(solana-keygen new --force --no-passphrase --outfile "$KEYPAIR_PATH")
    PUBKEY=$(solana-keygen pubkey "$KEYPAIR_PATH")
    SEED_PHRASE=$(echo "$SOLANA_KEYGEN_OUTPUT" | grep -A 12 "Save this seed phrase" | tail -n 12 | tr '\n' ' ')

    echo -e "${CYAN}=============================================================================="
    echo -e "${GREEN}Wallet Public Key (pubkey):${NC} ${PUBKEY}"
    echo -e "=============================================================================="
    echo -e "${GREEN}Seed phrase to recover your new keypair:${NC} ${SEED_PHRASE}"
    echo -e "=============================================================================="
    echo -e "${RED}⚠️ WARNING: This is your private key, which will be imported into Backpack. DO NOT share it!${NC}"
    echo -e "${BLUE}====================================${NC}"
    cat "$KEYPAIR_PATH"
    echo -e "${BLUE}====================================${NC}"
}

# Function to reboot the VPS
reboot_vps() {
    display_header
    echo -e "${CYAN}Rebooting VPS automatically...${NC}"
    reboot
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option:${NC}"
        echo -e " 1) ${WHITE}Install Solana Wallet${NC}"
        echo -e " 2) ${WHITE}Show Wallet Information${NC}"
        echo -e " 3) ${WHITE}Reboot VPS${NC}"
        echo -e " 4) ${WHITE}Exit${NC}"
        echo -e "${CYAN}====================================${NC}"

        read -p "$(echo -e "${CYAN}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_dependencies && install_rust && install_solana_cli && set_solana_cluster && generate_wallet && reboot_vps ;;
            2) generate_wallet ;;
            3) reboot_vps ;;
            4) echo -e "${GREEN}Exiting... See you later!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
    done
}

# Main Execution
check_root
main_menu
