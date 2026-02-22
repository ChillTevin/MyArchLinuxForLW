#!/bin/bash

# --- Color Palette (Cyber Violet) ---
VIOLET='\033[38;5;129m'
DEEP_PURPLE='\033[38;5;93m'
MAGENTA='\033[38;5;201m'
CYAN='\033[38;5;51m'
WHITE='\033[38;5;255m'
BG_SELECT='\033[48;5;236m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}ERROR: This script must be run as root (use sudo).${RESET}"
   exit 1
fi

# --- Logic: Check for Existing Privileged Users ---
# We check the 'wheel' group for existing members
EXISTING_USERS=$(grep '^wheel:' /etc/group | cut -d: -f4)
HAS_PRIVILEGED_USER=false
if [ -n "$EXISTING_USERS" ]; then
    HAS_PRIVILEGED_USER=true
fi

# --- UI Functions ---
draw_header() {
    clear
    echo -e "${DEEP_PURPLE}╭──────────────────────────────────────────────────────────╮"
    echo -e "│${BOLD}${MAGENTA}             💜  SYSTEM REGISTRATION PORTAL  💜           ${RESET}${DEEP_PURPLE}│"
    echo -e "╰──────────────────────────────────────────────────────────╯${RESET}"
}

show_warning() {
    if [ "$HAS_PRIVILEGED_USER" = true ]; then
        echo -e "  ${VIOLET}STATUS:${RESET} ${GREEN}Privileged account detected: (${EXISTING_USERS})${RESET}"
        echo -e "  ${VIOLET}NOTICE:${RESET} ${WHITE}You can skip registration and proceed to TOMEX.${RESET}"
    else
        echo -e "  ${VIOLET}STATUS:${RESET} ${RED}No privileged user found. Registration required.${RESET}"
    fi
    echo ""
}

# --- Registration Logic ---
register_user() {
    draw_header
    echo -e "  ${MAGENTA}📝 CREATE NEW ADMINISTRATOR${RESET}"
    echo -e "  ${VIOLET}───────────────────────────${RESET}"
    
    read -p "  ➜ Enter Username: " new_username
    
    if id "$new_username" &>/dev/null; then
        echo -e "\n  ${RED}Error: User '$new_username' already exists!${RESET}"
        sleep 2
        return
    fi

    # 1. Create user
    useradd -m -G wheel "$new_username"
    
    # 2. Set password
    echo -e "  ${CYAN}➜ Set password for $new_username:${RESET}"
    passwd "$new_username"

    # 3. Enable Sudo (Uncomment %wheel in /etc/sudoers)
    if [ -f /etc/sudoers ]; then
        sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
        # Alternative in case the line format is different
        sed -i 's/^#%wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
        echo -e "\n  ${GREEN}✔ Sudo privileges granted to 'wheel' group.${RESET}"
    fi

    echo -e "  ${GREEN}✔ User '$new_username' registered successfully!${RESET}"
    sleep 2
    start_tomex
}

# --- Repository Logic ---
start_tomex() {
    echo -e "\n  ${MAGENTA}🚀 Initializing TOMEX Environment...${RESET}"
    
    # Check dependencies
    for pkg in git; do
        if ! command -v $pkg &>/dev/null; then
            pacman -S --needed --noconfirm $pkg &>/dev/null
        fi
    done

    if [ -d "MyArchLinuxForLW" ]; then
        rm -rf MyArchLinuxForLW
    fi

    echo -e "  ${VIOLET}➜ Cloning repository...${RESET}"
    git clone https://github.com/ChillTevin/MyArchLinuxForLW
    
    cd MyArchLinuxForLW || exit
    if [ -f "tomex.sh" ]; then
        chmod +x tomex.sh
        echo -e "  ${GREEN}✔ Starting tomex.sh...${RESET}"
        sleep 1
        bash tomex.sh
    else
        echo -e "  ${RED}Error: tomex.sh not found in repository!${RESET}"
        read -p "Press Enter to return..."
    fi
    exit 0
}

# --- Main Menu Loop ---
options=(" [ REGISTER ] " " [ START TOMEX ] " " [ EXIT ] ")
cursor=0

while true; do
    draw_header
    show_warning

    for i in "${!options[@]}"; do
        if [ $i -eq $cursor ]; then
            echo -e "  ${MAGENTA}➜ ${BG_SELECT}${WHITE}${BOLD} ${options[$i]} ${RESET}"
        else
            echo -e "     ${LAVANDA}${options[$i]}${RESET}"
        fi
    done

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }

    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;;
        $'\x1b[B') [ $cursor -lt $((${#options[@]}-1)) ] && ((cursor++)) ;;
        "") 
            case $cursor in
                0) register_user ;;
                1) start_tomex ;;
                2) echo -e "\n  ${VIOLET}Goodbye!${RESET}"; exit 0 ;;
            esac
            ;;
    esac
done