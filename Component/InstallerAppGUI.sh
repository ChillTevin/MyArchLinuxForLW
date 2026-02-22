#!/bin/bash
# Recibe el idioma desde el menú principal de TOMEX
idx_lang=${1:-0}

# --- Colores ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RESET='\033[0m'
BOLD='\033[1m'
BG_SELECT='\033[48;5;236m'

# --- Traducciones ---
case $idx_lang in
    0) t_title="CENTRO DE INSTALACIÓN"; opts=("󰀻  Instalador de APPs" "󰆍  Instalador de CLI" "󰈆  Volver") ;;
    1) t_title="INSTALLATION CENTER"; opts=("󰀻 App Installer" "󰆍 CLI Installer" "󰈆 Back") ;;
    2) t_title="安装中心"; opts=("󰀻  应用商店 (图形)" "󰆍  专业安装程序 (命令行)" "󰈆  返回") ;;
esac

# --- Directorio de componentes ---
DIR_COMP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# --- Menú de Selección ---
cursor=0
tput civis
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃             📦 $t_title                ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!opts[@]}"; do
        if [ $i -eq $cursor ]; then
            echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${opts[$i]}  ${RESET}"
        else
            echo -e "     ${VIOLET}${opts[$i]}${RESET}"
        fi
    done

    read -rsn1 k
    [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }

    case $k in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;;
        $'\x1b[B') [ $cursor -lt $((${#opts[@]}-1)) ] && ((cursor++)) ;;
        "") 
            case $cursor in
                0) 
                    # AQUÍ LANZAS TU APP STORE ACTUAL
                    # Si tu App Store se llama de otra forma, cambia el nombre aquí
                    if [ -f "$DIR_COMP/InstallerAppGUI.sh" ]; then
                        bash "$DIR_COMP/InstallerAppGUI.sh" "$idx_lang"
                    else
                        echo -e "${CYAN}Iniciando App Store...${RESET}"
                        sleep 1
                    fi
                    ;;
                1) 
                    # AQUÍ LANZAS EL DE LA TERMINAL
                    if [ -f "$DIR_COMP/InstallerAppCLI.sh" ]; then
                        bash "$DIR_COMP/InstallerAppCLI.sh" "$idx_lang"
                    else
                        echo -e "${RED}Error: InstallerAppCLI.sh no encontrado en $DIR_COMP${RESET}"
                        sleep 2
                    fi
                    ;;
                2) tput cnorm; exit 0 ;;
            esac ;;
    esac
done