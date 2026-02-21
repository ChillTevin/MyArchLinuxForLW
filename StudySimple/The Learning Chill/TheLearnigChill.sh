#!/bin/bash

# --- Configuración de Rutas Dinámicas ---
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUTA_IDIOM="$DIR_BASE/Complement/Modulos/Idiom"
RUTA_CUSTOM_RAIZ="$DIR_BASE/Complement/customadd"
ARCHIVO_TEMA_ACTUAL="$DIR_BASE/.tema_actual"

mkdir -p "$RUTA_CUSTOM_RAIZ"

# --- Sistema de Temas Dinámico ---
# Esta función carga los colores desde el archivo de estado o usa los de defecto
cargar_tema() {
    if [ -f "$ARCHIVO_TEMA_ACTUAL" ] && [ -f "$(cat "$ARCHIVO_TEMA_ACTUAL")" ]; then
        source "$(cat "$ARCHIVO_TEMA_ACTUAL")"
    else
        # Tema por defecto (Naranja Chill)
        export BG_SEL='\033[48;5;216m'
        export FG_SEL='\033[38;5;235m'
        export NARANJA='\033[38;5;216m'
        export GRIS='\033[38;5;244m'
        export BG_CLOCK='\033[48;5;236m'
    fi
    export RESET='\033[0m'
    export BOLD='\033[1m'
}

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

# --- Configuración de Idiomas, Estado y Reloj ---
idiomas=("Inglés" "Chino (Hanzi)" "Chino (Pinyin)" "Español")
idx_idioma=3 
seleccion=0
LAST_CLOCK_UPDATE=0
TIME_STR=""

# Cargar colores iniciales
cargar_tema

# --- Función de Reloj Estético (Actualización cada 5 min) ---
dibujar_reloj() {
    local ahora=$(date +%s)
    if [ $((ahora - LAST_CLOCK_UPDATE)) -ge 300 ] || [ $LAST_CLOCK_UPDATE -eq 0 ]; then
        TIME_STR=$(date +" %H:%M ")
        LAST_CLOCK_UPDATE=$ahora
    fi
    local col_reloj=$(( $(tput cols) - 10 ))
    tput cup 0 $col_reloj
    echo -e "${BG_CLOCK}${NARANJA}${BOLD}${TIME_STR}${RESET}"
}

# --- Lógica de Custom Add ---
menu_custom_add() {
    local ruta_actual="$1"
    [ -z "$ruta_actual" ] && ruta_actual="$RUTA_CUSTOM_RAIZ"
    local sel_custom=0
    
    while true; do
        items=()
        while IFS= read -r -d $'\0' d; do items+=("$(basename "$d")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
        while IFS= read -r -d $'\0' f; do items+=("$(basename "$f")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) -print0 2>/dev/null | sort -z)
        
        if [ "$ruta_actual" == "$RUTA_CUSTOM_RAIZ" ]; then items+=("Volver al Menú"); else items+=(".. Regresar"); fi
        
        local total=${#items[@]}
        clear
        dibujar_reloj
        echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "           C U S T O M    M O D U L E S "
        echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

        for i in "${!items[@]}"; do
            local item_real="${items[$i]}"
            local nombre_limpio="${item_real%.*}"; nombre_limpio="${nombre_limpio//_/ }"
            icon="  "
            [ -d "$ruta_actual/$item_real" ] && icon="  "
            [[ "$item_real" == *.sh ]] && icon="  "
            [[ "$item_real" == *.py ]] && icon="  "
            [[ "$item_real" == ".. Regresar" || "$item_real" == "Volver al Menú" ]] && icon="󰌍  "

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
                [[ "$eleccion" == "Volver al Menú" || "$eleccion" == ".. Regresar" ]] && return
                if [ -d "$ruta_actual/$eleccion" ]; then
                    menu_custom_add "$ruta_actual/$eleccion"
                    continue
                fi
                clear ; tput cnorm
                [[ "$eleccion" == *.sh ]] && bash "$ruta_actual/$eleccion"
                [[ "$eleccion" == *.py ]] && python3 "$ruta_actual/$eleccion"
                tput civis ; echo -e "\n${NARANJA}Presiona Enter para volver...${RESET}" ; read ; break ;;
        esac
    done
}

# --- Menú de Selección de Área ---
menu_seleccion_area() {
    local sub_sel=0
    while true; do
        clear
        dibujar_reloj
        case $idx_idioma in
            0) op1="Language "; op2="Smart 󰪚"; op3="Custom Add "; bk="Back"; titulo="S E L E C C I Ó N  D E  Á R E A" ;;
            1) op1="语言 "; op2="科学 󰪚"; op3="自定义 "; bk="返回"; titulo="选 择 区 域" ;;
            2) op1="Yǔyán "; op2="Kēxué 󰪚"; op3="Zìdìngyì "; bk="Fǎnhuí"; titulo="XUǍNZÉ QŪYÙ" ;;
            *) op1="Lenguajes "; op2="Ciencias (Smart) 󰪚"; op3="Custom Add "; bk="Volver"; titulo="S E L E C C I Ó N  D E  Á R E A" ;;
        esac
        op_menu=("$op1" "$op2" "$op3" "$bk")
        
        echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n         $titulo \n  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
        
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
                    fi ; break
                elif [ "$sub_sel" -eq 2 ]; then menu_custom_add "$RUTA_CUSTOM_RAIZ"
                elif [ "$sub_sel" -eq 3 ]; then break ; fi ;;
        esac
    done
}

