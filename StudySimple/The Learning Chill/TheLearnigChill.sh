#!/bin/bash

# --- Traducciones (Conocimiento, Configuración, Salir) ---
lang_0=("Knowledge " "Settings " "Exit ")      # Inglés
lang_1=("知识 " "设置 " "退出 ")              # Chino
lang_2=("Zhishi " "Shezhi " "Tuichu ")        # Pinyin
lang_3=("Conocimiento " "Configuración " "Salir ") # Español

idiomas=("Inglés" "Chino (Hanzi)" "Chino (Pinyin)" "Español")
idx_idioma=3 # Empezamos en Español
seleccion=0

definir_colores() {
    # Paleta Naranja Suave / Piel
    BG_SEL='\033[48;5;216m'    # Fondo naranja suave
    FG_SEL='\033[38;5;235m'    # Letra oscura para contraste
    NARANJA='\033[38;5;216m'   # Texto naranja
    GRIS='\033[38;5;244m'
    RESET='\033[0m'
    BOLD='\033[1m'
}

dibujar_menu() {
    definir_colores
    RELOJ=$(date +%H:%M:%S)
    eval "actual_lang=(\"\${lang_$idx_idioma[@]}\")"

    tput cup 0 0
    # Reloj arriba a la derecha
    printf "%*s\n" $(tput cols) "[$RELOJ]" | sed "s/\[/${NARANJA}[/"
    
    echo -e "${NARANJA}${BOLD}"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "         T H E   L E A R N I N G   C H I L L "
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    # Renderizado de Opciones
    for i in 0 1 2; do
        if [ "$seleccion" -eq $i ]; then
            # Estética de barra seleccionada
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${actual_lang[$i]}"
        else
            printf "       ${NARANJA}%-35s${RESET}\n" "${actual_lang[$i]}"
        fi
    done

    # Mostrar idioma solo si estamos en Settings (opción 1)
    echo -e "\n"
    if [ "$seleccion" -eq 1 ]; then
        echo -e "      ${NARANJA} Idioma: ${RESET}${BOLD}< ${idiomas[$idx_idioma]} >${RESET}      "
    else
        echo -e "                                         " # Espacio vacío para mantener layout
    fi
    
    echo -e "\n  ${GRIS}[↑/↓] Mover  [Enter] Confirmar${RESET}"
    if [ "$seleccion" -eq 1 ]; then
        echo -e "  ${GRIS}[←/→] Cambiar idioma${RESET}"
    else
        echo -e "                        "
    fi
}

# --- Bucle Principal ---
clear
tput civis # Ocultar cursor
while true; do
    dibujar_menu
    read -rsn3 -t 1 tecla
    
    case "$tecla" in
        $'\e[A') seleccion=$(( (seleccion + 2) % 3 )) ;; # Arriba
        $'\e[B') seleccion=$(( (seleccion + 1) % 3 )) ;; # Abajo
        $'\e[C') # Derecha (Solo en Settings)
            if [ "$seleccion" -eq 1 ]; then
                idx_idioma=$(( (idx_idioma + 1) % 4 ))
            fi ;;
        $'\e[D') # Izquierda (Solo en Settings)
            if [ "$seleccion" -eq 1 ]; then
                idx_idioma=$(( (idx_idioma + 3) % 4 ))
            fi ;;
        "") 
            if [ -n "$tecla" ]; then
                if [ "$seleccion" -eq 0 ]; then
                    tput cnorm ; bash ./conocimiento.sh "${idiomas[$idx_idioma]}" ; tput civis
                elif [ "$seleccion" -eq 2 ]; then
                    clear ; tput cnorm ; exit 0
                fi
            fi ;;
    esac
done
