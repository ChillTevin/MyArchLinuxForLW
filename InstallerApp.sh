#!/bin/bash

################################################################################
# ARCH LINUX APPLICATION INSTALLER - CON CONFIRMACIÓN DE DEPENDENCIAS
################################################################################

set -o pipefail

readonly VERSION="4.0-interactive"
readonly CONFIG_DIR="${HOME}/.config/arch-academic-installer"
readonly LOG_FILE="${CONFIG_DIR}/install.log"

mkdir -p "$CONFIG_DIR" 2>/dev/null || true

#===============================================================================
# COLORES
#===============================================================================

C_RESET='\033[0m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_NAVY='\033[38;5;17m'
C_SLATE='\033[38;5;59m'
C_ACADEMY='\033[38;5;31m'
C_GOLD='\033[38;5;136m'
C_BURGUNDY='\033[38;5;88m'
C_FOREST='\033[38;5;22m'
C_ORANGE='\033[38;5;208m'
C_RED='\033[38;5;196m'
C_GRAY_LIGHT='\033[38;5;250m'
C_GRAY='\033[38;5;245m'

BG_SELECT='\033[48;5;234m'

#===============================================================================
# CARACTERES
#===============================================================================

U_TL='┌'; U_TR='┐'; U_BL='└'; U_BR='┘'
U_H='─'; U_V='│'; U_VR='├'; U_VL='┤'

I_CHECK='✓'
I_BULLET='•'
I_ARROW='▶'
I_CIRCLE='○'
I_HOURGLASS='⏳'
I_WARNING='⚠'
I_QUESTION='?'
I_SPINNER=('◐' '◓' '◑' '◒')

#===============================================================================
# CATÁLOGO CORREGIDO (8 obligatorias + 5 académicas)
#===============================================================================

declare -A APPS APP_CAT APP_DESC APP_METHOD APP_CMD APP_URL APP_DEPS

define_app() {
    local idx=$1
    APPS[$idx]=$2
    APP_CAT[$idx]=$3
    APP_DESC[$idx]=$4
    APP_METHOD[$idx]=$5
    APP_CMD[$idx]=$6
    APP_URL[$idx]=$7
    APP_DEPS[$idx]="${8:-}"
}

# 8 OBLIGATORIAS (corregidas)
define_app 0 "Obsidian" "Knowledge Management" \
    "Sistema de notas con grafos de conocimiento bidireccionales. Soporta Markdown, plugins, temas personalizados y sincronización cifrada." \
    "flatpak" \
    "flatpak install -y flathub md.obsidian.Obsidian" \
    "https://obsidian.md" \
    "flatpak"

define_app 1 "Stacer" "System Administration" \
    "Suite integrada de administración de sistema. Monitorización de recursos, gestión de procesos, limpieza de archivos y optimización." \
    "aur" \
    "yay -S --noconfirm stacer" \
    "https://github.com/oguzhaninan/Stacer" \
    "yay"

define_app 2 "OnlyOffice" "Productivity Suite" \
    "Suite ofimática completa con compatibilidad Microsoft Office. Incluye procesador de textos, hojas de cálculo y presentaciones." \
    "flatpak" \
    "flatpak install -y flathub org.onlyoffice.desktopeditors" \
    "https://www.onlyoffice.com" \
    "flatpak"

define_app 3 "Flatpak" "Package Management" \
    "Sistema de gestión de paquetes universal con sandboxing. Permite despliegue de aplicaciones independientes de la distribución." \
    "pacman" \
    "sudo pacman -S --noconfirm flatpak" \
    "https://flatpak.org" \
    ""

define_app 4 "WebCatalog" "Web Applications" \
    "Convierte sitios web en aplicaciones de escritorio nativas. Alternativa: se instalará como webapp si no está en repositorios." \
    "aur" \
    "yay -S --noconfirm webcatalog-appimage" \
    "https://webcatalog.io" \
    "yay"

define_app 5 "Brave Browser" "Internet Navigation" \
    "Navegador orientado a la privacidad con bloqueo nativo de publicidad, protección contra fingerprinting e integración Tor." \
    "aur" \
    "yay -S --noconfirm brave-bin" \
    "https://brave.com" \
    "yay"

define_app 6 "KDE Connect" "Device Integration" \
    "Infraestructura de integración entre estaciones de trabajo y dispositivos móviles. Transferencia segura de archivos y sincronización." \
    "pacman" \
    "sudo pacman -S --noconfirm kdeconnect" \
    "https://kdeconnect.kde.org" \
    ""

define_app 7 "TimeShift" "System Recovery" \
    "Sistema de snapshots con modelo de restauración temporal. Puntos de recuperación automáticos mediante Btrfs o rsync." \
    "aur" \
    "yay -S --noconfirm timeshift" \
    "https://github.com/linuxmint/timeshift" \
    "yay"

# 5 ACADÉMICAS (corregidas)
define_app 8 "Zotero" "Research Tools" \
    "Gestor de referencias bibliográficas. Organiza citas, genera bibliografías automáticas en múltiples formatos y extrae metadatos de PDFs." \
    "aur" \
    "yay -S --noconfirm zotero-bin" \
    "https://www.zotero.org" \
    "yay"

define_app 9 "Anki" "Education" \
    "Sistema de aprendizaje con tarjetas de repetición espaciada. Optimiza la memorización a largo plazo mediante algoritmos adaptativos." \
    "pacman" \
    "sudo pacman -S --noconfirm anki" \
    "https://apps.ankiweb.net" \
    ""

define_app 10 "TeX Live" "Typesetting" \
    "Distribución completa de LaTeX para composición tipográfica profesional. Instala el grupo completo de paquetes." \
    "pacman" \
    "sudo pacman -S --noconfirm texlive texlive-langspanish" \
    "https://tug.org/texlive/" \
    ""

define_app 11 "Joplin" "Note Taking" \
    "Aplicación de notas de código abierto con sincronización end-to-end encryption. Soporta Markdown y organización en cuadernos." \
    "aur" \
    "yay -S --noconfirm joplin-desktop" \
    "https://joplinapp.org" \
    "yay"

define_app 12 "RStudio" "Data Science" \
    "Entorno de desarrollo integrado para el lenguaje R. Editor de código, visualización de datos, gestión de paquetes y generación de informes reproducibles." \
    "aur" \
    "yay -S --noconfirm rstudio-desktop-bin" \
    "https://www.rstudio.com" \
    "yay"

TOTAL_APPS=${#APPS[@]}

#===============================================================================
# VARIABLES
#===============================================================================

SELECTED_INDEX=0
SCROLL_OFFSET=0
declare -A SELECTION_STATE
declare -A INSTALLED_CACHE
declare -A DEPENDENCIES_INSTALLED
TERMINAL_HEIGHT=0
TERMINAL_WIDTH=0
VISIBLE_ITEMS=0
NEEDS_REDRAW=true
IS_INSTALLING=false
LAST_ERROR=""
SKIP_ALL_DEPENDENCIES=false
AUTO_INSTALL_DEPENDENCIES=false

#===============================================================================
# FUNCIONES BÁSICAS
#===============================================================================

log_msg() { echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"; }
clear_screen() { printf '\033[2J\033[H'; }
hide_cursor() { printf '\033[?25l'; }
show_cursor() { printf '\033[?25h'; }
move_cursor() { printf '\033[%d;%dH' "$1" "$2"; }
clear_line() { printf '\033[2K'; }

get_terminal_size() {
    if command -v tput &>/dev/null; then
        TERMINAL_HEIGHT=$(tput lines)
        TERMINAL_WIDTH=$(tput cols)
    else
        read -r TERMINAL_HEIGHT TERMINAL_WIDTH < <(stty size 2>/dev/null || echo "24 80")
    fi
    [[ -z "$TERMINAL_HEIGHT" ]] && TERMINAL_HEIGHT=24
    [[ -z "$TERMINAL_WIDTH" ]] && TERMINAL_WIDTH=80
    
    VISIBLE_ITEMS=$((TERMINAL_HEIGHT - 12))
    [[ $VISIBLE_ITEMS -lt 3 ]] && VISIBLE_ITEMS=3
    [[ $VISIBLE_ITEMS -gt $TOTAL_APPS ]] && VISIBLE_ITEMS=$TOTAL_APPS
}

command_exists() { command -v "$1" &>/dev/null; }

cleanup() {
    show_cursor
    stty sane 2>/dev/null || true
    printf "${C_RESET}"
}

#===============================================================================
# CONFIRMACIÓN INTERACTIVA DE DEPENDENCIAS
#===============================================================================

ask_user() {
    local question="$1"
    local default="${2:-y}"
    
    show_cursor
    printf "\n  ${C_GOLD}${I_QUESTION} %s${C_RESET} " "$question"
    
    if $AUTO_INSTALL_DEPENDENCIES; then
        printf "${C_FOREST}[auto-yes]${C_RESET}\n"
        hide_cursor
        return 0
    fi
    
    if $SKIP_ALL_DEPENDENCIES; then
        printf "${C_GRAY}[auto-no]${C_RESET}\n"
        hide_cursor
        return 1
    fi
    
    local response
    read -r response
    
    # Si solo presionó enter, usar default
    [[ -z "$response" ]] && response="$default"
    
    hide_cursor
    
    case "${response,,}" in
        y|yes|s|si) return 0 ;;
        a|all) AUTO_INSTALL_DEPENDENCIES=true; return 0 ;;
        n|no) return 1 ;;
        s|skip) SKIP_ALL_DEPENDENCIES=true; return 1 ;;
        *) [[ "$default" == "y" ]] && return 0 || return 1 ;;
    esac
}

