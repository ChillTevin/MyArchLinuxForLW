#!/bin/bash

# ============================================
# Kit de Instalación para Arch Linux
# Estilo: Ranger TUI (Text User Interface)
# ============================================

# Configuración de terminal
export TERM=xterm-256color
shopt -s checkwinsize

# Colores - paleta Ranger
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Colores base
BLACK='\033[38;5;0m'
RED='\033[38;5;1m'
GREEN='\033[38;5;2m'
YELLOW='\033[38;5;3m'
BLUE='\033[38;5;4m'
MAGENTA='\033[38;5;5m'
CYAN='\033[38;5;6m'
WHITE='\033[38;5;7m'

# Colores brillantes (Ranger style)
FG_DEFAULT='\033[38;5;250m'
FG_SELECTED='\033[38;5;255m'
BG_SELECTED='\033[48;5;24m'
FG_HEADER='\033[38;5;11m'
FG_BORDER='\033[38;5;8m'
FG_STATUS='\033[38;5;12m'
FG_SUCCESS='\033[38;5;82m'
FG_ERROR='\033[38;5;196m'
FG_INFO='\033[38;5;14m'

# Símbolos Unicode
CORNER_TL='┌'
CORNER_TR='┐'
CORNER_BL='└'
CORNER_BR='┘'
HORIZONTAL='─'
VERTICAL='│'
T_RIGHT='├'
T_LEFT='┤'
T_DOWN='┬'
T_UP='┴'
CROSS='┼'

CHECK='✓'
UNCHECK='○'
BULLET='•'
ARROW='➜'
FOLDER='📁'
PACKAGE='📦'
INSTALLED='▣'
NOT_INSTALLED='▢'

# ============================================
# VARIABLES GLOBALES
# ============================================

TERMINAL_WIDTH=0
TERMINAL_HEIGHT=0
LEFT_WIDTH=35
RIGHT_WIDTH=45
SELECTED_INDEX=1
TOTAL_APPS=8
SCROLL_OFFSET=1

declare -A apps
declare -A descriptions
declare -A install_cmds
declare -A pkg_names
declare -A categories
declare -A installed_status

# ============================================
# INICIALIZACIÓN DE APPS
# ============================================

init_apps() {
    # 1. Obsidian
    apps[1]="Obsidian"
    categories[1]="NOTAS"
    descriptions[1]="Editor de notas en Markdown con grafos de conocimiento. Ideal para Zettelkasten, Second Brain y PKM. Soporta plugins, temas y sincronización."
    pkg_names[1]="obsidian"
    install_cmds[1]="install_yay obsidian"

    # 2. Stacer
    apps[2]="Stacer"
    categories[2]="SISTEMA"
    descriptions[2]="Administrador de sistema todo-en-uno. Limpieza de caché, monitor de recursos en tiempo real, gestor de procesos y control de aplicaciones de inicio."
    pkg_names[2]="stacer"
    install_cmds[2]="install_yay stacer"

    # 3. OnlyOffice
    apps[3]="OnlyOffice"
    categories[3]="OFIMÁTICA"
    descriptions[3]="Suite ofimática completa compatible con Microsoft Office. Soporta DOCX, XLSX, PPTX. Colaboración en tiempo real y edición local."
    pkg_names[3]="onlyoffice-bin"
    install_cmds[3]="install_yay onlyoffice-bin"

    # 4. Flatpak + Flathub
    apps[4]="Flatpak + Flathub"
    categories[4]="PAQUETES"
    descriptions[4]="Sistema de empaquetado universal sandboxed. Acceso a miles de apps en Flathub. Aislamiento de seguridad y compatibilidad entre distros."
    pkg_names[4]="flatpak"
    install_cmds[4]="install_pacman flatpak && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

    # 5. WebCatalog
    apps[5]="WebCatalog"
    categories[5]="INTERNET"
    descriptions[5]="Convierte cualquier sitio web en app de escritorio nativa. Aislamiento por sitio, notificaciones nativas, badges y atajos de teclado."
    pkg_names[5]="webcatalog"
    install_cmds[5]="install_yay webcatalog"

    # 6. Brave
    apps[6]="Brave Browser"
    categories[6]="NAVEGADOR"
    descriptions[6]="Navegador basado en Chromium con bloqueador de anuncios integrado. Modo Tor privado, recompensas BAT y enfocado en privacidad por defecto."
    pkg_names[6]="brave-bin"
    install_cmds[6]="install_yay brave-bin"

    # 7. KDE Connect
    apps[7]="KDE Connect"
    categories[7]="CONEXIÓN"
    descriptions[7]="Integración total entre PC y móvil. Transferencia de archivos, notificaciones espejo, control remoto, clipboard compartido y presentaciones."
    pkg_names[7]="kdeconnect"
    install_cmds[7]="install_pacman kdeconnect"

    # 8. TimeShift
    apps[8]="TimeShift"
    categories[8]="RESPALDO"
    descriptions[8]="Crea snapshots del sistema automáticamente. Restauración instantánea a puntos anteriores. Protección contra actualizaciones fallidas."
    pkg_names[8]="timeshift"
    install_cmds[8]="install_pacman timeshift"

    check_all_installed
}

