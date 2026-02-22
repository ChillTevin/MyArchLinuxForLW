#!/bin/bash

sudo pacman -Syyu ----no-confirm

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
secret_count=0 # Contador para el Easter Egg
LAST_CLOCK_UPDATE=0
TIME_STR=""

# --- Función: TheLearningChill (Easter Egg Multilingüe) ---
run_learning_chill() {
    local CHILL_PATH="$BASE_DIR/StudySimple/The Learning Chill/TheLearnigChill.sh"
    
    clear
    if [ -f "$CHILL_PATH" ]; then
        # --- Traducciones Internas del Huevo de Pascua ---
        case $idx_lang in
            0) # ESPAÑOL
                msg_welcome="🌿 BIENVENIDO A THE LEARNING CHILL 🌿"
                msg_status="Has activado el modo de estudio de alto rendimiento."
                l_state="Estado"; val_state="Concentración Máxima"
                l_mission="Misión"; val_mission="Menos configuración, más aprendizaje."
                quote="\"La maestría no es un destino, es un camino constante.\""
                msg_back="Presiona cualquier tecla para iniciar..."
                err_file="No se encontró el archivo en:"
                err_fix="Verifica que la carpeta 'StudySimple' esté en la raíz del repo."
                ;;
            1) # ENGLISH
                msg_welcome="🌿 WELCOME TO THE LEARNING CHILL 🌿"
                msg_status="High-performance study mode activated."
                l_state="Status"; val_state="Maximum Focus"
                l_mission="Mission"; val_mission="Less configuration, more learning."
                quote="\"Mastery is not a destination, it is a constant path.\""
                msg_back="Press any key to start..."
                err_file="File not found at:"
                err_fix="Check if 'StudySimple' folder exists in the repo root."
                ;;
            2) # CHINESE
                msg_welcome="🌿 欢迎来到 THE LEARNING CHILL 🌿"
                msg_status="高性能学习模式已激活。"
                l_state="状态"; val_state="高度专注"
                l_mission="使命"; val_mission="减少配置，增加学习。"
                quote="\"精通不是终点，而是一条不断的道路。\""
                msg_back="按任意键开始..."
                err_file="未找到文件："
                err_fix="请检查仓库根目录下是否存在 'StudySimple' 文件夹。"
                ;;
        esac

        # --- Interfaz Visual ---
        echo -e "${VIOLET}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "          $msg_welcome"
        echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        echo -e "${CYAN}$msg_status${RESET}"
        echo -e "\n${WHITE}$l_state: ${GREEN}$val_state${RESET}"
        echo -e "${WHITE}$l_mission: ${GRAY}$val_mission${RESET}"
        echo -e "\n${GOLD}➜ $quote${RESET}"
        echo -e "\n${GRAY}$msg_back${RESET}"
        
        read -n 1
        
        # Ejecución del script externo
        chmod +x "$CHILL_PATH"
        bash "$CHILL_PATH" "$idx_lang" # También le pasamos el idioma al script de estudio
    else
        # Mensaje de error multilingüe
        echo -e "${RED}${BOLD}  [!] ERROR:${RESET} $err_file"
        echo -e "  ${GRAY}$CHILL_PATH${RESET}"
        echo -e "\n${GOLD}➜ $err_fix${RESET}"
        read -n 1
    fi
    secret_count=0 # Resetear contador al volver
}

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
           opts=("󰀻  Instaladores & Software" "󰍉  Buscador (AUR/Pacman)" "🍷  Herramientas & Wine" "󰇄  Entornos Gráficos" "󱗼  Instalar HyDE Project" "󰈆  Salir")
           l_idioma="Idioma"; f_nav="Navegar"; f_chg="Cambiar idioma"; f_conf="Confirmar" ;;
        1) # ENGLISH
           t_sub="Modern Management & Wine System"
           opts=("󰀻  Installers & Software" "󰍉  Search (AUR/Pacman)" "🍷  Tools & Wine" "󰇄  Desktop Environments" "󱗼  Install HyDE Project" "󰈆  Exit")
           l_idioma="Language"; f_nav="Navigate"; f_chg="Change language"; f_conf="Confirm" ;;
        2) # CHINESE
           t_sub="现代管理与 Wine 系统"
           opts=("󰀻  安装程序和软件" "󰍉  搜索 (AUR/Pacman)" "🍷  工具和 Wine" "󰇄  桌面环境" "󱗼  安装 HyDE 项目" "󰈆  退出")
           l_idioma="语言"; f_nav="导航"; f_chg="更改语言"; f_conf="确认" ;;
    esac

    # Lógica del Huevo de Pascua: Modificar la última opción si se activa
    if [ "$secret_count" -ge 2 ]; then
        opts[5]="🌿  TheLearningChill"
    fi

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
            # Color especial cian si el secreto está activo y estamos encima
            if [ "$i" -eq 5 ] && [ "$secret_count" -ge 2 ]; then
                printf "  ${BG_SELECT}${CYAN}${BOLD}  ➜  %-38s ${RESET}\n" "${opts[$i]}"
            else
                printf "  ${BG_SELECT}${GOLD}${BOLD}  ➜  %-38s ${RESET}\n" "${opts[$i]}"
            fi
        else
            printf "       ${VIOLET}%-38s${RESET}\n" "${opts[$i]}"
        fi
    done

    echo -e "\n"
    echo -e "      ${CYAN}󰗊 ${l_idioma}: ${RESET}${BOLD}< ${WHITE}${langs[$idx_lang]}${RESET}${BOLD} >${RESET}"
    echo -e "\n  ${GRAY}[↑/↓] ${f_nav}   [←/→] ${f_chg}   [Enter] ${f_conf}${RESET}"

    # Lectura de teclas
    read -rsn1 -t 1 tecla
    st=$?

    if [ $st -eq 0 ]; then
        [[ $tecla == $'\e' ]] && { read -rsn2 -t 0.1 r; tecla+="$r"; }
        case "$tecla" in
            $'\e[A') # ARRIBA
                seleccion=$(( (seleccion + 5) % 6 ))
                secret_count=0 # Resetear secreto al moverse
                ;;
            $'\e[B') # ABAJO
                if [ "$seleccion" -eq 5 ]; then
                    ((secret_count++)) # Si ya está en la última, aumentar contador de secreto
                else
                    seleccion=$(( (seleccion + 1) % 6 ))
                    secret_count=0
                fi
                ;;
            $'\e[C') idx_lang=$(( (idx_lang + 1) % 3 )); secret_count=0 ;;
            $'\e[D') idx_lang=$(( (idx_lang + 2) % 3 )); secret_count=0 ;;
           "") 
                case $seleccion in
                    0) run_smart "InstallerApp.sh" ;;
                    1) run_smart "TOMEX_Search.sh" ;;
                    2) run_smart "tools.sh" ;;
                    3) run_smart "DesktopEnv.sh" ;;
                    4) [[ ! -d "$HOME/HyDE" ]] && git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                       cd ~/HyDE/Scripts && ./install.sh; cd "$BASE_DIR" ;;
                    5) 
                        if [ "$secret_count" -ge 2 ]; then
                            run_learning_chill  # <--- AQUÍ LANZA TU SCRIPT DE ESTUDIO
                        else
                            clear; tput cnorm; exit 0
                        fi ;;
                esac ;;
        esac
    fi
done
