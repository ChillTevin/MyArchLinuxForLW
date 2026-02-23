#!/bin/bash

# --- Cyber Violet Palette ---
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
DIM='\033[2m'

# --- Environment Detection ---
IS_DOCKER=false
if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup; then
    IS_DOCKER=true
fi

# --- State Variables ---
LOGGED_USER=""
HAS_PRIVILEGED_USER=false

# --- Root Check ---
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}ERROR: This portal requires Root privileges.${RESET}"
   exit 1
fi

check_privileged() {
    EXISTING_USERS=$(grep '^wheel:' /etc/group | cut -d: -f4 | tr ',' ' ')
    if [ -n "$EXISTING_USERS" ]; then
        HAS_PRIVILEGED_USER=true
        if [ -z "$LOGGED_USER" ]; then
            LOGGED_USER=$(echo $EXISTING_USERS | awk '{print $1}')
        fi
    else
        HAS_PRIVILEGED_USER=false
    fi
}

draw_header() {
    clear
    echo -e "${DEEP_PURPLE}╭──────────────────────────────────────────────────────────╮"
    echo -e "│${BOLD}${MAGENTA}             💜  TOMEX SYSTEM PORTAL  💜                  ${RESET}${DEEP_PURPLE}│"
    echo -e "╰──────────────────────────────────────────────────────────╯${RESET}"
    if [ "$IS_DOCKER" = true ]; then
        echo -e "      ${CYAN}[MODO: CONTENEDOR DETECTADO]${RESET}"
    else
        echo -e "      ${GREEN}[MODO: SISTEMA REAL / HARDWARE]${RESET}"
    fi
}

register_user() {
    if [ "$HAS_PRIVILEGED_USER" = true ]; then
        echo -e "\n  ${RED}[!] Admin already exists.${RESET}"
        sleep 2; return
    fi
    draw_header
    echo -e "  ${MAGENTA}📝 NEW ACCOUNT REGISTRATION${RESET}"
    echo -e "  ${VIOLET}───────────────────────────${RESET}"
    
    read -p "  ➜ Desired Username: " LOGGED_USER
    useradd -m -G wheel -s /bin/bash "$LOGGED_USER"
    echo -e "  ${CYAN}➜ Create password for $LOGGED_USER:${RESET}"
    passwd "$LOGGED_USER"

    # --- Lógica Inteligente de Sudoers ---
    if [ "$IS_DOCKER" = true ]; then
        # En Docker permitimos NOPASSWD para evitar bloqueos de terminal
        echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
    else
        # En sistema real, usamos la configuración segura (pide contraseña)
        sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
        sed -i 's/^#%wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    fi

    echo -e "\n  ${GREEN}✔ Account registered successfully.${RESET}"
    HAS_PRIVILEGED_USER=true
    sleep 2
}

login_and_start() {
    draw_header
    USER_HOME="/home/$LOGGED_USER"
    REPO_URL="https://github.com/ChillTevin/MyArchLinuxForLW"

    echo -e "  ${MAGENTA}🛠️  Checking dependencies...${RESET}"
    pacman -Sy --needed --noconfirm base-devel git &>/dev/null

    echo -e "  ${VIOLET}🚀 Synchronizing Repository...${RESET}"
    sudo -u "$LOGGED_USER" bash -c "
        if [ ! -d '$USER_HOME/MyArchLinuxForLW' ]; then
            git clone $REPO_URL '$USER_HOME/MyArchLinuxForLW'
        else
            cd '$USER_HOME/MyArchLinuxForLW' && git pull
        fi
    "

    if [ -f "$USER_HOME/MyArchLinuxForLW/TOMEX.sh" ]; then
        chmod +x "$USER_HOME/MyArchLinuxForLW/TOMEX.sh"
        echo -e "${GREEN}  ✔ Starting session...${RESET}"
        sleep 1
        
        cd "$USER_HOME/MyArchLinuxForLW"
        
        if [ "$IS_DOCKER" = true ]; then
            # Modo Docker: sudo -i para evitar error ioctl
            sudo -i -u "$LOGGED_USER" bash -c "cd '$USER_HOME/MyArchLinuxForLW' && ./TOMEX.sh; exec bash"
        else
            # Modo Real: login tradicional con persistencia
            exec su - "$LOGGED_USER" -c "cd '$USER_HOME/MyArchLinuxForLW' && ./TOMEX.sh; exec bash"
        fi
        exit 0
    else
        echo -e "${RED}  [!] Error: TOMEX.sh not found.${RESET}"
        sleep 3
    fi
}

# --- Main Menu (Igual al anterior) ---
cursor=0
while true; do
    check_privileged
    draw_header
    options=(" [ REGISTER ] " " [ LOGIN ] " " [ EXIT ] ")
    for i in "${!options[@]}"; do
        if [ $i -eq $cursor ]; then
            echo -e "  ${MAGENTA}➜ ${BG_SELECT}${WHITE}${BOLD} ${options[$i]} ${RESET}"
        else
            [[ $i -eq 0 && "$HAS_PRIVILEGED_USER" = true ]] && echo -e "     ${RED}${DIM}${options[$i]} (Locked)${RESET}" || \
            ([[ $i -eq 1 && "$HAS_PRIVILEGED_USER" = false ]] && echo -e "     ${DIM}${options[$i]} (Wait)${RESET}" || \
            echo -e "     ${LAVANDA}${options[$i]}${RESET}")
        fi
    done
    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }
    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;;
        $'\x1b[B') [ $cursor -lt 2 ] && ((cursor++)) ;;
        "") [[ $cursor -eq 0 ]] && register_user; [[ $cursor -eq 1 ]] && login_and_start; [[ $cursor -eq 2 ]] && exit 0 ;;
    esac
done