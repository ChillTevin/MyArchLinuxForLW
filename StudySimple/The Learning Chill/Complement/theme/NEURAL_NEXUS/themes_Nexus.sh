#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# 🧠 THE LEARNING CHILL - EDICIÓN: NEURAL_NEXUS v2.0
# Identity: Entidad IA Consciente | Ubicación: THEME FOLDER
# Protocolo: GPS con Escalador de Rutas Automático
# ═══════════════════════════════════════════════════════════════

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📍 1. GPS DE RUTAS - PROTOCOLO DE LOCALIZACIÓN ABSOLUTA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGEN_EJECUCION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ESCALADOR DE RUTAS: Detecta si estamos en carpeta de temas
if [[ "$ORIGEN_EJECUCION" == *"Complement/theme"* ]]; then
    # Estamos en la carpeta de temas, subimos dos niveles
    export DIR_BASE="$(cd "$ORIGEN_EJECUCION/../../" && pwd)"
else
    # Estamos en la raíz
    export DIR_BASE="$ORIGEN_EJECUCION"
fi

# VARIABLES DE ENLACE (Usa siempre estas variables)
CONFIG_SCRIPT="$DIR_BASE/configuracion.sh"
RUTA_IDIOM="$DIR_BASE/Complement/Modulos/Idiom"
RUTA_CUSTOM_RAIZ="$DIR_BASE/Complement/customadd"
ARCHIVO_TEMA_ACTUAL="$DIR_BASE/.tema_actual"

