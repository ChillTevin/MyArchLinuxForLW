#!/bin/bash

# --- PROTOCOLO DE LOCALIZACIÓN ABSOLUTA (GSI-CORE) ---
ORIGEN_EJECUCION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ESCALADOR DE RUTAS: Garantiza que DIR_BASE siempre apunte a la raíz 
if [[ "$ORIGEN_EJECUCION" == *"Complement/theme"* ]]; then
    export DIR_BASE="$(cd "$ORIGEN_EJECUCION/../../" && pwd)"
else
    export DIR_BASE="$ORIGEN_EJECUCION"
fi

# VARIABLES DE ENLACE PROTEGIDAS [cite: 7]
CONFIG_SCRIPT="$DIR_BASE/configuracion.sh"
RUTA_IDIOM="$DIR_BASE/Complement/Modulos/Idiom"
RUTA_CUSTOM_RAIZ="$DIR_BASE/Complement/customadd"
ARCHIVO_TEMA_ACTUAL="$DIR_BASE/.tema_actual"
RUTA_MI_TEMA="$DIR_BASE/Complement/theme/Gemini_CLI"

mkdir -p "$RUTA_MI_TEMA"
mkdir -p "$RUTA_CUSTOM_RAIZ"

# --- SISTEMA DE TEMAS DINÁMICO (HERENCIA DE COLOR) [cite: 15, 21] ---
cargar_tema() {
    if [ -f "$ARCHIVO_TEMA_ACTUAL" ] && [ -f "$(cat "$ARCHIVO_TEMA_ACTUAL")" ]; then
        source "$(cat "$ARCHIVO_TEMA_ACTUAL")"
    else
        export BG_SEL='\033[48;5;216m'
        export FG_SEL='\033[38;5;235m'
        export NARANJA='\033[38;5;216m'
        export GRIS='\033[38;5;244m'
        export BG_CLOCK='\033[48;5;236m'
    fi
    export RESET='\033[0m'
    export BOLD='\033[1m'
}

# --- MONITOR DE SISTEMA (GSI-DATA)  ---
mostrar_info_gemini() {
    local uptime_sys=$(uptime -p | sed 's/up //')
    echo -e "  ${GRIS}System: ${BOLD}Gemini-Core${RESET} ${GRIS}| Uptime: ${uptime_sys}${RESET}"
}

# --- REQUISITOS Y RELOJ ---
verificar_pantalla() {
    if [ "$(tput cols)" -lt 80 ] || [ "$(tput lines)" -lt 24 ]; then
        clear
        echo -e "${NARANJA}⚠️ Interfaz restringida. Se requiere terminal 80x24.${RESET}"
        exit 1
    fi
}

dibujar_reloj() {
    local tiempo=$(date +"%H:%M:%S")
    tput cup 0 $(( $(tput cols) - 12 ))
    echo -e "${BG_CLOCK}${BOLD} ${tiempo} ${RESET}"
}

# --- INTERFAZ GEMINI CLI [cite: 9, 10] ---
banner_gemini() {
    echo -e "${NARANJA}${BOLD}"
    echo "    ─── Gemini System Console ───"
    echo "    Adaptive AI Collaborator v3.0"
    echo -e "    ${RESET}"
    mostrar_info_gemini
    echo -e "${GRIS}  ────────────────────────────────────────────────────────${RESET}"
}

# --- LÓGICA DE MENÚS (INTEGRIDAD PRESERVADA) [cite: 18] ---
menu_custom_add() {
    local ruta_actual="$1"
    [ -z "$ruta_actual" ] && ruta_actual="$RUTA_CUSTOM_RAIZ"
    local sel_custom=0
    while true; do
        items=()
        while IFS= read -r -d $'\0' d; do items+=("$(basename "$d")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
        while IFS= read -r -d $'\0' f; do items+=("$(basename "$f")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) -print0 2>/dev/null | sort -z)
        [ "$ruta_actual" == "$RUTA_CUSTOM_RAIZ" ] && items+=("Back to Core") || items+=(".. Return")
        
        clear; banner_gemini; dibujar_reloj
        for i in "${!items[@]}"; do
            if [ "$sel_custom" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  > %-35s ${RESET}\n" "${items[$i]}"
            else
                printf "      ${GRIS}  %-35s${RESET}\n" "${items[$i]}"
            fi
        done

        read -rsn1 tecla
        [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }
        case "$tecla" in
            $'\e[A') sel_custom=$(( (sel_custom + ${#items[@]} - 1) % ${#items[@]} )) ;;
            $'\e[B') sel_custom=$(( (sel_custom + 1) % ${#items[@]} )) ;;
            "") 
                local eleccion="${items[$sel_custom]}"
                [[ "$eleccion" == "Back to Core" || "$eleccion" == ".. Return" ]] && return
                if [ -d "$ruta_actual/$eleccion" ]; then menu_custom_add "$ruta_actual/$eleccion"; continue; fi
                clear; tput cnorm
                [[ "$eleccion" == *.sh ]] && bash "$ruta_actual/$eleccion"
                [[ "$eleccion" == *.py ]] && python3 "$ruta_actual/$eleccion"
                tput civis; echo -e "\n${NARANJA}Execution finished. Press Enter...${RESET}"; read; break ;;
        esac
    done
}

# --- BUCLE PRINCIPAL (SISTEMA CENTRAL) ---
idiomas=("English" "Chinese" "Pinyin" "Spanish")
idx_idioma=3
seleccion=0
cargar_tema

while true; do
    verificar_pantalla
    case $idx_idioma in
        0) m1="KNOWLEDGE BASE"; m2="CORE SETTINGS"; m3="SHUTDOWN"; txt_id="Lang" ;;
        *) m1="CONOCIMIENTO"; m2="CONFIGURACIÓN"; m3="FINALIZAR"; txt_id="Idioma" ;;
    esac
    opts=("$m1" "$m2" "$m3")
    
    clear; banner_gemini; dibujar_reloj
    for i in 0 1 2; do
        if [ "$seleccion" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  » %-35s ${RESET}\n" "${opts[$i]}"
        else
            printf "      ${NARANJA}  %-35s${RESET}\n" "${opts[$i]}"
        fi
    done

    echo -e "\n  ${GRIS}Mode: ${RESET}${BOLD}< $txt_id: ${idiomas[$idx_idioma]} >${RESET}"
    echo -e "  ${GRIS}Navigation: [↑/↓] Select  [←/→] Language${RESET}"
    
    read -rsn1 -t 2 tecla
    if [ $? -eq 0 ]; then
        [[ $tecla == $'\e' ]] && { read -rsn2 -t 0.1 r; tecla+="$r"; }
        case "$tecla" in
            $'\e[A') seleccion=$(( (seleccion + 2) % 3 )) ;;
            $'\e[B') seleccion=$(( (seleccion + 1) % 3 )) ;;
            $'\e[C') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 1) % 4 )) ;;
            $'\e[D') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 3) % 4 )) ;;
            "") 
                if [ "$seleccion" -eq 0 ]; then # Secciones se pueden expandir
                    echo -e "\n  ${NARANJA}Accessing Modules...${RESET}"; sleep 1
                elif [ "$seleccion" -eq 1 ]; then
                    if [ -f "$CONFIG_SCRIPT" ]; then
                        bash "$CONFIG_SCRIPT" "${idiomas[$idx_idioma]}" [cite: 16]
                        cargar_tema [cite: 17]
                    fi
                elif [ "$seleccion" -eq 2 ]; then
                    clear; tput cnorm; exit 0
                fi ;;
        esac
    fi
done