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

# Full installation of Bitz CLI and dependencies
install_bitz_cli() {
    display_header
    echo -e "${CYAN}Starting full installation for Bitz CLI...${NC}"

    echo -e "${YELLOW}Installing dependencies...${NC}"
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
    echo -e "${GREEN}Wallet created!${NC}"

    solana config set --url https://mainnetbeta-rpc.eclipse.xyz >/dev/null 2>&1

    echo -e "${YELLOW}Creating screen session 'bitz' with command ready...${NC}"
    screen -S bitz -dm bash -c 'read -p "Press Enter to run: cargo install bitz" && cargo install bitz; exec bash'

    echo -e "${GREEN}Installation completed and screen 'bitz' is ready!${NC}"
    echo -e "${CYAN}To enter it manually: ${YELLOW}screen -r bitz${NC}"
}

# Start a screen session with command ready
start_bitz_screen() {
    display_header
    echo -e "${CYAN}Creating screen session 'bitz' with cargo install bitz prepared...${NC}"
    screen -S bitz -dm bash -c 'read -p "Press Enter to run: cargo install bitz" && cargo install bitz; exec bash'
    echo -e "${GREEN}Screen 'bitz' created successfully!${NC}"
    echo -e "${CYAN}To access it: ${YELLOW}screen -r bitz${NC}"
}

# Run Bitz node inside the screen
run_bitz_in_screen() {
    display_header
    echo -e "${YELLOW}Launching screen 'bitz' and running: cargo install bitz...${NC}"

    # Create screen if not exists
    screen -ls | grep -q "\.bitz" || screen -S bitz -dm bash

    # Send command to the screen
    screen -S bitz -X stuff "cargo install bitz && exec bash\n"

    echo -e "${GREEN}Command sent to screen. To monitor: screen -r bitz${NC}"
}

# Remove Bitz CLI and config
remove_bitz() {
    display_header
    echo -e "${YELLOW}Stopping screen session 'bitz' if it exists...${NC}"
    screen -S bitz -X quit 2>/dev/null
    echo -e "${GREEN}Screen 'bitz' closed (if it was running).${NC}"

    echo -e "${YELLOW}Removing wallet and config files...${NC}"
    rm -f ~/.config/solana/id.json
    rm -f ~/.config/solana/config.json
    echo -e "${GREEN}Cleanup complete!${NC}"
}

# Main menu
main_menu() {
    while true; do
        display_header
        echo -e "${YELLOW}Choose an option below:${NC}"
        echo -e "1) ${GREEN}Install Bitz CLI (Rust + Solana + Wallet + Screen)${NC}"
        echo -e "2) ${CYAN}Prepare screen with command: cargo install bitz${NC}"
        echo -e "3) ${MAGENTA}Run Bitz node (send command to screen)${NC}"
        echo -e "4) ${RED}Remove Bitz setup${NC}"
        echo -e "5) ${BLUE}Exit${NC}"

        read -p "$(echo -e "${BLUE}Enter your choice: ${NC}")" choice

        case $choice in
            1) install_bitz_cli ;;
            2) start_bitz_screen ;;
            3) run_bitz_in_screen ;;
            4) remove_bitz ;;
            5)
                echo -e "${GREEN}Exiting. Goodbye!${NC}"
                echo -e "${YELLOW}If screen 'bitz' is running, it will stay active in background.${NC}"
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
