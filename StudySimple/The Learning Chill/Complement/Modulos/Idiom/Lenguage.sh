#!/bin/bash

# --- Recibir Idioma del Sistema ---
IDIOMA_SISTEMA=$1 

# Colores y Estética
BG_SEL='\033[48;5;216m'
FG_SEL='\033[38;5;235m'
NARANJA='\033[38;5;216m'
BOLD='\033[1m'
RESET='\033[0m'

# Traducciones dinámicas para este menú
case "$IDIOMA_SISTEMA" in
    "Inglés") l1="Chinese Module"; l2="English Module"; bk="Back" ;;
    "Chino (Hanzi)") l1="中文模块"; l2="英文模块"; bk="返回" ;;
    "Chino (Pinyin)") l1="Zhongwen Mokuai"; l2="Yingwen Mokuai"; bk="Fanhui" ;;
    *) l1="Módulo de Chino"; l2="Módulo de Inglés"; bk="Volver" ;;
esac

opciones=("$l1" "$l2" "$bk")
sel=0

while true; do
    clear
    echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "          S E L E C T   L A N G U A G E "
    echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    for i in "${!opciones[@]}"; do
        if [ "$sel" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${opciones[$i]}"
        else
            printf "       ${NARANJA}%-35s${RESET}\n" "${opciones[$i]}"
        fi
    done

    # Lectura de teclas
    read -rsn1 tecla
    if [[ $tecla == $'\e' ]]; then
        read -rsn2 resto
        tecla+="$resto"
    fi

    case "$tecla" in
        $'\e[A') sel=$(( (sel + 2) % 3 )) ;;
        $'\e[B') sel=$(( (sel + 1) % 3 )) ;;
        "") 
            if [ "$sel" -eq 0 ]; then
                # Entrar a Chino (Ruta corregida según tu imagen)
                if [ -d "./modulo_chino" ]; then
                    cd "./modulo_chino"
                    bash ./mod_chinese.sh "$IDIOMA_SISTEMA"
                    cd ..
                    break
                else
                    echo -e "\n  Error: No se encuentra la carpeta 'modulo_chino'"
                    sleep 2
                fi
            elif [ "$sel" -eq 1 ]; then
                # Entrar a Inglés (Ruta corregida según tu imagen)
                if [ -d "./modulo_inglish" ]; then
                    cd "./modulo_inglish"
                    bash ./mod_inglish.sh "$IDIOMA_SISTEMA"
                    cd ..
                    break
                else
                    echo -e "\n  Error: No se encuentra la carpeta 'modulo_inglish'"
                    sleep 2
                fi
            elif [ "$sel" -eq 2 ]; then
                exit 0 # Regresa a TheLearnigChill.sh
            fi ;;
    esac
done