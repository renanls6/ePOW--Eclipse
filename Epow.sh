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
    echo -e "${GREEN}       ✨ Bitz Setup Script ⛏️💎✨${NC}"
    echo -e "${BLUE}=======================================================${NC}"
}

# Ensure root privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
fi

# Install dependencies and Bitz CLI
install_bitz_cli() {
    display_header
    echo -e "${CYAN}Installing dependencies and Bitz CLI...${NC}"
    sudo apt update
    sudo apt -qy install curl git jq lz4 build-essential screen

    echo -e "${YELLOW}Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${GREEN}Rust installed!${NC}"

    echo -e "${YELLOW}Installing Solana CLI...${NC}"
    curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    echo -e "${GREEN}Solana CLI installed!${NC}"

    echo -e "${YELLOW}Creating Solana wallet...${NC}"

    # Create new keypair and capture output
    SOLANA_KEYGEN_OUTPUT=$(solana-keygen new --no-passphrase --outfile ~/.config/solana/id.json)

    # Extract pubkey and seed phrase
    PUBKEY=$(echo "$SOLANA_KEYGEN_OUTPUT" | grep "pubkey" | awk '{print $2}')
    SEED_PHRASE=$(echo "$SOLANA_KEYGEN_OUTPUT" | grep "Save this seed phrase" -A 12 | tail -n 12 | tr '\n' ' ')

    solana config set --url https://mainnetbeta-rpc.eclipse.xyz >/dev/null 2>&1
    echo -e "${GREEN}Wallet created and RPC set!${NC}"

    # Show wallet details
    echo -e "${CYAN}Import to Backpack:${NC}"
    echo -e "${YELLOW}Solana Config Info:${NC}"
    solana config get

    # Show the Keypair path
    KEYPAIR_PATH=$(solana config get | grep "Keypair Path" | awk '{print $3}')
    echo -e "${CYAN}Copy the Keypair path: ${KEYPAIR_PATH}${NC}"

    # Convert the private key to base58 and show it
    PRIVATE_KEY_BASE58=$(solana-keygen pubkey "$KEYPAIR_PATH" | sed 's/\n//')

    # Display the wallet contents (private key)
    echo -e "${YELLOW}Wallet Private Key (DO NOT share this!):${NC}"
    solana-keygen pubkey "$KEYPAIR_PATH" # This shows the private key in base58 format.

    # Display the new keypair information
    echo -e "${YELLOW}New Keypair Information:${NC}"
    echo -e "=============================================================================="
    echo -e "pubkey: ${PUBKEY}"
    echo -e "=============================================================================="
    echo -e "Save this seed phrase to recover your new keypair:"
    echo -e "${SEED_PHRASE}"
    echo -e "=============================================================================="

    # Show the private key (DO NOT share)
    echo -e "${YELLOW}Private Key in Base58 (DO NOT share this!):${NC}"
    echo -e "${PRIVATE_KEY_BASE58}"
    echo -e "=============================================================================="
}

# Restart the VPS
restart_vps() {
    display_header
    echo -e "${CYAN}Restarting VPS...${NC}"
    sudo reboot
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option below:${NC}"
        echo -e "1) ${WHITE}Install Bitz CLI${NC}"
        echo -e "2) ${WHITE}Restart VPS${NC}"
        echo -e "3) ${WHITE}Exit${NC}"

        read -p "$(echo -e "${CYAN}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_bitz_cli ;;
            2) restart_vps ;;
            3) echo -e "${GREEN}Exiting.${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac

        echo -e "${YELLOW}Press any key to return to the menu...${NC}"
        read -n 1 -s
    done
}

# Start the main menu
main_menu
