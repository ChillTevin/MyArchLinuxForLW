#!/bin/bash

# --- Configuración de Colores ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# 1. INSTALACIÓN DE DEPENDENCIAS AL INICIAR
clear
echo -e "${VIOLET}Checking dependencies...${RESET}"
sudo pacman -S --needed --noconfirm git base-devel

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
    sleep 1.2
    exit 0
}

# --- FUNCIÓN PARA EJECUTAR CON LÓGICA SMART ---
# Recibe 1: Nombre del archivo, 2: URL de descarga
run_smart() {
    local FILE=$1
    local URL=$2

    if [ -f "$FILE" ]; then
        echo -e "${GREEN}✔ Archivo $FILE detectado localmente. Iniciando...${RESET}"
        chmod +x "$FILE" && ./"$FILE"
    else
        echo -e "${CYAN}➜ Archivo no encontrado. Descargando desde GitHub...${RESET}"
        wget -q --show-progress "$URL" -O "$FILE"
        chmod +x "$FILE" && ./"$FILE"
    fi
    echo -e "\n${GOLD}➜ Proceso finalizado. Presiona ENTER para volver a TOMEX...${RESET}"
    read
}

# --- SUBMENÚ: INSTALLERS ---
submenu_installers() {
    local SUB_OPCIONES=("InstallerApp.sh (GUI Mode)" "InstallerAppCLI.sh (CLI Mode)" "<-- Volver")
    local SUB_CURSOR=0
    local SUB_TOTAL=${#SUB_OPCIONES[@]}
    local RAW_URL="https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/main"

    while true; do
        clear
        echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃                ${WHITE}T  O  M  E  X   V 9.4${VIOLET}                 ┃"
        echo -e "┃                ${CYAN}SMART-LOGIC SECTION${VIOLET}                 ┃"
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
                    0) run_smart "InstallerApp.sh" "$RAW_URL/InstallerApp.sh" ;;
                    1) run_smart "InstallerAppCLI.sh" "$RAW_URL/InstallerAppCLI.sh" ;;
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
    echo -e "┃                ${WHITE}T  O  M  E  X   V 9.4${VIOLET}                 ┃"
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
                    echo -e "${CYAN}➜ Verificando HyDE Project...${RESET}"
                    if [ ! -d "$HOME/HyDE" ]; then
                        sudo git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                    fi
                    cd ~/HyDE/Scripts && chmod +x install.sh && ./install.sh
                    echo -e "\n${GOLD}➜ HyDE finalizado. Presiona ENTER para volver...${RESET}"
                    read
                    cd - > /dev/null ;;
                2) rainbow_exit ;;
            esac ;;
        q|Q) rainbow_exit ;;
    esac
done