# ============================================
# FUNCIONES DE UTILIDAD
# ============================================

get_terminal_size() {
    read -r TERMINAL_HEIGHT TERMINAL_WIDTH < <(stty size)
}

check_installed() {
    if pacman -Q "$1" &>/dev/null || yay -Q "$1" &>/dev/null 2>/dev/null || flatpak list 2>/dev/null | grep -qi "$1"; then
        return 0
    else
        return 1
    fi
}

check_all_installed() {
    for i in $(seq 1 $TOTAL_APPS); do
        if check_installed "${pkg_names[$i]}"; then
            installed_status[$i]=1
        else
            installed_status[$i]=0
        fi
    done
}

# ============================================
# FUNCIONES DE DIBUJO TUI
# ============================================

draw_horizontal_line() {
    local width=$1
    local char="${2:-$HORIZONTAL}"
    printf "%${width}s" "" | tr " " "$char"
}

draw_box_top() {
    local width=$1
    echo -e "${FG_BORDER}${CORNER_TL}$(draw_horizontal_line $((width-2)))${CORNER_TR}${RESET}"
}

draw_box_bottom() {
    local width=$1
    echo -e "${FG_BORDER}${CORNER_BL}$(draw_horizontal_line $((width-2)))${CORNER_BR}${RESET}"
}

