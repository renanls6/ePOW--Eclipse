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

# Install necessary packages
install_dependencies() {
    echo -e "${YELLOW}Installing necessary packages...${NC}"
    apt -qy install curl git jq lz4 build-essential screen -y
    echo -e "${GREEN}Dependencies installed!${NC}"
}

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
    solana config set --url https://mainnetbeta-rpc.eclipse.xyz

    # Notify user that installation is complete
    echo -e "${GREEN}Bitz installation completed! Now starting the node in a screen session...${NC}"

    # Start the node in the 'eclipse' screen session
    screen -S eclipse -dm bash -c "bitz collect"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Node started inside screen session 'eclipse'!${NC}"
        echo -e "${CYAN}To view logs: screen -r eclipse${NC}"
    else
        echo -e "${RED}Failed to start the node. Please check the installation and try again.${NC}"
    fi
}

# View logs from the screen session
view_logs() {
    display_header
    echo -e "${YELLOW}Displaying logs from the 'eclipse' screen session...${NC}"

    # Attach to the screen session to view logs or start node if it's not running
    screen -S eclipse -X quit 2>/dev/null
    echo -e "${CYAN}Session 'eclipse' stopped. Starting the node in the session...${NC}"
    
    # Start the node in the 'eclipse' screen session with cargo install bitz (if it's not already running)
    screen -S eclipse -dm bash -c "cargo install bitz && bitz collect"
    echo -e "${GREEN}Node started inside screen session 'eclipse' with 'cargo install bitz'!${NC}"
    echo -e "${CYAN}To view logs: screen -r eclipse${NC}"
}

# Remove node and clean up
remove_eclipse_node() {
    display_header
    echo -e "${YELLOW}Stopping node inside screen session 'eclipse'...${NC}"

    # Stop the screen session
    screen -S eclipse -X quit
    echo -e "${GREEN}Node stopped!${NC}"

    # Optionally, remove wallet and configuration files
    echo -e "${YELLOW}Removing Solana wallet and configuration files...${NC}"
    rm -f ~/.config/solana/id.json
    rm -f ~/.config/solana/config.json
    echo -e "${GREEN}Wallet and config files removed!${NC}"

    # Optionally, remove Solana and Rust installations (if desired)
    # echo -e "${YELLOW}Removing Solana CLI and Rust...${NC}"
    # rm -rf $HOME/.local/share/solana
    # rm -rf $HOME/.cargo
    # rm -rf $HOME/.rustup
    # echo -e "${GREEN}Solana CLI and Rust removed!${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${BLUE}To exit this script, press Ctrl+C${NC}"
        echo -e "${YELLOW}Choose an option below:${NC}"
        echo -e "1) ${GREEN}Install Bitz CLI (Rust + Solana + Wallet) and Start Node${NC}"
        echo -e "2) ${CYAN}View Logs from 'eclipse' Screen or Restart Node${NC}"
        echo -e "3) ${RED}Remove Bitz ${NC}"
        echo -e "4) ${RED}Exit${NC}"

        read -p "$(echo -e "${BLUE}Enter your choice: ${NC}")" choice

        case $choice in
            1) 
                install_dependencies
                install_eclipse_node
                ;;
            2) view_logs ;;
            3) remove_eclipse_node ;;
            4) 
                echo -e "${GREEN}Exiting. Goodbye!${NC}"
                echo -e "${YELLOW}Node is still running in the 'eclipse' screen session!${NC}"
                exit 0
                ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}" ;;
        esac

        echo -e "${YELLOW}Press any key to return to the menu...${NC}"
        read -n 1 -s
    done
}

# Launch menu
main_menu