ensure_dependency() {
    local dep="$1"
    
    # Verificar cache
    [[ -n "${DEPENDENCIES_INSTALLED[$dep]:-}" ]] && return "${DEPENDENCIES_INSTALLED[$dep]}"
    
    if command_exists "$dep"; then
        DEPENDENCIES_INSTALLED[$dep]=0
        return 0
    fi
    
    printf "\n  ${C_ORANGE}${I_WARNING} Missing dependency: ${C_BOLD}%s${C_RESET}\n" "$dep"
    printf "  ${C_GRAY_LIGHT}This is required to install AUR/Flatpak packages.${C_RESET}\n\n"
    
    if ! ask_user "Install $dep now? [Y/n/a=all/s=skip]" "y"; then
        printf "  ${C_GRAY}Skipping $dep installation${C_RESET}\n\n"
        DEPENDENCIES_INSTALLED[$dep]=1
        return 1
    fi
    
    # Instalar según dependencia
    case "$dep" in
        yay)
            printf "  ${C_GRAY_LIGHT}Installing yay (AUR helper)...${C_RESET}\n"
            printf "  ${C_DIM}This requires: git, base-devel${C_RESET}\n\n"
            
            if ! ask_user "Proceed with yay installation? [Y/n]" "y"; then
                DEPENDENCIES_INSTALLED[$dep]=1
                return 1
            fi
            
            # Instalar dependencias de compilación
            printf "  ${C_GRAY_LIGHT}Installing build dependencies...${C_RESET}\n"
            if ! sudo pacman -S --needed --noconfirm git base-devel 2>&1 | tee -a "$LOG_FILE"; then
                printf "  ${C_RED}✗ Failed to install build dependencies${C_RESET}\n\n"
                DEPENDENCIES_INSTALLED[$dep]=1
                return 1
            fi
            
            # Clonar y compilar yay
            printf "  ${C_GRAY_LIGHT}Cloning yay repository...${C_RESET}\n"
            cd /tmp && rm -rf yay
            if ! git clone https://aur.archlinux.org/yay.git 2>&1 | tee -a "$LOG_FILE"; then
                printf "  ${C_RED}✗ Failed to clone yay${C_RESET}\n\n"
                DEPENDENCIES_INSTALLED[$dep]=1
                return 1
            fi
            
            cd yay
            printf "  ${C_GRAY_LIGHT}Building yay (this may take a minute)...${C_RESET}\n"
            if makepkg -si --noconfirm 2>&1 | tee -a "$LOG_FILE"; then
                printf "  ${C_FOREST}${I_CHECK} yay installed successfully${C_RESET}\n\n"
                DEPENDENCIES_INSTALLED[$dep]=0
                cd .. && rm -rf yay
                return 0
            else
                printf "  ${C_RED}✗ Failed to build yay${C_RESET}\n"
                printf "  ${C_GRAY_LIGHT}Try manually: cd /tmp/yay && makepkg -si${C_RESET}\n\n"
                DEPENDENCIES_INSTALLED[$dep]=1
                return 1
            fi
            ;;
            
        flatpak)
            printf "  ${C_GRAY_LIGHT}Installing flatpak...${C_RESET}\n"
            
            if sudo pacman -S --noconfirm flatpak 2>&1 | tee -a "$LOG_FILE"; then
                printf "  ${C_FOREST}${I_CHECK} flatpak installed${C_RESET}\n"
                printf "  ${C_GRAY_LIGHT}Adding flathub repository...${C_RESET}\n"
                
                if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>&1 | tee -a "$LOG_FILE"; then
                    printf "  ${C_FOREST}${I_CHECK} flathub repository added${C_RESET}\n\n"
                    DEPENDENCIES_INSTALLED[$dep]=0
                    return 0
                else
                    printf "  ${C_ORANGE}${I_WARNING} Could not add flathub automatically${C_RESET}\n"
                    printf "  ${C_GRAY_LIGHT}Run manually: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo${C_RESET}\n\n"
                    DEPENDENCIES_INSTALLED[$dep]=0  # flatpak sí está instalado
                    return 0
                fi
            else
                printf "  ${C_RED}✗ Failed to install flatpak${C_RESET}\n\n"
                DEPENDENCIES_INSTALLED[$dep]=1
                return 1
            fi
            ;;
            
        *)
            printf "  ${C_RED}✗ Unknown dependency: $dep${C_RESET}\n\n"
            DEPENDENCIES_INSTALLED[$dep]=1
            return 1
            ;;
    esac
}