draw_box_line() {
    local width=$1
    local content="$2"
    local align="${3:-left}"
    local padding=$((width - 2 - ${#content}))
    
    if [ "$align" = "center" ]; then
        local left=$((padding / 2))
        local right=$((padding - left))
        printf "${FG_BORDER}${VERTICAL}${RESET}%${left}s%s%${right}s${FG_BORDER}${VERTICAL}${RESET}\n" "" "$content" ""
    else
        printf "${FG_BORDER}${VERTICAL}${RESET} %s%${padding}s ${FG_BORDER}${VERTICAL}${RESET}\n" "$content" ""
    fi
}

clear_screen() {
    printf '\033[2J\033[H'
}

move_cursor() {
    printf '\033[%d;%dH' "$1" "$2"
}

hide_cursor() {
    printf '\033[?25l'
}

show_cursor() {
    printf '\033[?25h'
}

# ============================================
# PANELES PRINCIPALES
# ============================================

draw_header() {
    local title="🛠️  KIT DE INSTALACIÓN ARCH LINUX"
    local subtitle="Navega con ↑↓ • Espacio: seleccionar • Enter: instalar • q: salir"
    
    echo -e "${FG_HEADER}${BOLD}"
    draw_box_top $TERMINAL_WIDTH
    draw_box_line $TERMINAL_WIDTH "$title" "center"
    draw_box_line $TERMINAL_WIDTH "$subtitle" "center"
    draw_box_bottom $TERMINAL_WIDTH
    echo -e "${RESET}"
}

draw_left_panel() {
    local start_y=5
    local visible_height=$((TERMINAL_HEIGHT - 8))
    
    # Marco del panel
    move_cursor $start_y 1
    echo -e "${FG_BORDER}${CORNER_TL}$(draw_horizontal_line $((LEFT_WIDTH-2)))${CORNER_TR}${RESET}"
    
    for i in $(seq 1 $visible_height); do
        move_cursor $((start_y + i)) 1
        echo -e "${FG_BORDER}${VERTICAL}${RESET}$(printf "%$((LEFT_WIDTH-2))s" "")${FG_BORDER}${VERTICAL}${RESET}"
    done
    
    move_cursor $((start_y + visible_height + 1)) 1
    echo -e "${FG_BORDER}${CORNER_BL}$(draw_horizontal_line $((LEFT_WIDTH-2)))${CORNER_BR}${RESET}"
    
    # Título del panel
    move_cursor $start_y 3
    echo -e "${BOLD}${CYAN}PAQUETES${RESET}"
    
    # Lista de apps
    local list_start=$((start_y + 2))
    local end_idx=$((SCROLL_OFFSET + visible_height - 1))
    [ $end_idx -gt $TOTAL_APPS ] && end_idx=$TOTAL_APPS
    
    local row=$list_start
    for i in $(seq $SCROLL_OFFSET $end_idx); do
        move_cursor $row 3
        
        # Indicador de selección
        if [ $i -eq $SELECTED_INDEX ]; then
            echo -e "${BG_SELECTED}${FG_SELECTED}"
        fi
        
        # Estado de instalación
        if [ ${installed_status[$i]} -eq 1 ]; then
            printf "${FG_SUCCESS}${INSTALLED}${RESET} "
        else
            printf "${FG_ERROR}${NOT_INSTALLED}${RESET} "
        fi
        
        # Número y nombre
        printf "%d. %-20s" "$i" "${apps[$i]:0:20}"
        
        # Categoría
        if [ $i -eq $SELECTED_INDEX ]; then
            echo -e "${RESET}"
        else
            echo ""
        fi
        
        ((row++))
    done
    
    # Scroll indicators
    if [ $SCROLL_OFFSET -gt 1 ]; then
        move_cursor $((start_y + 1)) $((LEFT_WIDTH - 2))
        echo -e "${FG_INFO}▲${RESET}"
    fi
    if [ $end_idx -lt $TOTAL_APPS ]; then
        move_cursor $((start_y + visible_height)) $((LEFT_WIDTH - 2))
        echo -e "${FG_INFO}▼${RESET}"
    fi
}

draw_right_panel() {
    local start_y=5
    local start_x=$((LEFT_WIDTH + 2))
    local visible_height=$((TERMINAL_HEIGHT - 8))
    local width=$((TERMINAL_WIDTH - LEFT_WIDTH - 2))
    
    # Marco
    move_cursor $start_y $start_x
    echo -e "${FG_BORDER}${CORNER_TL}$(draw_horizontal_line $((width-2)))${CORNER_TR}${RESET}"
    
    for i in $(seq 1 $visible_height); do
        move_cursor $((start_y + i)) $start_x
        echo -e "${FG_BORDER}${VERTICAL}${RESET}$(printf "%$((width-2))s" "")${FG_BORDER}${VERTICAL}${RESET}"
    done
    
    move_cursor $((start_y + visible_height + 1)) $start_x
    echo -e "${FG_BORDER}${CORNER_BL}$(draw_horizontal_line $((width-2)))${CORNER_BR}${RESET}"
    
    # Contenido
    local content_y=$((start_y + 2))
    
    # Nombre de la app seleccionada
    move_cursor $content_y $((start_x + 2))
    echo -e "${BOLD}${YELLOW}${apps[$SELECTED_INDEX]}${RESET}"
    
    # Categoría
    move_cursor $((content_y + 1)) $((start_x + 2))
    echo -e "${MAGENTA}[${categories[$SELECTED_INDEX]}]${RESET}"
    
    # Separador
    move_cursor $((content_y + 2)) $((start_x + 2))
    echo -e "${FG_BORDER}$(draw_horizontal_line $((width-6)))${RESET}"
    
    # Descripción (word wrap)
    local desc="${descriptions[$SELECTED_INDEX]}"
    local max_len=$((width - 6))
    local line_num=0
    
    while [ ${#desc} -gt 0 ] && [ $line_num -lt $((visible_height - 6)) ]; do
        move_cursor $((content_y + 3 + line_num)) $((start_x + 2))
        
        if [ ${#desc} -le $max_len ]; then
            echo "$desc"
            break
        else
            local line="${desc:0:$max_len}"
            # Buscar último espacio
            local last_space=$(echo "$line" | grep -o ' [^ ]*$' || echo "")
            if [ -n "$last_space" ] && [ ${#last_space} -lt $max_len ]; then
                line="${line% *}"
                desc="${desc:${#line}}"
            else
                desc="${desc:$max_len}"
            fi
            echo "$line"
        fi
        ((line_num++))
    done
    
    # Estado actual
    move_cursor $((start_y + visible_height - 2)) $((start_x + 2))
    if [ ${installed_status[$SELECTED_INDEX]} -eq 1 ]; then
        echo -e "${FG_SUCCESS}${CHECK} INSTALADO${RESET}"
    else
        echo -e "${FG_ERROR}${UNCHECK} NO INSTALADO${RESET}"
    fi
}

draw_status_bar() {
    local y=$((TERMINAL_HEIGHT - 2))
    move_cursor $y 1
    
    local selected_count=0
    for i in $(seq 1 $TOTAL_APPS); do
        [ ${selected_to_install[$i]:-0} -eq 1 ] && ((selected_count++))
    done
    
    local status_text=" ${SELECTED_INDEX}/${TOTAL_APPS} | ${selected_count} seleccionados | Enter: instalar | a: todos | q: salir "
    local padding=$((TERMINAL_WIDTH - ${#status_text} - 2))
    
    echo -e "${BG_SELECTED}${FG_SELECTED}${status_text}$(printf "%${padding}s")${RESET}"
}

draw_preview_command() {
    local start_y=$((TERMINAL_HEIGHT / 2))
    local start_x=$((TERMINAL_WIDTH / 4))
    local width=$((TERMINAL_WIDTH / 2))
    
    move_cursor $start_y $start_x
    echo -e "${FG_BORDER}${CORNER_TL}$(draw_horizontal_line $((width-2)))${CORNER_TR}${RESET}"
    
    move_cursor $((start_y + 1)) $start_x
    echo -e "${FG_BORDER}${VERTICAL}${RESET} ${BOLD}Comando a ejecutar:${RESET}$(printf "%$((width-21))s")${FG_BORDER}${VERTICAL}${RESET}"
    
    move_cursor $((start_y + 2)) $start_x
    echo -e "${FG_BORDER}${VERTICAL}${RESET}$(printf "%$((width-2))s")${FG_BORDER}${VERTICAL}${RESET}"
    
    local cmd="${install_cmds[$SELECTED_INDEX]}"
    move_cursor $((start_y + 3)) $start_x
    echo -e "${FG_BORDER}${VERTICAL}${RESET} ${CYAN}$cmd${RESET}$(printf "%$((width - ${#cmd} - 2))s")${FG_BORDER}${VERTICAL}${RESET}"
    
    move_cursor $((start_y + 4)) $start_x
    echo -e "${FG_BORDER}${CORNER_BL}$(draw_horizontal_line $((width-2)))${CORNER_BR}${RESET}"
}

# ============================================
# FUNCIONES DE INSTALACIÓN
# ============================================

install_pacman() {
    echo -e "\n${FG_INFO}▶ Instalando con pacman...${RESET}"
    sudo pacman -S --noconfirm --needed "$1"
}

install_yay() {
    if ! command -v yay &>/dev/null; then
        echo -e "${FG_ERROR}yay no encontrado. Instalando...${RESET}"
        install_yay_helper
    fi
    echo -e "\n${FG_INFO}▶ Instalando desde AUR...${RESET}"
    yay -S --noconfirm "$1"
}

install_yay_helper() {
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp || return
    git clone https://aur.archlinux.org/yay.git
    cd yay || return
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

do_install() {
    local idx=$1
    local app_name="${apps[$idx]}"
    
    clear_screen
    echo -e "${FG_HEADER}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${FG_HEADER}║${RESET}  ${BOLD}Instalando: $app_name${RESET}$(printf "%$((50 - ${#app_name}))s")${FG_HEADER}║${RESET}"
    echo -e "${FG_HEADER}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    eval "${install_cmds[$idx]}"
    
    if [ $? -eq 0 ]; then
        installed_status[$idx]=1
        echo -e "\n${FG_SUCCESS}✓ $app_name instalado correctamente${RESET}"
    else
        echo -e "\n${FG_ERROR}✗ Error instalando $app_name${RESET}"
    fi
    
    echo ""
    read -rp "$(echo -e "${FG_INFO}Presiona Enter para continuar...${RESET}")"
}

install_selected() {
    local to_install=()
    
    for i in $(seq 1 $TOTAL_APPS); do
        if [ ${selected_to_install[$i]:-0} -eq 1 ] && [ ${installed_status[$i]} -eq 0 ]; then
            to_install+=($i)
        fi
    done
    
    if [ ${#to_install[@]} -eq 0 ]; then
        return
    fi
    
    clear_screen
    echo -e "${FG_HEADER}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${FG_HEADER}║${RESET}           ${BOLD}INSTALACIÓN MÚLTIPLE${RESET}                             ${FG_HEADER}║${RESET}"
    echo -e "${FG_HEADER}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    for idx in "${to_install[@]}"; do
        echo -e "${YELLOW}▶ ${apps[$idx]}${RESET}"
        eval "${install_cmds[$idx]}"
        
        if [ $? -eq 0 ]; then
            installed_status[$idx]=1
            echo -e "${FG_SUCCESS}  ✓ Completado${RESET}\n"
        else
            echo -e "${FG_ERROR}  ✗ Fallido${RESET}\n"
        fi
    done
    
    echo -e "${FG_SUCCESS}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${FG_SUCCESS}║${RESET}           ${BOLD}INSTALACIÓN COMPLETADA${RESET}                          ${FG_SUCCESS}║${RESET}"
    echo -e "${FG_SUCCESS}╚════════════════════════════════════════════════════════════╝${RESET}"
    read -rp "$(echo -e "\n${FG_INFO}Presiona Enter para continuar...${RESET}")"
}

# ============================================
# MAIN LOOP
# ============================================

declare -A selected_to_install

main() {
    init_apps
    get_terminal_size
    hide_cursor
    clear_screen
    
    # Loop principal
    while true; do
        get_terminal_size
        draw_header
        draw_left_panel
        draw_right_panel
        draw_status_bar
        
        # Leer input
        IFS= read -rs -n1 key
        
        case "$key" in
            $'\x1b')  # Secuencias de escape (flechas)
                read -rs -n2 rest
                case "$rest" in
                    '[A')  # Arriba
                        if [ $SELECTED_INDEX -gt 1 ]; then
                            ((SELECTED_INDEX--))
                            [ $SELECTED_INDEX -lt $SCROLL_OFFSET ] && ((SCROLL_OFFSET--))
                        fi
                        ;;
                    '[B')  # Abajo
                        if [ $SELECTED_INDEX -lt $TOTAL_APPS ]; then
                            ((SELECTED_INDEX++))
                            local visible=$((TERMINAL_HEIGHT - 8))
                            [ $SELECTED_INDEX -gt $((SCROLL_OFFSET + visible - 1)) ] && ((SCROLL_OFFSET++))
                        fi
                        ;;
                esac
                ;;
            ' ')  # Espacio - toggle selección
                if [ ${selected_to_install[$SELECTED_INDEX]:-0} -eq 1 ]; then
                    selected_to_install[$SELECTED_INDEX]=0
                else
                    selected_to_install[$SELECTED_INDEX]=1
                fi
                ;;
            '')   # Enter - instalar seleccionados o actual
                local has_selection=0
                for i in $(seq 1 $TOTAL_APPS); do
                    [ ${selected_to_install[$i]:-0} -eq 1 ] && has_selection=1 && break
                done
                
                if [ $has_selection -eq 1 ]; then
                    install_selected
                    # Limpiar selecciones
                    for i in $(seq 1 $TOTAL_APPS); do
                        selected_to_install[$i]=0
                    done
                else
                    do_install $SELECTED_INDEX
                fi
                clear_screen
                ;;
            'a'|'A')  # Seleccionar todos
                for i in $(seq 1 $TOTAL_APPS); do
                    [ ${installed_status[$i]} -eq 0 ] && selected_to_install[$i]=1
                done
                ;;
            'c'|'C')  # Limpiar selección
                for i in $(seq 1 $TOTAL_APPS); do
                    selected_to_install[$i]=0
                done
                ;;
            'q'|'Q')  # Salir
                break
                ;;
        esac
    done
    
    show_cursor
    clear_screen
    echo -e "${FG_SUCCESS}✓ Saliendo del instalador${RESET}"
}

# Capturar señales para restaurar cursor
trap 'show_cursor; clear; exit' INT TERM EXIT

main