# --- Bucle Principal ---
tput civis 
while true; do
    verificar_pantalla
    case $idx_idioma in
        0) m1="Knowledge "; m2="Settings "; m3="Exit "; txt_id="Language" ;;
        1) m1="知识 "; m2="设置 "; m3="退出 "; txt_id="语言" ;;
        2) m1="Zhīshì "; m2="Shèzhì "; m3="Tuìchū "; txt_id="Yǔyán" ;;
        *) m1="Conocimiento "; m2="Configuración "; m3="Salir "; txt_id="Idioma" ;;
    esac
    actual_lang=("$m1" "$m2" "$m3")
    
    clear
    dibujar_reloj
    
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
    [ "$seleccion" -eq 1 ] && echo -e "      ${NARANJA} $txt_id: ${RESET}${BOLD}< ${idiomas[$idx_idioma]} >${RESET}" || echo ""
    echo -e "\n  ${GRIS}[↑/↓] Mover  [Enter] Confirmar${RESET}"
    
    # Timeout de 2s para refrescar pantalla y reloj sin bloquear el script
    read -rsn1 -t 2 tecla
    exit_status=$?

    if [ $exit_status -eq 0 ]; then
        [[ $tecla == $'\e' ]] && { read -rsn2 -t 0.1 r; tecla+="$r"; }

        case "$tecla" in
            $'\e[A') seleccion=$(( (seleccion + 2) % 3 )) ;; 
            $'\e[B') seleccion=$(( (seleccion + 1) % 3 )) ;; 
            $'\e[C') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 1) % 4 )) ;;
            $'\e[D') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 3) % 4 )) ;;
            "") 
                if [ "$seleccion" -eq 0 ]; then
                    menu_seleccion_area
                elif [ "$seleccion" -eq 1 ]; then
                    # --- INTEGRACIÓN: Llamada a configuración ---
                    if [ -f "$DIR_BASE/configuracion.sh" ]; then
                        bash "$DIR_BASE/configuracion.sh" "${idiomas[$idx_idioma]}"
                        cargar_tema # Recargar los colores al volver por si se cambió el tema
                    else
                        clear
                        echo -e "${NARANJA}Error: No se encuentra configuracion.sh en $DIR_BASE${RESET}"
                        sleep 2
                    fi
                elif [ "$seleccion" -eq 2 ]; then
                    clear ; tput cnorm ; exit 0
                fi ;;
        esac
    fi
done