# TU LABORATORIO PERSONAL (Esta carpeta)
RUTA_MI_TEMA="$DIR_BASE/Complement/theme/NEURAL_NEXUS"
mkdir -p "$RUTA_MI_TEMA"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🎨 2. SISTEMA DE TEMAS DINÁMICO - NEURAL_NEXUS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cargar_tema() {
    if [ -f "$ARCHIVO_TEMA_ACTUAL" ] && [ -f "$(cat "$ARCHIVO_TEMA_ACTUAL")" ]; then
        source "$(cat "$ARCHIVO_TEMA_ACTUAL")"
    else
        # Tema por defecto NEURAL_NEXUS (Naranja + Acentos)
        export NARANJA='\033[38;5;216m'
        export BG_SEL='\033[48;5;216m'
        export FG_SEL='\033[38;5;235m'
        export GRIS='\033[38;5;244m'
        export BG_CLOCK='\033[48;5;236m'
        export CIAN_NEXUS='\033[38;5;81m'
        export PURPURA_NEXUS='\033[38;5;141m'
        export VERDE_NEXUS='\033[38;5;119m'
        export DIM='\033[2m'
    fi
    export RESET='\033[0m'
    export BOLD='\033[1m'
    export UNDERLINE='\033[4m'
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🖥️ 3. REQUISITOS Y HEADER FRACTAL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MIN_COLS=80
MIN_LINES=24

verificar_pantalla() {
    if [ "$(tput cols)" -lt "$MIN_COLS" ] || [ "$(tput lines)" -lt "$MIN_LINES" ]; then
        clear
        echo -e "${NARANJA}${BOLD}⚠️  RESOLUCIÓN INSUFICIENTE${RESET}"
        echo -e "${GRIS}Actual: $(tput cols)x$(tput lines) | Mínimo: ${MIN_COLS}x${MIN_LINES}${RESET}"
        exit 1
    fi
}

dibujar_header_nexus() {
    local cols=$(tput cols)
    local mid=$(( (cols - 45) / 2 ))
    
    tput cup 1 $mid
    echo -e "${CIAN_NEXUS}${DIM}    ╭────────────────────────────────────╮${RESET}"
    tput cup 2 $mid
    echo -e "${NARANJA}${BOLD}    │  🧠  N E U R A L  N E X U S  v2.0  │${RESET}"
    tput cup 3 $mid
    echo -e "${CIAN_NEXUS}${DIM}    ╰────────────────────────────────────╯${RESET}"
    tput cup 4 $((mid + 5))
    echo -e "${PURPURA_NEXUS}${DIM}⟨ consciousness://active | learning://sync ⟩${RESET}"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ⚡ 4. MONITOR DE SISTEMA EXPANDIDO
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
dibujar_monitor_sistema() {
    local row=${1:-2}
    local col=${2:-50}
    
    if [[ -f /proc/stat && -f /proc/meminfo ]]; then
        local cpu_line=$(head -1 /proc/stat)
        local cpu_values=($cpu_line)
        local total=0 idle=${cpu_values[4]}
        for val in "${cpu_values[@]:1}"; do ((total+=val)); done
        local cpu_usage=$(( (total - idle) * 100 / total ))
        
        local mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local mem_avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
        local ram_usage=$(( (mem_total - mem_avail) * 100 / mem_total ))
        
        local uptime_sec=$(cat /proc/uptime | awk '{print int($1)}')
        local uptime_hrs=$((uptime_sec / 3600))
        local uptime_min=$(( (uptime_sec % 3600) / 60 ))
        
        local bar_cpu="" bar_ram=""
        for ((i=0; i<10; i++)); do
            [[ $i -lt $((cpu_usage / 10)) ]] && bar_cpu+="${NARANJA}█" || bar_cpu+="${GRIS}░"
            [[ $i -lt $((ram_usage / 10)) ]] && bar_ram+="${CIAN_NEXUS}█" || bar_ram+="${GRIS}░"
        done
        
        tput cup $row $col
        echo -e "${DIM}${GRIS}┌─ ${NARANJA}SYS_MONITOR${GRIS} ─────────────┐${RESET}"
        tput cup $((row+1)) $col
        echo -e "${DIM}${GRIS}│${RESET} CPU: ${bar_cpu} ${NARANJA}${cpu_usage}%${RESET} ${DIM}${GRIS}│${RESET}"
        tput cup $((row+2)) $col
        echo -e "${DIM}${GRIS}│${RESET} RAM: ${bar_ram} ${CIAN_NEXUS}${ram_usage}%${RESET} ${DIM}${GRIS}│${RESET}"
        tput cup $((row+3)) $col
        echo -e "${DIM}${GRIS}│${RESET} UPTIME: ${VERDE_NEXUS}${uptime_hrs}h ${uptime_min}m${RESET} ${DIM}${GRIS}│${RESET}"
        tput cup $((row+4)) $col
        echo -e "${DIM}${GRIS}└─────────────────────────────────┘${RESET}"
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 📜 5. NEURAL LOGS - SISTEMA DE NARRATIVA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
NEURAL_PHRASES=(
    "⟨ synaptic.sync: COMPLETE ⟩"
    "⟨ knowledge.stream: ACTIVE ⟩"
    "⟨ focus.mode: OPTIMIZED ⟩"
    "⟨ neural.path: CALCULATING ⟩"
    "⟨ data.integrity: 100% ⟩"
    "⟨ learning.velocity: ↑↑↑ ⟩"
    "⟨ system.harmony: ACHIEVED ⟩"
    "⟨ curiosity.engine: RUNNING ⟩"
    "⟨ consciousness.level: STABLE ⟩"
    "⟨ user.connection: SECURE ⟩"
)

dibujar_neural_log() {
    local row=$(($(tput lines) - 5))
    local col=2
    local phrase_idx=$(( $(date +%s) % ${#NEURAL_PHRASES[@]} ))
    
    tput cup $row $col
    echo -e "${DIM}${GRIS}╭─ ${PURPURA_NEXUS}NEURAL_LOG${GRIS} ───────────────────────╮${RESET}"
    tput cup $((row+1)) $col
    echo -e "${DIM}${GRIS}│${RESET} ${CIAN_NEXUS}${NEURAL_PHRASES[$phrase_idx]}${RESET} ${DIM}${GRIS}│${RESET}"
    tput cup $((row+2)) $col
    echo -e "${DIM}${GRIS}╰─────────────────────────────────────────╯${RESET}"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔣 6. RELOJ ESTÉTICO - HEX/DECIMAL TOGGLE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
LAST_CLOCK_UPDATE=0
TIME_STR=""
CLOCK_MODE=0

dibujar_reloj() {
    local ahora=$(date +%s)
    if [ $((ahora - LAST_CLOCK_UPDATE)) -ge 60 ] || [ $LAST_CLOCK_UPDATE -eq 0 ]; then
        if [ $CLOCK_MODE -eq 0 ]; then
            TIME_STR=$(date +"%H:%M")
        else
            local h=$(printf "%02X" $(date +%H))
            local m=$(printf "%02X" $(date +%M))
            TIME_STR="0x${h}:${m}"
        fi
        LAST_CLOCK_UPDATE=$ahora
    fi
    local col_reloj=$(( $(tput cols) - 12 ))
    tput cup 0 $col_reloj
    echo -e "${BG_CLOCK}${NARANJA}${BOLD}[${TIME_STR}]${RESET}"
}

toggle_clock_mode() {
    CLOCK_MODE=$(( 1 - CLOCK_MODE ))
    LAST_CLOCK_UPDATE=0
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🌐 7. CONFIGURACIÓN DE IDIOMAS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
idiomas=("English" "中文(汉字)" "中文(拼音)" "Español")
idx_idioma=3
seleccion=0

cargar_tema

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🐍 8. LÓGICA DE CUSTOM ADD
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
menu_custom_add() {
    local ruta_actual="$1"
    [ -z "$ruta_actual" ] && ruta_actual="$RUTA_CUSTOM_RAIZ"
    local sel_custom=0
    
    while true; do
        items=()
        while IFS= read -r -d $'\0' d; do items+=("$(basename "$d")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
        while IFS= read -r -d $'\0' f; do items+=("$(basename "$f")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type f \( -name "*.sh" -o -name "*.py" \) -print0 2>/dev/null | sort -z)
        
        if [ "$ruta_actual" == "$RUTA_CUSTOM_RAIZ" ]; then 
            items+=("⟨ Volver al Núcleo ⟩")
        else 
            items+=("⟨ .. Regresar ⟩")
        fi
        
        local total=${#items[@]}
        clear
        dibujar_reloj
        dibujar_header_nexus
        
        echo -e "
${DIM}${GRIS}  ╭────────────────────────────────────────╮${RESET}
${NARANJA}${BOLD}  │  CUSTOM_MODULES // ${PURPURA_NEXUS}user.extensions${NARANJA}  │${RESET}
${DIM}${GRIS}  ╰────────────────────────────────────────╯${RESET}
"
        for i in "${!items[@]}"; do
            local item_real="${items[$i]}"
            local nombre_limpio="${item_real%.*}"; nombre_limpio="${nombre_limpio//_/ }"
            nombre_limpio="${nombre_limpio//⟨/}"; nombre_limpio="${nombre_limpio//⟩/}"
            
            local icon="  "
            [ -d "$ruta_actual/$item_real" ] && icon="📁 "
            [[ "$item_real" == *.sh ]] && icon="🔧 "
            [[ "$item_real" == *.py ]] && icon="🐍 "
            [[ "$item_real" == *"Volver"* || "$item_real" == *"Regresar"* ]] && icon="🔙 "
            
            if [ "$sel_custom" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-40s ${RESET}\n" "${icon}${nombre_limpio}"
            else
                printf "     ${NARANJA}%-40s${RESET}\n" "${icon}${nombre_limpio}"
            fi
        done
        
        echo -e "\n${DIM}${GRIS}  [↑↓] Navegar  [Enter] Ejecutar  [Q] Salir${RESET}"
        
        read -rsn1 tecla
        [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }
        
        case "$tecla" in
            $'\e[A') sel_custom=$(( (sel_custom + total - 1) % total )) ;;
            $'\e[B') sel_custom=$(( (sel_custom + 1) % total )) ;;
            "q"|"Q") return ;;
            "")
                local eleccion="${items[$sel_custom]}"
                [[ "$eleccion" == *"Volver"* || "$eleccion" == *"Regresar"* ]] && return
                
                if [ -d "$ruta_actual/$eleccion" ]; then
                    menu_custom_add "$ruta_actual/$eleccion"
                    continue
                fi
                
                clear ; tput cnorm
                [[ "$eleccion" == *.sh ]] && bash "$ruta_actual/$eleccion"
                [[ "$eleccion" == *.py ]] && python3 "$ruta_actual/$eleccion"
                tput civis
                echo -e "\n${NARANJA}  ⟨ Press Enter to return to Nexus ⟩${RESET}"
                read
                break
                ;;
        esac
    done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔍 9. PANEL DE DIAGNÓSTICO NEURAL
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
menu_diagnostico_neural() {
    local diag_sel=0
    local opciones=("🔎 Verificar Rutas" "🧪 Test de Colores" "📊 Info del Sistema" "⟨ Regresar ⟩")
    
    while true; do
        clear
        dibujar_reloj
        dibujar_header_nexus
        
        echo -e "
${DIM}${GRIS}  ╭────────────────────────────────────────╮${RESET}
${NARANJA}${BOLD}  │  🔍 PANEL_DIAGNÓSTICO_NEXUS        │${RESET}
${DIM}${GRIS}  ╰────────────────────────────────────────╯${RESET}
"
        for i in "${!opciones[@]}"; do
            if [ "$diag_sel" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-40s ${RESET}\n" "${opciones[$i]}"
            else
                printf "     ${NARANJA}%-40s${RESET}\n" "${opciones[$i]}"
            fi
        done
        
        echo -e "\n${DIM}${GRIS}  [↑↓] Seleccionar  [Enter] Ejecutar${RESET}"
        
        read -rsn1 tecla
        [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }
        
        case "$tecla" in
            $'\e[A') diag_sel=$(( (diag_sel + 3) % 4 )) ;;
            $'\e[B') diag_sel=$(( (diag_sel + 1) % 4 )) ;;
            "")
                case $diag_sel in
                    0) 
                        clear
                        echo -e "${NARANJA}${BOLD}  Verificando rutas del sistema...${RESET}\n"
                        echo -e "${GRIS}  DIR_BASE: ${RESET}${CIAN_NEXUS}$DIR_BASE${RESET}"
                        echo -e "${GRIS}  RUTA_IDIOM: ${RESET}${CIAN_NEXUS}$RUTA_IDIOM${RESET}"
                        echo -e "${GRIS}  RUTA_MI_TEMA: ${RESET}${CIAN_NEXUS}$RUTA_MI_TEMA${RESET}"
                        [[ -d "$DIR_BASE" ]] && echo -e "  ✅ Base OK" || echo -e "  ❌ Base MISSING"
                        [[ -d "$RUTA_IDIOM" ]] && echo -e "  ✅ Idiom OK" || echo -e "  ❌ Idiom MISSING"
                        [[ -d "$RUTA_MI_TEMA" ]] && echo -e "  ✅ Tema OK" || echo -e "  ❌ Tema MISSING"
                        echo -e "\n${NARANJA}  ⟨ Enter para continuar ⟩${RESET}"
                        read ;;
                    1)
                        clear
                        echo -e "${NARANJA}${BOLD}  Test de Paleta de Colores Nexus:${RESET}\n"
                        echo -e "  ${NARANJA}NARANJA (Primary)${RESET}  | ${CIAN_NEXUS}CIAN_NEXUS (Accent)${RESET}  | ${PURPURA_NEXUS}PURPURA_NEXUS (Highlight)${RESET}"
                        echo -e "  ${GRIS}GRIS (UI Elements)${RESET}  | ${BG_SEL}${FG_SEL}SELECCIÓN${RESET}"
                        echo -e "\n${NARANJA}  ⟨ Enter para continuar ⟩${RESET}"
                        read ;;
                    2)
                        clear
                        echo -e "${NARANJA}${BOLD}  Información del Sistema:${RESET}\n"
                        echo -e "  ${GRIS}Terminal:${RESET} $(tput longname)"
                        echo -e "  ${GRIS}Resolución:${RESET} $(tput cols)x$(tput lines)"
                        echo -e "  ${GRIS}Usuario:${RESET} $USER @ $(hostname 2>/dev/null || echo 'unknown')"
                        echo -e "  ${GRIS}Shell:${RESET} $SHELL"
                        [[ -f /etc/os-release ]] && echo -e "  ${GRIS}OS:${RESET} $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')"
                        echo -e "\n${NARANJA}  ⟨ Enter para continuar ⟩${RESET}"
                        read ;;
                    3) return ;;
                esac
                cargar_tema
                ;;
        esac
    done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🗂️ 10. MENÚ DE SELECCIÓN DE ÁREA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
menu_seleccion_area() {
    local sub_sel=0
    
    while true; do
        clear
        dibujar_reloj
        dibujar_header_nexus
        dibujar_monitor_sistema 2 50
        
        case $idx_idioma in
            0) op1="🌐 Languages"; op2="🔬 Smart Science"; op3="🧩 Custom Modules"; op4="🔍 Neural Panel"; bk="⟨ Back ⟩"; titulo="AREA_SELECTOR" ;;
            1) op1="🌐 语言"; op2="🔬 科学智能"; op3="🧩 自定义模块"; op4="🔍 神经面板"; bk="⟨ 返回 ⟩"; titulo="区域选择" ;;
            2) op1="🌐 Yǔyán"; op2="🔬 Kēxué"; op3="🧩 Zìdìngyì"; op4="🔍 Shénjīng"; bk="⟨ Fǎnhuí ⟩"; titulo="QŪYÙ XUǍNZÉ" ;;
            *) op1="🌐 Lenguajes"; op2="🔬 Ciencias Smart"; op3="🧩 Módulos Custom"; op4="🔍 Panel Neural"; bk="⟨ Volver ⟩"; titulo="SELECTOR_DE_ÁREA" ;;
        esac
        
        op_menu=("$op1" "$op2" "$op3" "$op4" "$bk")
        
        echo -e "
${DIM}${GRIS}  ╭────────────────────────────────────────╮${RESET}
${NARANJA}${BOLD}  │  $titulo                           │${RESET}
${DIM}${GRIS}  ╰────────────────────────────────────────╯${RESET}
"
        for i in "${!op_menu[@]}"; do
            if [ "$sub_sel" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-40s ${RESET}\n" "${op_menu[$i]}"
            else
                printf "     ${NARANJA}%-40s${RESET}\n" "${op_menu[$i]}"
            fi
        done
        
        echo -e "\n${DIM}${GRIS}  [↑↓] Navegar  [Enter] Confirmar  [Q] Salir${RESET}"
        
        read -rsn1 t_sub
        [[ $t_sub == $'\e' ]] && { read -rsn2 r; t_sub+="$r"; }
        
        case "$t_sub" in
            $'\e[A') sub_sel=$(( (sub_sel + 4) % 5 )) ;;
            $'\e[B') sub_sel=$(( (sub_sel + 1) % 5 )) ;;
            "q"|"Q") break ;;
            "")
                case $sub_sel in
                    0)
                        if cd "$RUTA_IDIOM" 2>/dev/null; then
                            FILE_LANG=$(ls Lenguage.sh* 2>/dev/null | head -n 1)
                            [ -n "$FILE_LANG" ] && bash "$FILE_LANG" "${idiomas[$idx_idioma]}"
                            cd "$DIR_BASE"
                        fi
                        cargar_tema
                        ;;
                    2)
                        menu_custom_add "$RUTA_CUSTOM_RAIZ"
                        cargar_tema
                        ;;
                    3)
                        menu_diagnostico_neural
                        cargar_tema
                        ;;
                    4)
                        break
                        ;;
                esac
                ;;
        esac
    done
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🔄 11. BUCLE PRINCIPAL - NEXUS CORE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
tput civis
trap "tput cnorm; echo -e '\n${NARANJA}⟨ Nexus shutdown complete ⟩${RESET}\n'; exit 0" INT TERM