check_installed() {
    local name="${1:-}"
    local method="${2:-}"
    
    [[ -z "$name" ]] && return 1
    
    if [[ "${DEMO_MODE:-0}" == "1" ]]; then
        return 1
    fi
    
    local pkg=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    
    case "$method" in
        pacman|aur)
            pacman -Q "$pkg" &>/dev/null || \
            pacman -Q "${pkg}-bin" &>/dev/null || \
            pacman -Q "${pkg}-git" &>/dev/null || \
            pacman -Q "${pkg}-appimage" &>/dev/null
            ;;
        flatpak)
            command_exists flatpak && \
            flatpak list --app 2>/dev/null | grep -qi "$pkg"
            ;;
        *) 
            return 1 
            ;;
    esac
}

update_cache() {
    INSTALLED_CACHE=()
    local i
    for i in "${!APPS[@]}"; do
        if check_installed "${APPS[$i]}" "${APP_METHOD[$i]}" 2>/dev/null; then
            INSTALLED_CACHE[$i]=1
        else
            INSTALLED_CACHE[$i]=0
        fi
    done
}

#===============================================================================
# RENDERIZADO (simplificado para espacio)
#===============================================================================

draw_interface() {
    get_terminal_size
    update_cache
    clear_screen
    
    # Header
    move_cursor 1 1
    printf "${C_NAVY}${C_BOLD}%${TERMINAL_WIDTH}s${C_RESET}\n" | tr ' ' '='
    move_cursor 2 1
    local title="ARCH LINUX ACADEMIC SOFTWARE REPOSITORY"
    local padding=$(( (TERMINAL_WIDTH - ${#title}) / 2 ))
    printf "%${padding}s${C_NAVY}${C_BOLD}${title}${C_RESET}\n" ""
    move_cursor 3 1
    printf "${C_GRAY_DARK}%${TERMINAL_WIDTH}s${C_RESET}\n" | tr ' ' '-'
    
    # Lista
    local start=$SCROLL_OFFSET
    local end=$((SCROLL_OFFSET + VISIBLE_ITEMS))
    [[ $end -gt $TOTAL_APPS ]] && end=$TOTAL_APPS
    
    local line=5
    move_cursor $line 2
    printf "${C_GRAY_LIGHT}[Catalog: %d items | Select with SPACE, Install with ENTER]${C_RESET}\n" "$TOTAL_APPS"
    ((line++))
    
    for ((i=start; i<end; i++)); do
        move_cursor $line 2
        clear_line
        
        local name="${APPS[$i]}"
        local installed=${INSTALLED_CACHE[$i]:-0}
        local selected=${SELECTION_STATE[$i]:-0}
        
        [[ ${#name} -gt 28 ]] && name="${name:0:26}.."
        
        if [[ $i -eq $SELECTED_INDEX ]]; then
            printf "${C_GOLD}${I_ARROW}${C_RESET} ${BG_SELECT}"
        else
            printf "  "
        fi
        
        printf "${C_GRAY}%2d.${C_RESET} " "$((i+1))"
        
        if [[ $selected -eq 1 ]]; then
            printf "${C_GOLD}${C_BOLD}%-28s${C_RESET}" "$name"
        elif [[ $installed -eq 1 ]]; then
            printf "${C_FOREST}%-28s${C_RESET}" "$name"
        else
            printf "${C_SLATE}%-28s${C_RESET}" "$name"
        fi
        
        printf " ${C_GRAY_LIGHT}[%s]${C_RESET}" "${APP_METHOD[$i]}"
        
        printf "  "
        [[ $selected -eq 1 ]] && printf "${C_GOLD}${I_CHECK}${C_RESET}" || printf " "
        printf " "
        [[ $installed -eq 1 ]] && printf "${C_FOREST}${I_BULLET}${C_RESET}" || printf "${C_GRAY}${I_CIRCLE}${C_RESET}"
        
        [[ $i -eq $SELECTED_INDEX ]] && printf "${C_RESET}"
        
        ((line++))
    done
    
    while [[ $line -lt $((TERMINAL_HEIGHT - 6)) ]]; do
        move_cursor $line 2
        clear_line
        ((line++))
    done
    
    # Preview
    local idx=$SELECTED_INDEX
    local y=$((TERMINAL_HEIGHT - 5))
    
    move_cursor $y 2
    printf "${C_NAVY}${U_VR}%$((TERMINAL_WIDTH - 4))s${U_VL}${C_RESET}\n" | tr ' ' "${U_H}"
    ((y++))
    move_cursor $y 2
    printf "${C_NAVY}${U_V}${C_RESET} ${C_ACADEMY}%s${C_RESET} %${C_GRAY_LIGHT}s${C_RESET}" "${APP_CAT[$idx]}" "[${APP_METHOD[$idx]}]"
    printf "%$((TERMINAL_WIDTH - ${#APP_CAT[$idx]} - 15))s ${C_NAVY}${U_V}${C_RESET}\n" ""
    ((y++))
    move_cursor $y 2
    printf "${C_NAVY}${U_V}${C_RESET} ${C_SLATE}%.$(($TERMINAL_WIDTH - 6))s${C_RESET}" "${APP_DESC[$idx]}"
    printf "%$((TERMINAL_WIDTH - ${#APP_DESC[$idx]} - 6))s ${C_NAVY}${U_V}${C_RESET}\n" ""
    ((y++))
    move_cursor $y 2
    printf "${C_NAVY}${U_VR}%$((TERMINAL_WIDTH - 4))s${U_VL}${C_RESET}\n" | tr ' ' "${U_H}"
    
    # Status
    y=$((TERMINAL_HEIGHT - 1))
    move_cursor $y 2
    
    local count=0
    for _ in "${!SELECTION_STATE[@]}"; do ((count++)); done
    
    if $IS_INSTALLING; then
        printf "${C_GOLD}${I_HOURGLASS} Installing %d package(s)...${C_RESET}" "$count"
    else
        printf "${C_GRAY_LIGHT}[%d/%d]${C_RESET} " "$((SELECTED_INDEX + 1))" "$TOTAL_APPS"
        if [[ $count -gt 0 ]]; then
            printf "${C_GOLD}%d selected - Press ENTER to install${C_RESET}" "$count"
        else
            printf "${C_GRAY}SPACE:select  ENTER:install  q:quit${C_RESET}"
        fi
    fi
    
    NEEDS_REDRAW=false
}

#===============================================================================
# NAVEGACIÓN
#===============================================================================

navigate_up() {
    $IS_INSTALLING && return
    [[ $SELECTED_INDEX -gt 0 ]] || return
    ((SELECTED_INDEX--))
    [[ $SELECTED_INDEX -lt $SCROLL_OFFSET ]] && SCROLL_OFFSET=$SELECTED_INDEX
    [[ $SCROLL_OFFSET -lt 0 ]] && SCROLL_OFFSET=0
    NEEDS_REDRAW=true
}

navigate_down() {
    $IS_INSTALLING && return
    [[ $SELECTED_INDEX -lt $((TOTAL_APPS - 1)) ]] || return
    ((SELECTED_INDEX++))
    local max_offset=$((TOTAL_APPS - VISIBLE_ITEMS))
    [[ $max_offset -lt 0 ]] && max_offset=0
    [[ $SELECTED_INDEX -ge $((SCROLL_OFFSET + VISIBLE_ITEMS)) ]] && SCROLL_OFFSET=$((SELECTED_INDEX - VISIBLE_ITEMS + 1))
    [[ $SCROLL_OFFSET -gt $max_offset ]] && SCROLL_OFFSET=$max_offset
    NEEDS_REDRAW=true
}

toggle_item() {
    $IS_INSTALLING && return
    if [[ -n "${SELECTION_STATE[$SELECTED_INDEX]:-}" ]]; then
        unset SELECTION_STATE[$SELECTED_INDEX]
    else
        SELECTION_STATE[$SELECTED_INDEX]=1
    fi
    NEEDS_REDRAW=true
}

select_all() {
    $IS_INSTALLING && return
    local i
    for i in "${!APPS[@]}"; do
        [[ ${INSTALLED_CACHE[$i]:-0} -eq 0 ]] && SELECTION_STATE[$i]=1
    done
    NEEDS_REDRAW=true
}

clear_all() {
    $IS_INSTALLING && return
    SELECTION_STATE=()
    NEEDS_REDRAW=true
}

#===============================================================================
# INSTALACIÓN CON CONFIRMACIÓN
#===============================================================================

install_selection() {
    local targets=()
    local i
    
    for i in "${!SELECTION_STATE[@]}"; do
        [[ ${INSTALLED_CACHE[$i]:-0} -eq 0 ]] && targets+=("$i")
    done
    
    if [[ ${#targets[@]} -eq 0 ]]; then
        [[ ${INSTALLED_CACHE[$SELECTED_INDEX]:-0} -eq 0 ]] && targets+=("$SELECTED_INDEX")
    fi
    
    [[ ${#targets[@]} -eq 0 ]] && return
    
    IS_INSTALLING=true
    NEEDS_REDRAW=true
    
    clear_screen
    show_cursor
    
    printf "\n${C_NAVY}%${TERMINAL_WIDTH}s${C_RESET}\n\n" | tr ' ' '='
    printf "  ${C_GOLD}${C_BOLD}INSTALLATION PROCESS${C_RESET}\n"
    printf "  ${C_GRAY_LIGHT}%d package(s) queued${C_RESET}\n\n" "${#targets[@]}"
    printf "  ${C_NAVY}%$((TERMINAL_WIDTH - 4))s${C_RESET}\n\n" | tr ' ' '-'
    
    local current=0
    local total=${#targets[@]}
    local idx
    
    for idx in "${targets[@]}"; do
        ((current++))
        local app_name="${APPS[$idx]}"
        local app_cmd="${APP_CMD[$idx]}"
        local app_method="${APP_METHOD[$idx]}"
        local app_deps="${APP_DEPS[$idx]:-}"
        
        printf "  ${C_ACADEMY}[%d/%d]${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$current" "$total" "$app_name"
        printf "  ${C_GRAY_LIGHT}Method: %s${C_RESET}\n" "$app_method"
        
        # CONFIRMAR DEPENDENCIAS
        if [[ -n "$app_deps" ]]; then
            printf "  ${C_GRAY_LIGHT}Required: %s${C_RESET}\n" "$app_deps"
            
            for dep in $app_deps; do
                if ! ensure_dependency "$dep"; then
                    printf "  ${C_ORANGE}${I_WARNING} Cannot install without %s${C_RESET}\n\n" "$dep"
                    printf "  ${C_NAVY}%$((TERMINAL_WIDTH - 4))s${C_RESET}\n\n" | tr ' ' '-'
                    continue 2
                fi
            done
        fi
        
        printf "  ${C_GRAY_LIGHT}Command: %s${C_RESET}\n\n" "$app_cmd"
        
        # EJECUTAR
        if [[ "${DEMO_MODE:-0}" == "1" ]]; then
            local spin_idx=0
            for ((prog=0; prog<=100; prog+=25)); do
                move_cursor $((TERMINAL_HEIGHT - 4)) 10
                printf "${C_GOLD}${I_SPINNER[$((spin_idx % 4))]}${C_RESET} %d%%   " "$prog"
                ((spin_idx++))
                sleep 0.3
            done
            printf "\n\n  ${C_FOREST}${I_CHECK} Simulated${C_RESET}\n\n"
            INSTALLED_CACHE[$idx]=1
        else
            local tmp_log="${CONFIG_DIR}/tmp_$$.log"
            
            # Verificar si el comando anterior dejó yay roto (libalpm)
            if [[ "$app_method" == "aur" ]] && command_exists yay; then
                if ! yay --version &>/dev/null; then
                    printf "  ${C_ORANGE}${I_WARNING} yay appears broken (missing libalpm)${C_RESET}\n"
                    printf "  ${C_GRAY_LIGHT}Attempting to rebuild yay...${C_RESET}\n"
                    
                    if ask_user "Rebuild yay now? [Y/n]" "y"; then
                        sudo pacman -S --noconfirm yay 2>/dev/null || {
                            cd /tmp && rm -rf yay && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm
                        }
                    fi
                fi
            fi
            
            eval "$app_cmd" > "$tmp_log" 2>&1 &
            local pid=$!
            
            local spin_idx=0
            while kill -0 $pid 2>/dev/null; do
                move_cursor $((TERMINAL_HEIGHT - 4)) 10
                printf "${C_GOLD}${I_SPINNER[$((spin_idx % 4))]}${C_RESET} Installing..."
                ((spin_idx++))
                sleep 0.3
            done
            
            wait $pid
            local exit_code=$?
            printf "\n\n"
            
            if [[ $exit_code -eq 0 ]]; then
                printf "  ${C_FOREST}${I_CHECK} Success${C_RESET}\n\n"
                INSTALLED_CACHE[$idx]=1
            else
                printf "  ${C_BURGUNDY}✗ Failed (code: %d)${C_RESET}\n\n" "$exit_code"
                [[ -f "$tmp_log" ]] && tail -n 2 "$tmp_log" | while read -r line; do
                    printf "    ${C_GRAY}> %s${C_RESET}\n" "$line"
                done
                printf "\n"
            fi
            
            rm -f "$tmp_log"
        fi
        
        printf "  ${C_NAVY}%$((TERMINAL_WIDTH - 4))s${C_RESET}\n\n" | tr ' ' '-'
    done
    
    SELECTION_STATE=()
    SKIP_ALL_DEPENDENCIES=false
    AUTO_INSTALL_DEPENDENCIES=false
    
    printf "  ${C_FOREST}${C_BOLD}Complete${C_RESET}\n\n"
    printf "  ${C_GRAY_LIGHT}Press any key...${C_RESET}"
    read -n 1 -s
    
    hide_cursor
    IS_INSTALLING=false
    NEEDS_REDRAW=true
}

#===============================================================================
# MAIN
#===============================================================================

main() {
    if [[ "${DEMO_MODE:-0}" != "1" ]] && [[ ! -f /etc/arch-release ]]; then
        printf "\n${C_BURGUNDY}Error: Requires Arch Linux${C_RESET}\n"
        printf "Use: ${C_GOLD}DEMO_MODE=1 ./installer.sh${C_RESET}\n\n"
        exit 1
    fi
    
    trap cleanup EXIT INT TERM
    hide_cursor
    stty -echo -icanon min 1 time 0 2>/dev/null || true
    
    draw_interface
    
    while true; do
        if $NEEDS_REDRAW; then
            draw_interface
        fi
        
        local key=""
        if IFS= read -rs -t 0.5 -n1 key 2>/dev/null; then
            if [[ "$key" == $'\x1b' ]]; then
                local rest=""
                IFS= read -rs -t 0.05 -n2 rest 2>/dev/null || true
                key+="$rest"
            fi
            
            case "$key" in
                $'\x1b[A'|k|K) navigate_up ;;
                $'\x1b[B'|j|J) navigate_down ;;
                ' ') toggle_item ;;
                $'\n'|$'\r'|"") install_selection ;;
                a|A) select_all ;;
                c|C) clear_all ;;
                q|Q|$'\x03') break ;;
            esac
        fi
    done
    
    cleanup
    clear_screen
    printf "\n${C_NAVY}%${TERMINAL_WIDTH}s${C_RESET}\n" | tr ' ' '-'
    printf "${C_GRAY_LIGHT}  Academic Software Installer${C_RESET}\n"
    printf "${C_NAVY}%${TERMINAL_WIDTH}s${C_RESET}\n\n" | tr ' ' '-'
}

main "$@"
