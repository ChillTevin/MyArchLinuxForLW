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

# Comprobación de seguridad: Evitar ejecutar el script principal como root 
# para que las funciones de usuario normal sean posibles.
if [ "$EUID" -eq 0 ]; then 
  echo -e "${RED}Error: Ejecuta TOMEX sin 'sudo' (ej: ./TOMEX.sh).${RESET}"
  echo -e "${GOLD}El script te pedirá contraseña cuando necesite instalar algo.${RESET}"
  exit 1
fi

echo -e "${VIOLET}Actualizando paquetes del sistema...${RESET}"
sudo pacman -Syyu --noconfirm

# 1. INSTALACIÓN DE DEPENDENCIAS Y FIX DE YAY
clear
echo -e "${VIOLET}Checking dependencies...${RESET}"
sudo pacman -S --needed --noconfirm git base-devel wget

# --- LÓGICA DE DETECCIÓN Y FIX DE YAY (Usando privilegios correctamente) ---
if command -v yay &>/dev/null; then
    if ! yay -V &>/dev/null; then
        echo -e "${RED}⚠️ Error de librerías detectado en yay.${RESET}"
        echo -e "${GOLD}Reparando...${RESET}"
        sudo rm -rf /tmp/yay
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -si --noconfirm
        cd - > /dev/null
        echo -e "${GREEN}✔ yay ha sido reparado.${RESET}"
        sleep 2
    fi
else
    echo -e "${CYAN}➜ yay no detectado. Instalando...${RESET}"
    sudo rm -rf /tmp/yay
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm
    cd - > /dev/null
fi

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

# --- FUNCIÓN INTELIGENTE CON SELECTOR DE PRIVILEGIOS ---
# $1: Archivo, $2: URL, $3: usar_sudo (true/false)
run_smart() {
    local FILE=$1
    local URL=$2
    local USE_SUDO=$3

    # Descarga si no existe
    if [ ! -f "$FILE" ]; then
        echo -e "${CYAN}➜ Descargando $FILE desde GitHub...${RESET}"
        wget -q --show-progress "$URL" -O "$FILE"
        chmod +x "$FILE"
    else
        echo -e "${GREEN}✔ $FILE detectado localmente.${RESET}"
        chmod +x "$FILE"
    fi

    # Ejecución selectiva
    if [ "$USE_SUDO" = "true" ]; then
        echo -e "${GOLD}➜ Iniciando con privilegios de Superusuario...${RESET}"
        sudo bash "./$FILE"
    else
        echo -e "${VIOLET}➜ Iniciando como Usuario Normal (Seguro para AUR)...${RESET}"
        bash "./$FILE"
    fi

    echo -e "\n${GOLD}➜ Proceso finalizado. Presiona ENTER para volver...${RESET}"
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
        echo -e "┃                ${WHITE}T  O  M  E  X   V 10.2${VIOLET}                ┃"
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
                    0) run_smart "InstallerApp.sh" "$RAW_URL/InstallerApp.sh" "true" ;;
                    1) run_smart "InstallerAppCLI.sh" "$RAW_URL/InstallerAppCLI.sh" "true" ;;
                    2) return ;;
                esac ;;
        esac
    done
}

# --- MENÚ PRINCIPAL ---
MAIN_OPCIONES=("Installers" "Buscador de Repositorios (AUR/Pacman)" "Instalar HyDE Project" "Salir")
CURSOR=0
TOTAL=${#MAIN_OPCIONES[@]}
SEARCH_URL="https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/%F0%9D%93%A3%F0%9D%93%B8%F0%9D%93%B6%F0%9D%93%B2%F0%9D%94%81%F0%9D%93%90%F0%9D%93%BB%F0%9D%93%AC%F0%9D%93%B1/TOMEX_Search.sh"

tput civis
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}T  O  M  E  X   V 10.2${VIOLET}                ┃"
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
                1) run_smart "TOMEX_Search.sh" "$SEARCH_URL" "false" ;; # ESTE VA SIN SUDO
                2)
                    echo -e "${CYAN}➜ Iniciando instalador de HyDE...${RESET}"
                    if [ ! -d "$HOME/HyDE" ]; then
                        git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                    fi
                    cd ~/HyDE/Scripts && chmod +x install.sh && sudo ./install.sh # ESTE LLEVA SUDO
                    echo -e "\n${GOLD}➜ HyDE finalizado. Presiona ENTER para volver...${RESET}"
                    read
                    cd - > /dev/null ;;
                3) rainbow_exit ;;
            esac ;;
        q|Q) rainbow_exit ;;
    esac
done