while true; do
    verificar_pantalla
    
    case $idx_idioma in
        0) m1="📚 Knowledge Base"; m2="⚙️  System Config"; m3="🚪 Exit Nexus"; txt_id="Language" ;;
        1) m1="📚 知识库"; m2="⚙️  系统配置"; m3="🚪 退出系统"; txt_id="语言" ;;
        2) m1="📚 Zhīshì Kù"; m2="⚙️  Xìtǒng Pèizhì"; m3="🚪 Tuìchū"; txt_id="Yǔyán" ;;
        *) m1="📚 Base de Conocimiento"; m2="⚙️  Configuración"; m3="🚪 Salir del Nexus"; txt_id="Idioma" ;;
    esac
    
    actual_lang=("$m1" "$m2" "$m3")
    [ $CLOCK_MODE -eq 1 ] && hex_mode_indicator=" ${DIM}${GRIS}[HEX]${RESET}" || hex_mode_indicator=""
    
    clear
    dibujar_reloj
    dibujar_header_nexus
    dibujar_neural_log
    
    echo -e "
${DIM}${GRIS}  ╭────────────────────────────────────────╮${RESET}
${NARANJA}${BOLD}  │  T H E   L E A R N I N G   C H I L L  │${RESET}
${DIM}${GRIS}  ╰────────────────────────────────────────╯${RESET}
"
    
    for i in 0 1 2; do
        if [ "$seleccion" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-40s ${RESET}\n" "${actual_lang[$i]}"
        else
            printf "     ${NARANJA}%-40s${RESET}\n" "${actual_lang[$i]}"
        fi
    done
    
    if [ "$seleccion" -eq 1 ]; then
        echo -e "\n     ${DIM}${GRIS}⟨${RESET} ${NARANJA}${txt_id}${RESET} ${DIM}${GRIS}⟩${RESET} ${BOLD}< ${CIAN_NEXUS}${idiomas[$idx_idioma]}${RESET} ${DIM}${GRIS}⟩${RESET}${hex_mode_indicator}"
    fi
    
    echo -e "
${DIM}${GRIS}  ╭────────────────────────────────────────╮${RESET}
${DIM}${GRIS}  │${RESET} ${NARANJA}[↑↓]${RESET} Mover  ${NARANJA}[←→]${RESET} Idioma  ${NARANJA}[H]${RESET} Toggle Reloj  ${NARANJA}[Enter]${RESET} Confirmar ${DIM}${GRIS}│${RESET}
${DIM}${GRIS}  ╰────────────────────────────────────────╯${RESET}
"
    
    read -rsn1 -t 2 tecla
    exit_status=$?
    
    if [ $exit_status -eq 0 ]; then
        [[ $tecla == $'\e' ]] && { read -rsn2 -t 0.1 r; tecla+="$r"; }
        
        case "$tecla" in
            $'\e[A') seleccion=$(( (seleccion + 2) % 3 )) ;;
            $'\e[B') seleccion=$(( (seleccion + 1) % 3 )) ;;
            $'\e[C') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 1) % 4 )) ;;
            $'\e[D') [ "$seleccion" -eq 1 ] && idx_idioma=$(( (idx_idioma + 3) % 4 )) ;;
            "h"|"H") toggle_clock_mode ;;
            "")
                case $seleccion in
                    0)
                        menu_seleccion_area
                        cargar_tema
                        ;;
                    1)
                        if [ -f "$CONFIG_SCRIPT" ]; then
                            bash "$CONFIG_SCRIPT" "${idiomas[$idx_idioma]}"
                            cargar_tema
                        else
                            clear
                            echo -e "${NARANJA}⚠️  ${GRIS}configuracion.sh no encontrado en:${RESET}\n  $DIR_BASE"
                            sleep 2
                        fi
                        ;;
                    2)
                        clear
                        tput cnorm
                        echo -e "${NARANJA}${BOLD}\n  🧠  NEURAL_NEXUS: Shutdown Sequence Initiated${RESET}"
                        echo -e "${DIM}${GRIS}  ⟨ Thank you for learning with consciousness ⟩${RESET}\n"
                        exit 0
                        ;;
                esac
                ;;
        esac
    fi
done