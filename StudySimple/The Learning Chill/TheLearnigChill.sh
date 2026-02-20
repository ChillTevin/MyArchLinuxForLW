#!/bin/bash

# --- Configuración de Rutas Dinámicas ---
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUTA_IDIOM="$DIR_BASE/Complement/Modulos/Idiom"
RUTA_CUSTOM_RAIZ="$DIR_BASE/Complement/customadd"

mkdir -p "$RUTA_CUSTOM_RAIZ"

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
idiomas=("Inglés" "Chino (Hanzi)" "Chino (Pinyin)" "Español")
idx_idioma=3 
seleccion=0

BG_SEL='\033[48;5;216m'
FG_SEL='\033[38;5;235m'
NARANJA='\033[38;5;216m'
GRIS='\033[38;5;244m'
RESET='\033[0m'
BOLD='\033[1m'

obtener_hora_aproximada() {
    printf "%s" "[$(date +%H:%M)]"
}

# --- Lógica de Custom Add Corregida (Solución a espacios) ---
menu_custom_add() {
    local ruta_actual="$1"
    [ -z "$ruta_actual" ] && ruta_actual="$RUTA_CUSTOM_RAIZ"
    
    local sel_custom=0
    while true; do
        items=()
        
        # 1. Escanear carpetas (respetando espacios en nombres)
        while IFS= read -r -d $'\0' d; do
            items+=("$(basename "$d")")
        done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)

        # 2. Escanear archivos .sh y .py (respetando espacios en nombres)
        while IFS= read -r -d $'\0' f; do
            items+=("$(basename "$f")")
        done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) -print0 2>/dev/null | sort -z)
        
        # 3. Botón de retorno dinámico
        if [ "$ruta_actual" == "$RUTA_CUSTOM_RAIZ" ]; then
            items+=("Volver al Menú")
        else
            items+=(".. Regresar")
        fi
        
        local total=${#items[@]}

        clear
        echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "           C U S T O M    M O D U L E S "
        echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

        for i in "${!items[@]}"; do
            local item_real="${items[$i]}"
            
            # Limpieza visual
            local nombre_limpio="${item_real%.*}"
            nombre_limpio="${nombre_limpio//_/ }"
            
            icon="  "
            # Identificar tipo para el icono
            if [ -d "$ruta_actual/$item_real" ]; then
                icon="  "
            elif [[ "$item_real" == *.sh ]]; then
                icon="  "
            elif [[ "$item_real" == *.py ]]; then
                icon="  "
            fi
            
            # Iconos especiales para volver/regresar
            [[ "$item_real" == ".. Regresar" ]] && icon="󰌍  " && nombre_limpio="Regresar"
            [[ "$item_real" == "Volver al Menú" ]] && icon="󰌍  " && nombre_limpio="Volver"

            if [ "$sel_custom" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "$icon$nombre_limpio"
            else
                printf "       ${NARANJA}%-35s${RESET}\n" "$icon$nombre_limpio"
            fi
        done

        read -rsn1 tecla
        [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }

        case "$tecla" in
            $'\e[A') sel_custom=$(( (sel_custom + total - 1) % total )) ;;
            $'\e[B') sel_custom=$(( (sel_custom + 1) % total )) ;;
            "") 
                local eleccion="${items[$sel_custom]}"
                
                [ "$eleccion" == "Volver al Menú" ] && return
                [ "$eleccion" == ".. Regresar" ] && return

                # Si es directorio, entra recursivamente
                if [ -d "$ruta_actual/$eleccion" ]; then
                    menu_custom_add "$ruta_actual/$eleccion"
                    sel_custom=0
                    continue
                fi

                # Si es archivo, lo ejecuta
                clear
                tput cnorm
                if [[ "$eleccion" == *.sh ]]; then
                    bash "$ruta_actual/$eleccion"
                elif [[ "$eleccion" == *.py ]]; then
                    python3 "$ruta_actual/$eleccion"
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
            [ "$sub_sel" -eq $i ] && printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${op_menu[$i]}" || printf "       ${NARANJA}%-35s${RESET}\n" "${op_menu[$i]}"
        done

        read -rsn1 t_sub
        [[ $t_sub == $'\e' ]] && { read -rsn2 r; t_sub+="$r"; }

        case "$t_sub" in
            $'\e[A') sub_sel=$(( (sub_sel + 3) % 4 )) ;;
            $'\e[B') sub_sel=$(( (sub_sel + 1) % 4 )) ;;
            "") 
                if [ "$sub_sel" -eq 0 ]; then
                    if cd "$RUTA_IDIOM" 2>/dev/null; then
                        FILE_LANG=$(ls Lenguage.sh* 2>/dev/null | head -n 1)
                        [ -n "$FILE_LANG" ] && bash "$FILE_LANG" "${idiomas[$idx_idioma]}"
                        cd "$DIR_BASE"
                    fi
                    break
                elif [ "$sub_sel" -eq 2 ]; then
                    menu_custom_add "$RUTA_CUSTOM_RAIZ"
                elif [ "$sub_sel" -eq 3 ]; then
                    break
                fi
                ;;
        esac
    done
}

# --- Bucle Principal ---
clear
tput civis 
while true; do
    verificar_pantalla
    case $idx_idioma in
        0) m1="Knowledge "; m2="Settings "; m3="Exit " ;;
        *) m1="Conocimiento "; m2="Configuración "; m3="Salir " ;;
    esac
    actual_lang=("$m1" "$m2" "$m3")
    
    tput cup 0 0
    printf "%*s\n" $(tput cols) "$(obtener_hora_aproximada)" | sed "s/\[/${NARANJA}[/"
    
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