#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Display header
display_header() {
    clear
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

# Root check
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
fi

# Install CLI + Wallet
install_bitz_cli() {
    display_header
    echo -e "${CYAN}Installing dependencies and environment...${NC}"
    apt update
    apt -qy install curl git jq lz4 build-essential screen

    echo -e "${YELLOW}Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${GREEN}Rust installed!${NC}"

    echo -e "${YELLOW}Installing Solana CLI...${NC}"
    curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    echo -e "${GREEN}Solana CLI installed!${NC}"

    # Automatically set the Solana cluster to mainnet-beta
    echo -e "${CYAN}🌐 Setting Solana CLI cluster to mainnet-beta...${NC}"
    solana config set --url "https://api.mainnet-beta.solana.com" >/dev/null 2>&1

    # Wallet generation using `solana-keygen new` with --force flag
    display_header
    echo -e "${CYAN}🔐 Generating new Solana wallet...${NC}"

    KEYPAIR_PATH="$HOME/.config/solana/id.json"
    
    # Generate the new keypair and capture the output
    SOLANA_KEYGEN_OUTPUT=$(solana-keygen new --force --no-passphrase --outfile "$KEYPAIR_PATH")

    # Extract the public key
    PUBKEY=$(solana-keygen pubkey "$KEYPAIR_PATH")

    # Extract the seed phrase directly from the output
    SEED_PHRASE=$(echo "$SOLANA_KEYGEN_OUTPUT" | grep -A 12 "Save this seed phrase" | tail -n 12 | tr '\n' ' ')

    # Show wallet information
    echo -e "${YELLOW}Node Config Info:${NC}"
    solana config get

    # Display information in the desired format
    echo -e "${CYAN}"
    echo -e "=============================================================================="
    echo -e "${GREEN}pubkey:${NC} ${PUBKEY}"
    echo -e "=============================================================================="
    echo -e "${YELLOW}Save this seed phrase to recover your new keypair:${NC}"
    echo -e "${SEED_PHRASE}"
    echo -e "=============================================================================="
    echo -e "${RED}⚠️  WARNING: This is your PRIVATE KEY! DO NOT share it!${NC}"
    echo -e "${BLUE}====================================${NC}"
    cat "$KEYPAIR_PATH"
    echo -e "${BLUE}====================================${NC}"

    echo ""
    read -n 1 -s -r -p "$(echo -e "${YELLOW}Press any key to return to the menu...${NC}")"
}

# Reboot VPS (automatic)
restart_vps() {
    display_header
    echo -e "${CYAN}Rebooting VPS automatically...${NC}"
    sleep 2
    reboot
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option:${NC}"
        echo -e " 1) ${WHITE}Install Bitz${NC}"
        echo -e " 2) ${WHITE}Reboot VPS${NC}"
        echo -e " 3) ${WHITE}Exit${NC}"
        echo -e "${CYAN}====================================${NC}"

        read -p "$(echo -e "${CYAN}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_bitz_cli ;;
            2) restart_vps ;;
            3) echo -e "${GREEN}Exiting... See you later!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac
    done
}

# Start
main_menu
