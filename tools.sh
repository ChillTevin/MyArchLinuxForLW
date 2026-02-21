#!/bin/bash

# --- Configuración de Colores ---
ROSA='\033[38;5;205m'
MORADO='\033[38;5;93m'
AMARILLO='\033[38;5;220m'
CYAN='\033[38;5;51m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# Localización
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WINE_MANAGER="$DIR_BASE/wine_manager.sh"

# --- Variables de Estado ---
cursor=0        
sub_idx=0       # 0=Glibc, 1=Bionic, 2=Settings

# --- BUCLE PRINCIPAL ---
opciones=("Choose Wine Environment" "Open File Manager" "Terminal Widget Installer" "Back to TOMEX")

while true; do
    clear
    echo -e "${MORADO}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}🧰  T O M E X   T O O L S${MORADO}             ┃"
    echo -e "┃           ${CYAN}Advanced Management System${MORADO}             ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!opciones[@]}"; do
        if [ $i -eq $cursor ]; then
            if [ $i -eq 0 ]; then
                # --- Lógica de Color Dinámico para el Carrusel ---
                case $sub_idx in
                    0) selector_txt="${ROSA} < Glibc > ${RESET}" ;;
                    1) selector_txt="${MORADO} < Bionic > ${RESET}" ;;
                    2) selector_txt="${AMARILLO} < Settings > ${RESET}" ;;
                esac
                echo -e "${BG_SELECT}${AMARILLO}  ➜  ${WHITE}${BOLD}${opciones[$i]}:${RESET}${selector_txt}${BG_SELECT} ${RESET}"
            else
                echo -e "${BG_SELECT}${AMARILLO}  ➜  ${WHITE}${BOLD}${opciones[$i]}  ${RESET}"
            fi
        else
            # Opciones no seleccionadas
            if [ $i -eq 0 ]; then
                # Mostrar qué hay seleccionado actualmente pero sin brillo
                case $sub_idx in
                    0) simple_txt="Glibc" ;;
                    1) simple_txt="Bionic" ;;
                    2) simple_txt="Settings" ;;
                esac
                echo -e "     ${MORADO}${opciones[$i]}: ${WHITE}$simple_txt${RESET}"
            else
                echo -e "     ${MORADO}${opciones[$i]}${RESET}"
            fi
        fi
    done

    echo -e "\n${AMARILLO}  [↑/↓] Menú  [←/→] Cambiar  [Enter] Confirmar${RESET}"

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }

    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;; 
        $'\x1b[B') [ $cursor -lt $((${#opciones[@]}-1)) ] && ((cursor++)) ;; 
        $'\x1b[C') # Derecha
            [ $cursor -eq 0 ] && sub_idx=$(( (sub_idx + 1) % 3 )) ;;
        $'\x1b[D') # Izquierda
            [ $cursor -eq 0 ] && sub_idx=$(( (sub_idx + 2) % 3 )) ;;
        "") 
            case $cursor in
                0) 
                    case $sub_idx in
                        0) echo -e "${GREEN}➜ Entorno Glibc (Rosa) seleccionado.${RESET}"; sleep 0.5 ;;
                        1) echo -e "${GREEN}➜ Entorno Bionic (Morado) seleccionado.${RESET}"; sleep 0.5 ;;
                        2) # Ejecutar Settings
                           if [ -f "$WINE_MANAGER" ]; then
                               bash "$WINE_MANAGER"
                           else
                               echo -e "${RED}Error: wine_manager.sh no encontrado${RESET}"; sleep 2
                           fi ;;
                    esac ;;
                1) if command -v ranger &> /dev/null; then ranger; else ls -F; read; fi ;;
                2) echo -e "${CYAN}Abriendo instalador de widgets...${RESET}"; sleep 1 ;;
                3) exit 0 ;;
            esac ;;
    esac
done