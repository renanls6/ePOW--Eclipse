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
    solana-keygen new --no-passphrase --outfile ~/.config/solana/id.json
    solana config set --url https://mainnetbeta-rpc.eclipse.xyz >/dev/null 2>&1
    echo -e "${GREEN}Wallet created and RPC set!${NC}"
}

# Create and start the Bitz screen
create_bitz_screen() {
    display_header
    echo -e "${CYAN}Creating and opening Screen session 'bitz'...${NC}"

    # Create screen session and run cargo install bitz
    screen -S bitz -dm bash -c 'cargo install bitz; exec bash'

    echo -e "${GREEN}Screen 'bitz' created successfully and ready to run 'cargo install bitz'!${NC}"
    echo -e "${CYAN}You can access it using: ${YELLOW}screen -r bitz${NC}"
}

# Restart the Bitz node (stop the screen and restart it)
restart_bitz_node() {
    display_header
    echo -e "${CYAN}Stopping current 'bitz' screen and restarting it...${NC}"

    # Kill the existing 'bitz' screen session
    screen -S bitz -X quit

    # Create a new screen and start cargo install bitz
    screen -S bitz -dm bash -c 'cargo install bitz; exec bash'

    echo -e "${GREEN}Bitz node restarted successfully in the 'bitz' screen!${NC}"
    echo -e "${CYAN}You can access it anytime using: ${YELLOW}screen -r bitz${NC}"
}

# Remove Bitz setup (optional)
remove_bitz() {
    display_header
    echo -e "${YELLOW}Removing Bitz setup...${NC}"

    # Kill the 'bitz' screen session
    screen -S bitz -X quit 2>/dev/null

    # Remove Solana wallet and config files
    rm -f ~/.config/solana/id.json
    rm -f ~/.config/solana/config.json

    echo -e "${GREEN}Bitz setup removed successfully.${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option below:${NC}"
        echo -e "1) ${WHITE}Install Bitz CLI${NC}"
        echo -e "2) ${WHITE}Create and Start Bitz Screen${NC}"
        echo -e "3) ${GREEN}Restart Bitz Node ⛏️${NC}"
        echo -e "4) ${RED}Remove Bitz 🗑️${NC}"
        echo -e "5) ${WHITE}Exit${NC}"

        read -p "$(echo -e "${CYAN}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_bitz_cli ;;
            2) create_bitz_screen ;;
            3) restart_bitz_node ;;
            4) remove_bitz ;;
            5) echo -e "${GREEN}Exiting. Node may still be running in screen 'bitz'.${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac

        echo -e "${YELLOW}Press any key to return to the menu...${NC}"
        read -n 1 -s
    done
}

# Start the main menu
main_menu
