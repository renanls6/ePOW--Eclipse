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

    # Cluster auto-select: mainnet-beta
    echo -e "${BLUE}====================================${NC}"
    echo -e "${CYAN}🌐 Selecting Solana cluster automatically: mainnet-beta (1)...${NC}"
    CLUSTER_OPTION=1

    case $CLUSTER_OPTION in
        1)
            CLUSTER_URL="https://api.mainnet-beta.solana.com"
            ;;
        2)
            CLUSTER_URL="https://api.testnet.solana.com"
            ;;
        3)
            CLUSTER_URL="https://api.devnet.solana.com"
            ;;
        *)
            echo -e "${RED}❌ Invalid option. Exiting...${NC}"
            exit 1
            ;;
    esac

    solana config set --url "$CLUSTER_URL" >/dev/null 2>&1

    # Wallet generation
    display_header
    echo -e "${CYAN}🔐 Generating new Solana wallet...${NC}"

    KEYPAIR_PATH="$HOME/.config/solana/id.json"
    SOLANA_KEYGEN_OUTPUT=$(solana-keygen new --no-passphrase --outfile "$KEYPAIR_PATH")

    # Extract pubkey and seed phrase directly
    PUBKEY=$(solana-keygen pubkey "$KEYPAIR_PATH")
    SEED_PHRASE=$(solana-keygen recover --outfile /tmp/recovered-keypair.json "$KEYPAIR_PATH")

    # If the seed phrase was extracted successfully, display it
    if [[ -f /tmp/recovered-keypair.json ]]; then
        RECOVERED_SEED=$(cat /tmp/recovered-keypair.json | grep -oP '\"phrase\": \[.*\]' | sed 's/"phrase": \[//g' | sed 's/\]//g' | tr -d '"')
    fi


  echo ""
    echo -e "${BLUE}====================================${NC}"
    echo -e "${CYAN}⚙️  Current Solana CLI Configuration${NC}"
    echo -e "${BLUE}====================================${NC}"
    solana config get
    echo -e "${BLUE}====================================${NC}"

    echo ""
    echo -e "${GREEN}✅ Wallet successfully created!${NC}"
    echo -e "${CYAN}📁 Keypair Path: $KEYPAIR_PATH${NC}"

    echo ""
    echo -e "${YELLOW}📬 Public Key:${NC}"
    echo -e "$PUBKEY"

  echo ""
    echo -e "${YELLOW}📝 Seed Phrase for recovery (store securely):${NC}"
    echo -e "$RECOVERED_SEED"

    echo ""
    echo -e "${RED}⚠️  WARNING: This is your PRIVATE KEY! DO NOT share it!${NC}"
    echo -e "${BLUE}====================================${NC}"
    cat "$KEYPAIR_PATH"
    echo -e "${BLUE}====================================${NC}"

    echo ""
    read -n 1 -s -r -p "$(echo -e "${YELLOW}Press any key to return to the menu...${NC}")"
}

# Reboot VPS
restart_vps() {
    display_header
    echo -e "${RED}⚠️  Are you sure you want to reboot the VPS? (y/n)${NC}"
    read -p "> " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo -e "${CYAN}Rebooting VPS...${NC}"
        reboot
    else
        echo -e "${YELLOW}Reboot canceled.${NC}"
        sleep 2
    fi
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option:${NC}"
        echo -e "1) ${WHITE}Install Bitz CLI and Generate Wallet${NC}"
        echo -e "2) ${WHITE}Reboot VPS${NC}"
        echo -e "3) ${WHITE}Exit${NC}"
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
