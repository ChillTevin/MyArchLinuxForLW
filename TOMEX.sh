#!/bin/bash

# --- Colores Vanta-Violet ---
VIOLET='\033[38;5;93m'
V_BRIGHT='\033[38;5;141m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# Asegurar directorio de trabajo
cd "$(dirname "$0")"

rainbow_exit() {
    clear
    TEXT=">>> TOMEX POWER EDITION - CERRANDO SESION <<<"
    COLORS=(196 202 226 190 82 21 93)
    for (( i=0; i<${#TEXT}; i++ )); do
        color=${COLORS[$((i % ${#COLORS[@]}))]}
        echo -ne "\033[38;5;${color}m${TEXT:$i:1}"
    done
    echo -e "${RESET}\n"
    tput cnorm
    sleep 1.5
    exit 0
}

# --- SUBMENÚ: INSTALLERS ---
submenu_installers() {
    local SUB_OPCIONES=("InstallerApp.sh (GUI)" "InstallerAppCLI.sh (CLI)" "<-- Volver")
    local SUB_CURSOR=0
    local SUB_TOTAL=${#SUB_OPCIONES[@]}

    while true; do
        clear
        echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃                ${WHITE}T  O  M  E  X   V 9.1${VIOLET}                 ┃"
        echo -e "┃                ${CYAN}SECCIÓN: INSTALLERS${VIOLET}                 ┃"
        echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

        for i in "${!SUB_OPCIONES[@]}"; do
            if [ $i -eq $SUB_CURSOR ]; then
                echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${SUB_OPCIONES[$i]}  ${RESET}"
            else
                echo -e "     ${VIOLET}${SUB_OPCIONES[$i]}${RESET}"
            fi
        done

        read -rsn1 key
        case $key in
            $'\x1b')
                read -rsn2 key
                case $key in
                    '[A') [ $SUB_CURSOR -gt 0 ] && ((SUB_CURSOR--)) ;;
                    '[B') [ $SUB_CURSOR -lt $((SUB_TOTAL-1)) ] && ((SUB_CURSOR++)) ;;
                esac ;;
            "") 
                case $SUB_CURSOR in
                    0)
                        if [ -f "InstallerApp.sh" ]; then
                            chmod +x InstallerApp.sh && ./InstallerApp.sh
                        else
                            echo -e "${RED}✘ InstallerApp.sh no encontrado${RESET}"; sleep 2
                        fi ;;
                    1)
                        if [ -f "InstallerAppCLI.sh" ]; then
                            chmod +x InstallerAppCLI.sh && ./InstallerAppCLI.sh
                        else
                            echo -e "${RED}✘ InstallerAppCLI.sh no encontrado${RESET}"; sleep 2
                        fi ;;
                    2) return ;;
                esac ;;
        esac
    done
}

# --- MENÚ PRINCIPAL ---
MAIN_OPCIONES=("Installers" "Instalar HyDE Project" "Salir")
CURSOR=0
TOTAL=${#MAIN_OPCIONES[@]}

tput civis
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}T  O  M  E  X   V 9.1${VIOLET}                 ┃"
    echo -e "┃          ${CYAN}Kinetic Navigation System${VIOLET}             ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!MAIN_OPCIONES[@]}"; do
        if [ $i -eq $CURSOR ]; then
            echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${MAIN_OPCIONES[$i]}  ${RESET}"
        else
            echo -e "     ${VIOLET}${MAIN_OPCIONES[$i]}${RESET}"
        fi
    done

    read -rsn1 key
    case $key in
        $'\x1b')
            read -rsn2 key
            case $key in
                '[A') [ $CURSOR -gt 0 ] && ((CURSOR--)) ;;
                '[B') [ $CURSOR -lt $((TOTAL-1)) ] && ((CURSOR++)) ;;
            esac ;;
        "")
            case $CURSOR in
                0) submenu_installers ;;
                1)
                    echo -e "${CYAN}➜ Clonando HyDE...${RESET}"
                    sudo git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                    cd ~/HyDE/Scripts && chmod +x install.sh && ./install.sh
                    cd - > /dev/null ;;
                2) rainbow_exit ;;
            esac ;;
        q|Q) rainbow_exit ;;
    esac
done
