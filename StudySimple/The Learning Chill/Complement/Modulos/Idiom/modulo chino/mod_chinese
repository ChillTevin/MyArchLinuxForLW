#!/bin/bash

# --- Configuración de Datos ---
niveles=("HSK 1 " "HSK 2 " "HSK 3 " "HSK 4 " "HSK 5 " "HSK 6 " "Custom ")
modos=("Quiz " "Lectura 󰉿" "Flashcard 󰴓" "Game 󰊴" "Internet 󰖟")

seleccion_hsk=0
seleccion_modo=0
pinyin_active=0 

# --- Colores ---
NARANJA='\033[38;5;216m'
BG_SEL='\033[48;5;216m'
FG_SEL='\033[38;5;235m'
GRIS='\033[38;5;244m'
RESET='\033[0m'
BOLD='\033[1m'

dibujar_menu() {
    tput cup 0 0
    clear
    echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "         M Ó D U L O   D E   C H I N O "
    echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    for i in "${!niveles[@]}"; do
        if [ "$seleccion_hsk" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${niveles[$i]}"
        else
            printf "       ${NARANJA}%-35s${RESET}\n" "${niveles[$i]}"
        fi
    done

    echo -e "\n  ${GRIS}────────────────────────────────────────${RESET}"
    p_status=$( [ $pinyin_active -eq 1 ] && echo "ON" || echo "OFF" )
    printf "  ${NARANJA}Modo: ${RESET}${BOLD}< ${modos[$seleccion_modo]} >${RESET}  "
    printf "${NARANJA}Pinyin: ${RESET}${BOLD}[ $p_status ]${RESET}\n"
    echo -e "\n  ${GRIS}[↑/↓] Nivel  [←/→] Modo  [P] Pinyin  [Enter] Start  [Q] Salir${RESET}"
}

tput civis
while true; do
    dibujar_menu
    read -rsn3 -t 1 tecla
    case "$tecla" in
        $'\e[A') seleccion_hsk=$(( (seleccion_hsk + 6) % 7 )) ;;
        $'\e[B') seleccion_hsk=$(( (seleccion_hsk + 1) % 7 )) ;;
        $'\e[C') seleccion_modo=$(( (seleccion_modo + 1) % 5 )) ;;
        $'\e[D') seleccion_modo=$(( (seleccion_modo + 4) % 5 )) ;;
        "p"|"P") pinyin_active=$(( (pinyin_active + 1) % 2 )) ;;
        "") 
            if [ "$seleccion_modo" -eq 0 ]; then
                tput cnorm
                # Pasamos el nivel exacto (ej: "HSK 1") y el estado de Pinyin
                python3 quiz_chino.py "${niveles[$seleccion_hsk]}" "$pinyin_active"
                echo -e "\n${GRIS}Presiona una tecla para volver...${RESET}"
                read -n 1
                tput civis
            fi ;;
        "q"|"Q") tput cnorm; exit 0 ;;
    esac
done
