#!/bin/bash

# --- Configuración de Rutas Dinámicas ---
# Detecta la raíz del proyecto para que funcione en cualquier ubicación
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUTA_IDIOM="$DIR_BASE/Complement/Modulos/Idiom"
RUTA_CUSTOM="$DIR_BASE/Complement/customadd"

# Crear carpeta customadd si no existe para evitar errores
mkdir -p "$RUTA_CUSTOM"

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

# --- Configuración de Idiomas y Estado ---
lang_3=("Conocimiento " "Configuración " "Salir ")
lang_0=("Knowledge " "Settings " "Exit ")
lang_1=("知识 " "设置 " "退出 ")
lang_2=("Zhishi " "Shezhi " "Tuichu ")

idiomas=("Inglés" "Chino (Hanzi)" "Chino (Pinyin)" "Español")
idx_idioma=3 
seleccion=0

# Colores y Estética
BG_SEL='\033[48;5;216m'
FG_SEL='\033[38;5;235m'
NARANJA='\033[38;5;216m'
GRIS='\033[38;5;244m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Funciones de Utilidad ---
obtener_hora_aproximada() {
    HORA=$(date +%H)
    MIN=$(date +%M)
    MIN_REDONDO=$(( (MIN / 5) * 5 ))
    printf "%02d:%02d" $HORA $MIN_REDONDO
}

# --- Lógica de Custom Add (Plug & Play) ---
menu_custom_add() {
    local sel_custom=0
    while true; do
        # Escaneo de archivos .sh y .py en la carpeta Complement/customadd
        mapfile -t archivos < <(ls "$RUTA_CUSTOM" 2>/dev/null | grep -E '\.(sh|py)$')
        archivos+=("Volver")
        local total=${#archivos[@]}

        clear
        echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "           C U S T O M    M O D U L E S "
        echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

        for i in "${!archivos[@]}"; do
            # Asignar iconos según extensión
            icon=""
            [[ "${archivos[$i]}" == *.sh ]] && icon=" "
            [[ "${archivos[$i]}" == *.py ]] && icon=" "
            
            if [ "$sel_custom" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "$icon${archivos[$i]}"
            else
                printf "       ${NARANJA}%-35s${RESET}\n" "$icon${archivos[$i]}"
            fi
        done

        read -rsn1 tecla
        [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }

        case "$tecla" in
            $'\e[A') sel_custom=$(( (sel_custom + total - 1) % total )) ;;
            $'\e[B') sel_custom=$(( (sel_custom + 1) % total )) ;;
            "") 
                eleccion="${archivos[$sel_custom]}"
                [ "$eleccion" == "Volver" ] && return

                clear
                tput cnorm
                # Ejecutar según la extensión del archivo
                if [[ "$eleccion" == *.sh ]]; then
                    bash "$RUTA_CUSTOM/$eleccion"
                elif [[ "$eleccion" == *.py ]]; then
                    python3 "$RUTA_CUSTOM/$eleccion"
                fi
                tput civis
                echo -e "\n${NARANJA}Presiona Enter para volver...${RESET}"
                read ; break
                ;;
        esac
    done
}

# --- Menú de Selección de Área ---
menu_seleccion_area() {
    local sub_sel=0
    while true; do
        clear
        case $idx_idioma in
            0) op1="Language "; op2="Smart 󰪚"; op3="Custom Add "; bk="Back" ;;
            *) op1="Lenguajes "; op2="Ciencias (Smart) 󰪚"; op3="Custom Add "; bk="Volver" ;;
        esac
        
        op_menu=("$op1" "$op2" "$op3" "$bk")
        
        echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n         S E L E C C I Ó N   D E   Á R E A \n  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
        
        for i in "${!op_menu[@]}"; do
            if [ "$sub_sel" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${op_menu[$i]}"
            else
                printf "       ${NARANJA}%-35s${RESET}\n" "${op_menu[$i]}"
            fi
        done

        read -rsn1 t_sub
        [[ $t_sub == $'\e' ]] && { read -rsn2 r; t_sub+="$r"; }

        case "$t_sub" in
            $'\e[A') sub_sel=$(( (sub_sel + 3) % 4 )) ;;
            $'\e[B') sub_sel=$(( (sub_sel + 1) % 4 )) ;;
            "") 
                if [ "$sub_sel" -eq 0 ]; then
                    # Ir a Idiomas
                    if cd "$RUTA_IDIOM" 2>/dev/null; then
                        # Buscador robusto por si el archivo tiene espacios
                        FILE_LANG=$(ls Lenguage.sh* 2>/dev/null | head -n 1)
                        [ -n "$FILE_LANG" ] && bash "$FILE_LANG" "${idiomas[$idx_idioma]}"
                        cd "$DIR_BASE"
                    fi
                    break
                elif [ "$sub_sel" -eq 1 ]; then
                    echo -e "\n  ${NARANJA}Módulo Smart en construcción...${RESET}"
                    sleep 1 ; break
                elif [ "$sub_sel" -eq 2 ]; then
                    menu_custom_add
                elif [ "$sub_sel" -eq 3 ]; then
                    break
                fi
                ;;
        esac
    done
}

# --- Bucle Principal del Script ---
clear
tput civis 
while true; do
    verificar_pantalla
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
    
    read -rsn1 tecla
    [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }

    case "$tecla" in
        $'\e[A') seleccion=$(( (seleccion + 2) % 3 )) ;; 
        $'\e[B') seleccion=$(( (seleccion + 1) % 3 )) ;; 
        $'\e[C') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 1) % 4 )) ;;
        $'\e[D') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 3) % 4 )) ;;
        "") 
            if [ "$seleccion" -eq 0 ]; then
                menu_seleccion_area
            elif [ "$seleccion" -eq 2 ]; then
                clear ; tput cnorm ; exit 0
            fi
            ;;
    esac
    clear
done