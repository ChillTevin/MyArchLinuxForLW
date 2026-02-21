#!/bin/bash

# --- Configuración de Colores ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
GRAY='\033[38;5;244m'
BG_CLOCK='\033[48;5;236m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Configuración de Rutas ---
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
COMPONENT_DIR="$BASE_DIR/Component"
mkdir -p "$COMPONENT_DIR"

# URL de Repositorio (Ruta de tu GitHub)
BRANCH_URL="https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/%F0%9D%93%A3%F0%9D%93%B8%F0%9D%93%B6%F0%9D%93%B2%F0%9D%94%81%F0%9D%93%90%F0%9D%93%BB%F0%9D%93%AC%F0%9D%93%B1"

# --- Variables de Idioma y Estado ---
idx_lang=0 # 0: Español, 1: English, 2: 中文
langs=("Español" "English" "中文 (Chinese)")
seleccion=0
LAST_CLOCK_UPDATE=0
TIME_STR=""

# --- Función: Reloj Estético ---
dibujar_reloj() {
    local ahora=$(date +%s)
    if [ $((ahora - LAST_CLOCK_UPDATE)) -ge 60 ] || [ $LAST_CLOCK_UPDATE -eq 0 ]; then
        TIME_STR=$(date +" %H:%M:%S ")
        LAST_CLOCK_UPDATE=$ahora
    fi
    local col_reloj=$(( $(tput cols) - 12 ))
    tput cup 0 $col_reloj
    echo -e "${BG_CLOCK}${CYAN}${BOLD}${TIME_STR}${RESET}"
}

# --- Función: Ejecutor de Componentes ---
run_smart() {
    local FILE=$1
    local TARGET="$COMPONENT_DIR/$FILE"
    clear
    if [ ! -f "$TARGET" ]; then
        echo -e "${CYAN}➜ Downloading $FILE...${RESET}"
        wget -q --show-progress "$BRANCH_URL/$FILE" -O "$TARGET"
        chmod +x "$TARGET"
    fi
    # Pasamos el idioma al sub-script para que también sepa qué idioma usar
    bash "$TARGET" "$idx_lang"
    echo -e "\n${GOLD}➜ Enter...${RESET}"; read
}

# --- Bucle Principal ---
tput civis
while true; do
    # --- Definición de Textos según Idioma ---
    case $idx_lang in
        0) # ESPAÑOL
           t_sub="Gestión Moderna & Sistema Wine"
           opts=("󰀻  Instaladores & Software" "󰍉  Buscador (AUR/Pacman)" "🍷  Herramientas & Wine" "󱗼  Instalar HyDE Project" "󰈆  Salir")
           l_idioma="Idioma"
           f_nav="Navegar"
           f_chg="Cambiar idioma"
           f_conf="Confirmar"
           ;;
        1) # ENGLISH
           t_sub="Modern Management & Wine System"
           opts=("󰀻  Installers & Software" "󰍉  Search (AUR/Pacman)" "🍷  Tools & Wine" "󱗼  Install HyDE Project" "󰈆  Exit")
           l_idioma="Language"
           f_nav="Navigate"
           f_chg="Change language"
           f_conf="Confirm"
           ;;
        2) # CHINESE
           t_sub="现代管理与 Wine 系统"
           opts=("󰀻  安装程序和软件" "󰍉  搜索 (AUR/Pacman)" "🍷  工具和 Wine" "󱗼  安装 HyDE 项目" "󰈆  退出")
           l_idioma="语言"
           f_nav="导航"
           f_chg="更改语言"
           f_conf="确认"
           ;;
    esac

    clear
    dibujar_reloj
    
    # Header Moderno
    echo -e "${VIOLET}${BOLD}  ╔══════════════════════════════════════════════════════╗"
    echo -e "  ║                ${WHITE}𝓣 𝓞 𝓜 𝓔 𝓧   𝓐 𝓻 𝓬 𝓱   𝓥 11${VIOLET}              ║"
    echo -e "  ║           ${CYAN}${t_sub}${VIOLET}            ║"
    echo -e "  ╚══════════════════════════════════════════════════════╝${RESET}\n"

    # Dibujar Menú
    for i in "${!opts[@]}"; do
        if [ "$seleccion" -eq $i ]; then
            printf "  ${BG_SELECT}${GOLD}${BOLD}  ➜  %-38s ${RESET}\n" "${opts[$i]}"
        else
            printf "       ${VIOLET}%-38s${RESET}\n" "${opts[$i]}"
        fi
    done

    # --- Selector de Idioma Inferior ---
    echo -e "\n"
    echo -e "      ${CYAN}󰗊 ${l_idioma}: ${RESET}${BOLD}< ${WHITE}${langs[$idx_lang]}${RESET}${BOLD} >${RESET}"

    # Footer de Navegación Traducido
    echo -e "\n  ${GRAY}[↑/↓] ${f_nav}   [←/→] ${f_chg}   [Enter] ${f_conf}${RESET}"

    # Lectura de teclas
    read -rsn1 -t 1 tecla
    st=$?

    if [ $st -eq 0 ]; then
        [[ $tecla == $'\e' ]] && { read -rsn2 -t 0.1 r; tecla+="$r"; }
        case "$tecla" in
            $'\e[A') seleccion=$(( (seleccion + 4) % 5 )) ;;
            $'\e[B') seleccion=$(( (seleccion + 1) % 5 )) ;;
            $'\e[C') idx_lang=$(( (idx_lang + 1) % 3 )) ;; # Derecha -> Siguiente idioma
            $'\e[D') idx_lang=$(( (idx_lang + 2) % 3 )) ;; # Izquierda -> Idioma anterior
            "") 
                case $seleccion in
                    0) run_smart "InstallerApp.sh" ;;
                    1) run_smart "TOMEX_Search.sh" ;;
                    2) run_smart "tools.sh" ;;
                    3) [[ ! -d "$HOME/HyDE" ]] && git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                       cd ~/HyDE/Scripts && ./install.sh; cd "$BASE_DIR" ;;
                    4) clear; tput cnorm; exit 0 ;;
                esac ;;
        esac
    fi
done