#!/bin/bash

# --- Requisitos de Pantalla ---
MIN_COLS=80
MIN_LINES=24

verificar_pantalla() {
    if [ "$(tput cols)" -lt "$MIN_COLS" ] || [ "$(tput lines)" -lt "$MIN_LINES" ]; then
        clear
        echo -e "\033[38;5;216m⚠️ Pantalla pequeña: $(tput cols)x$(tput lines). Mínimo: ${MIN_COLS}x${MIN_LINES}\033[0m"
        exit 1
    fi
}

# --- Configuración de Idiomas ---
lang_3=("Conocimiento " "Configuración " "Salir ")
lang_0=("Knowledge " "Settings " "Exit ")
lang_1=("知识 " "设置 " "退出 ")
lang_2=("Zhishi " "Shezhi " "Tuichu ")

idiomas=("Inglés" "Chino (Hanzi)" "Chino (Pinyin)" "Español")
idx_idioma=3 
seleccion=0

# --- LÓGICA DE RUTA DINÁMICA ---
DIR_BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Ruta hacia la carpeta donde están los módulos de idiomas
RUTA_IDIOM="$DIR_BASE/Complement/Modulos/Idiom"

# Colores
BG_SEL='\033[48;5;216m'
FG_SEL='\033[38;5;235m'
NARANJA='\033[38;5;216m'
GRIS='\033[38;5;244m'
RESET='\033[0m'
BOLD='\033[1m'

obtener_hora_aproximada() {
    HORA=$(date +%H)
    MIN=$(date +%M)
    MIN_REDONDO=$(( (MIN / 5) * 5 ))
    printf "%02d:%02d" $HORA $MIN_REDONDO
}

dibujar_menu() {
    eval "actual_lang=(\"\${lang_$idx_idioma[@]}\")"
    tput cup 0 0
    printf "%*s\n" $(tput cols) "[$(obtener_hora_aproximada)]" | sed "s/\[/${NARANJA}[/"
    
    echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "         T H E   L E A R N I N G   C H I L L "
    echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    for i in 0 1 2; do
        if [ "$seleccion" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${actual_lang[$i]}"
        else
            printf "       ${NARANJA}%-35s${RESET}\n" "${actual_lang[$i]}"
        fi
    done

    echo -e "\n"
    [ "$seleccion" -eq 1 ] && echo -e "      ${NARANJA} Idioma: ${RESET}${BOLD}< ${idiomas[$idx_idioma]} >${RESET}" || echo ""
    echo -e "\n  ${GRIS}[↑/↓] Mover  [Enter] Confirmar${RESET}"
}

clear
tput civis 
while true; do
    verificar_pantalla
    dibujar_menu
    
    read -rsn1 tecla
    if [[ $tecla == $'\e' ]]; then
        read -rsn2 resto
        tecla+="$resto"
    fi

    case "$tecla" in
        $'\e[A') seleccion=$(( (seleccion + 2) % 3 )) ;; 
        $'\e[B') seleccion=$(( (seleccion + 1) % 3 )) ;; 
        $'\e[C') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 1) % 4 )) ;;
        $'\e[D') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 3) % 4 )) ;;
        "") 
            if [ "$seleccion" -eq 0 ]; then
                sub_sel=0
                while true; do
                    clear
                    case $idx_idioma in
                        0) l1="Language "; l2="Smart 󰪚"; bk="Back" ;;
                        1) l1="语言 "; l2="智能 󰪚"; bk="返回" ;;
                        2) l1="Yuyan "; l2="Zhineng 󰪚"; bk="Fanhui" ;;
                        *) l1="Lenguajes "; l2="Ciencias (Smart) 󰪚"; bk="Volver" ;;
                    esac
                    echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n         S E L E C C I Ó N   D E   Á R E A \n  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
                    
                    [ "$sub_sel" -eq 0 ] && printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "$l1" || printf "       ${NARANJA}%-35s${RESET}\n" "$l1"
                    [ "$sub_sel" -eq 1 ] && printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "$l2" || printf "       ${NARANJA}%-35s${RESET}\n" "$l2"
                    [ "$sub_sel" -eq 2 ] && printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "$bk" || printf "       ${NARANJA}%-35s${RESET}\n" "$bk"

                    read -rsn1 t_sub
                    [[ $t_sub == $'\e' ]] && { read -rsn2 r; t_sub+="$r"; }

                    case "$t_sub" in
                        $'\e[A') sub_sel=$(( (sub_sel + 2) % 3 )) ;;
                        $'\e[B') sub_sel=$(( (sub_sel + 1) % 3 )) ;;
                        "") 
                            if [ "$sub_sel" -eq 0 ]; then
                                tput cnorm
                                if cd "$RUTA_IDIOM" 2>/dev/null; then
                                    # BUSCADOR INTELIGENTE: Busca Lenguage.sh sin importar mayúsculas
                                    FILE=$(find . -maxdepth 1 -iname "Lenguage.sh" -print -quit)
                                    
                                    if [ -n "$FILE" ]; then
                                        chmod +x "$FILE" # Asegura permisos sobre la marcha
                                        bash "$FILE" "${idiomas[$idx_idioma]}"
                                    else
                                        echo -e "\n  Error: No se encontró el archivo Lenguage.sh"
                                        echo -e "  Contenido de la carpeta:"
                                        ls
                                        sleep 5
                                    fi
                                    cd "$DIR_BASE"
                                else
                                    echo -e "\n  Error: No se puede entrar a: $RUTA_IDIOM"
                                    sleep 5
                                fi
                                tput civis ; break
                            elif [ "$sub_sel" -eq 1 ]; then
                                echo -e "\n  ${NARANJA}Módulo Smart en construcción...${RESET}"
                                sleep 1 ; break
                            elif [ "$sub_sel" -eq 2 ]; then break; fi
                            ;;
                    esac
                done
                clear
            elif [ "$seleccion" -eq 2 ]; then
                clear ; tput cnorm ; exit 0
            fi
            ;;
    esac
done