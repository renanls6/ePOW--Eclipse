#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[1;35m'
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
    echo -e "${GREEN}       ✨ Eclipse Node Setup Script (bitz collect) ✨${NC}"
    echo -e "${BLUE}=======================================================${NC}"
}

# Ensure root privileges
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}This script must be run as root.${NC}"
    echo -e "${YELLOW}Please run 'sudo -i' and try again.${NC}"
    exit 1
fi

# Load Rust if already installed
source $HOME/.cargo/env 2>/dev/null

# Full automatic installation
install_eclipse_node() {
    display_header
    echo -e "${CYAN}Starting Eclipse Node full installation...${NC}"

    # Install Rust
    echo -e "${YELLOW}Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    echo -e "${GREEN}Rust installed!${NC}"

    # Install Solana CLI
    echo -e "${YELLOW}Installing Solana CLI...${NC}"
    curl --proto '=https' --tlsv1.2 -sSfL https://solana-install.solana.workers.dev | bash
    export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
    echo -e "${GREEN}Solana CLI installed!${NC}"

    # Create Solana wallet
    echo -e "${YELLOW}Generating Solana wallet...${NC}"
    solana-keygen new --no-passphrase --outfile ~/.config/solana/id.json
    echo -e "${GREEN}Wallet created!${NC}"

    # Set RPC to Eclipse Mainnet automatically
    echo -e "${YELLOW}Configuring RPC to Eclipse Mainnet automatically...${NC}"
    solana config set --url https://mainnetbeta-rpc.eclipse.xyz
    echo -e "${GREEN}RPC set to Eclipse Mainnet automatically!${NC}"

    # Start node with screen
    echo -e "${YELLOW}Starting node with screen session 'eclipse'...${NC}"
    screen -S eclipse -dm bash -c "bitz collect"
    echo -e "${GREEN}Node started inside screen session 'eclipse'!${NC}"
    echo -e "${CYAN}To view logs: screen -r eclipse${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${BLUE}To exit this script, press Ctrl+C${NC}"
        echo -e "${YELLOW}Choose an option below:${NC}"
        echo -e "1) ${GREEN}Install Eclipse Node (Rust + Solana + Wallet + Start Node)${NC}"
        echo -e "2) ${CYAN}Start Node only (bitz collect in screen)${NC}"
        echo -e "3) ${RED}Exit${NC}"

        read -p "$(echo -e "${BLUE}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_eclipse_node ;;
            2)
                echo -e "${YELLOW}Starting node...${NC}"
                screen -S eclipse -dm bash -c "bitz collect"
                echo -e "${GREEN}Node started in screen session 'eclipse'!${NC}"
                ;;
            3) echo -e "${GREEN}Exiting. Goodbye!${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac

        echo -e "${YELLOW}Press any key to return to the menu...${NC}"
        read -n 1 -s
    done
}

# Launch menu
main_menu
