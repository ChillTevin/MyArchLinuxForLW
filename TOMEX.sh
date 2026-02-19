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

# Seguridad: No ejecutar el script principal con sudo
if [ "$EUID" -eq 0 ]; then 
  echo -e "${RED}Error: Por seguridad, ejecuta el script sin sudo: ./TOMEX.sh${RESET}"
  exit 1
fi

echo -e "${VIOLET}Sincronizando sistema...${RESET}"
sudo pacman -Syyu --noconfirm

# 1. DEPENDENCIAS
clear
echo -e "${VIOLET}Checking dependencies...${RESET}"
sudo pacman -S --needed --noconfirm git base-devel wget

# --- FIX DE YAY (Siempre como Usuario) ---
if ! command -v yay &>/dev/null || ! yay -V &>/dev/null; then
    echo -e "${RED}⚠️ Instalando/Reparando yay...${RESET}"
    sudo rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd - > /dev/null
fi

# Directorio de trabajo
BASE_DIR=$(pwd)
cd "$BASE_DIR"

# --- FUNCIÓN SMART (EJECUCIÓN SIN ROOT) ---
run_smart() {
    local FILE=$1
    local URL=$2

    # Limpiar si el archivo está corrupto
    if [ -f "$FILE" ] && [ $(stat -c%s "$FILE") -lt 100 ]; then
        sudo rm -f "$FILE"
    fi

    if [ ! -f "$FILE" ]; then
        echo -e "${CYAN}➜ Descargando $FILE...${RESET}"
        sudo wget -q --show-progress "$URL" -O "$FILE"
        # Devolver propiedad al usuario para que pueda ejecutarlo
        sudo chown $USER:$USER "$FILE"
        chmod +x "$FILE"
    else
        echo -e "${GREEN}✔ $FILE detectado.${RESET}"
        sudo chown $USER:$USER "$FILE"
        chmod +x "$FILE"
    fi

    echo -e "${VIOLET}➜ Iniciando $FILE (Modo Usuario)...${RESET}"
    # EJECUCIÓN SIN SUDO
    bash "$BASE_DIR/$FILE"

    echo -e "\n${GOLD}➜ Proceso finalizado. Presiona ENTER...${RESET}"
    read
}

# --- SUBMENÚ: INSTALLERS ---
submenu_installers() {
    local SUB_OPCIONES=("InstallerApp.sh (GUI Mode)" "InstallerAppCLI.sh (CLI Mode)" "<-- Volver")
    local SUB_CURSOR=0
    local SUB_TOTAL=${#SUB_OPCIONES[@]}
    local BRANCH_URL="https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/%F0%9D%93%A3%F0%9D%93%B8%F0%9D%93%B6%F0%9D%93%B2%F0%9D%94%81%F0%9D%93%90%F0%9D%93%BB%F0%9D%93%AC%F0%9D%93%B1"

    while true; do
        clear
        echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃                ${WHITE}T  O  M  E  X   V 10.6${VIOLET}                ┃"
        echo -e "┃                ${CYAN}NO-ROOT SMART LOGIC${VIOLET}                 ┃"
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
            $'\x1b') read -rsn2 key
                case $key in
                    '[A') [ $SUB_CURSOR -gt 0 ] && ((SUB_CURSOR--)) ;;
                    '[B') [ $SUB_CURSOR -lt $((SUB_TOTAL-1)) ] && ((SUB_CURSOR++)) ;;
                esac ;;
            "") case $SUB_CURSOR in
                    0) run_smart "InstallerApp.sh" "$BRANCH_URL/InstallerApp.sh" ;;
                    1) run_smart "InstallerAppCLI.sh" "$BRANCH_URL/InstallerAppCLI.sh" ;;
                    2) return ;;
                esac ;;
        esac
    done
}

# --- MENÚ PRINCIPAL ---
MAIN_OPCIONES=("Installers" "Buscador de Repositorios (AUR/Pacman)" "Instalar HyDE Project" "Salir")
CURSOR=0
TOTAL=${#MAIN_OPCIONES[@]}
BRANCH_URL="https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/%F0%9D%93%A3%F0%9D%93%B8%F0%9D%93%B6%F0%9D%93%B2%F0%9D%94%81%F0%9D%93%90%F0%9D%93%BB%F0%9D%93%AC%F0%9D%93%B1"

while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}T  O  M  E  X   V 10.6${VIOLET}                ┃"
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
        $'\x1b') read -rsn2 key
            case $key in
                '[A') [ $CURSOR -gt 0 ] && ((CURSOR--)) ;;
                '[B') [ $CURSOR -lt $((TOTAL-1)) ] && ((CURSOR++)) ;;
            esac ;;
        "") case $CURSOR in
                0) submenu_installers ;;
                1) run_smart "TOMEX_Search.sh" "$BRANCH_URL/TOMEX_Search.sh" ;;
                2) # HyDE Project
                    if [ ! -d "$HOME/HyDE" ]; then
                        git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                    fi
                    cd ~/HyDE/Scripts && chmod +x install.sh && ./install.sh
                    cd "$BASE_DIR" ;;
                3) exit 0 ;;
            esac ;;
    esac
done
