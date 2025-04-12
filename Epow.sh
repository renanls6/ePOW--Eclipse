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
    echo -e "${GREEN}       ✨ If this script was helpful, feel free to follow me on X: https://x.com/renanls6 ✨${NC}"
    echo -e "${BLUE}=======================================================${NC}"
}

# Ensure root privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}This script must be run as root.${NC}"
    echo -e "${YELLOW}Please run 'sudo -i' and try again.${NC}"
    exit 1
fi

source $HOME/.cargo/env 2>/dev/null

# Install Bitz CLI
install_bitz_cli() {
    display_header
    echo -e "${CYAN}Installing dependencies and Bitz CLI...${NC}"
    sudo apt -qy install curl git jq lz4 build-essential screen
    echo -e "${GREEN}Dependencies installed!${NC}"

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

# Create screen session and run bitz mining (cargo install bitz inside screen)
start_bitz_screen() {
    display_header
    echo -e "${CYAN}Creating Screen 'bitz' and starting Bitz Mining...${NC}"

    # Check if a screen session named 'bitz' already exists, and kill it if necessary
    screen -S bitz -X quit 2>/dev/null

    # Create the screen session and run the bitz installation command
    screen -S bitz -dm bash -c 'cargo install bitz; exec bash'  # Create screen and run the command
    echo -e "${GREEN}Screen 'bitz' created and mining started inside the screen.${NC}"
    
    # After creating the screen, attach to it immediately
    echo -e "${CYAN}Attaching to the 'bitz' screen...${NC}"
    screen -r bitz  # This will bring you into the screen session
}

# Remove Bitz files, kill screen session, and clean up
remove_bitz() {
    display_header
    echo -e "${YELLOW}Stopping and removing screen session 'bitz'...${NC}"

    # Kill any existing 'bitz' screen session
    screen -S bitz -X quit 2>/dev/null

    echo -e "${GREEN}Screen 'bitz' has been stopped.${NC}"

    echo -e "${YELLOW}Removing Bitz setup...${NC}"
    rm -f ~/.config/solana/id.json
    rm -f ~/.config/solana/config.json
    rm -f ~/.cargo/bin/bitz
    echo -e "${GREEN}Bitz removed successfully.${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option below:${NC}"
        echo -e "1) ${WHITE}Install Bitz CLI${NC}"
        echo -e "2) ${GREEN}Run Bitz Mining ⛏️${NC}"
        echo -e "3) ${RED}Remove Bitz 🗑️${NC}"
        echo -e "4) ${WHITE}Exit${NC}"

        read -p "$(echo -e "${CYAN}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_bitz_cli ;;
            2) start_bitz_screen ;;
            3) remove_bitz ;;
            4) echo -e "${GREEN}Exiting. Node may still be running in screen 'bitz'.${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac

        echo -e "${YELLOW}Press any key to return to the menu...${NC}"
        read -n 1 -s
    done
}

# Start menu
main_menu
