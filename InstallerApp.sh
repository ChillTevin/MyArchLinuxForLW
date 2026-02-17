#!/bin/bash

# ============================================
# Kit de Instalación para Arch Linux
# Estilo: Ranger TUI con descripciones
# ============================================

# Configuración de terminal
export TERM=xterm-256color
shopt -s checkwinsize

# ============================================
# PALETA DE COLORES
# ============================================

# Reset y estilos
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Violetas y púrpuras
VIOLET_DARK='\033[38;5;55m'
VIOLET='\033[38;5;93m'
VIOLET_BRIGHT='\033[38;5;141m'
VIOLET_NEON='\033[38;5;165m'
MAGENTA_GLOW='\033[38;5;198m'

# Backgrounds violetas
BG_VIOLET_DARK='\033[48;5;55m'
BG_VIOLET='\033[48;5;93m'
BG_VIOLET_BRIGHT='\033[48;5;141m'

# Colores de acento
CYAN='\033[38;5;51m'
CYAN_BRIGHT='\033[38;5;87m'
GREEN='\033[38;5;82m'
GREEN_BRIGHT='\033[38;5;118m'
GOLD='\033[38;5;220m'
GOLD_BRIGHT='\033[38;5;226m'
ORANGE='\033[38;5;208m'
ORANGE_BRIGHT='\033[38;5;214m'
WHITE='\033[38;5;255m'
WHITE_BRIGHT='\033[38;5;231m'
GRAY='\033[38;5;245m'
GRAY_DARK='\033[38;5;240m'

# ============================================
# SÍMBOLOS Y CARACTERES
# ============================================

# Marcadores de estado
CHECK='✓'
CHECK_HEAVY='✔'
CIRCLE='○'
CIRCLE_FILLED='●'
ARROW='▶'
ARROW_DOUBLE='»'
BULLET='•'
DIAMOND='◆'
STAR='★'

# Separadores
LINE_SINGLE='─'
LINE_DOUBLE='═'
LINE_THICK='━'

# ============================================
# VARIABLES GLOBALES
# ============================================

# Dimensiones de terminal
TERMINAL_WIDTH=0
TERMINAL_HEIGHT=0

# Dimensiones de paneles
PANEL_LEFT_WIDTH=45
PANEL_RIGHT_WIDTH=0
PANEL_HEIGHT=0

# Navegación
SELECTED_INDEX=1
TOTAL_APPS=8
SCROLL_OFFSET=1
VISIBLE_ITEMS=0

# ============================================
# ARRAYS DE DATOS
# ============================================

# Nombres de aplicaciones
declare -A APPS

# Descripciones detalladas
declare -A DESCRIPTIONS

# Comandos de instalación
declare -A INSTALL_CMDS

# Nombres de paquetes
declare -A PKG_NAMES

# Categorías
declare -A CATEGORIES

# Estado de instalación (0=no, 1=sí)
declare -A INSTALLED_STATUS

# Selección para instalación batch
declare -A SELECTED_TO_INSTALL

# Iconos por categoría
declare -A ICONS

# ============================================
# FUNCIONES DE UTILIDAD BÁSICAS
# ============================================

# Obtiene el tamaño actual de la terminal
function update_terminal_size() {
    # Leer dimensiones de la terminal
    read -r TERMINAL_HEIGHT TERMINAL_WIDTH < <(stty size)
    
    # Calcular items visibles (dejar espacio para header y footer)
    VISIBLE_ITEMS=$((TERMINAL_HEIGHT - 12))
    
    # Asegurar valores mínimos y máximos
    if [ $VISIBLE_ITEMS -gt $TOTAL_APPS ]; then
        VISIBLE_ITEMS=$TOTAL_APPS
    fi
    
    if [ $VISIBLE_ITEMS -lt 1 ]; then
        VISIBLE_ITEMS=1
    fi
    
    # Calcular ancho del panel derecho
    PANEL_RIGHT_WIDTH=$((TERMINAL_WIDTH - PANEL_LEFT_WIDTH - 6))
    
    # Asegurar ancho mínimo
    if [ $PANEL_RIGHT_WIDTH -lt 30 ]; then
        PANEL_RIGHT_WIDTH=30
    fi
    
    # Calcular altura de paneles
    PANEL_HEIGHT=$((VISIBLE_ITEMS + 4))
}

# Verifica si un paquete está instalado
function is_package_installed() {
    local package_name="$1"
    
    # Verificar con pacman
    if pacman -Q "$package_name" &>/dev/null; then
        return 0
    fi
    
    # Verificar con yay (AUR)
    if command -v yay &>/dev/null; then
        if yay -Q "$package_name" &>/dev/null 2>/dev/null; then
            return 0
        fi
    fi
    
    # Verificar con flatpak
    if command -v flatpak &>/dev/null; then
        if flatpak list 2>/dev/null | grep -qi "$package_name"; then
            return 0
        fi
    fi
    
    return 1
}

# Actualiza el estado de instalación de todas las apps
function update_all_install_status() {
    local index
    
    for index in $(seq 1 $TOTAL_APPS); do
        if is_package_installed "${PKG_NAMES[$index]}"; then
            INSTALLED_STATUS[$index]=1
        else
            INSTALLED_STATUS[$index]=0
        fi
    done
}

# ============================================
# INICIALIZACIÓN DE DATOS
# ============================================

function initialize_data() {
    # Definir iconos para cada categoría
    ICONS[NOTAS]="📝"
    ICONS[SISTEMA]="⚙️"
    ICONS[OFIMÁTICA]="📊"
    ICONS[PAQUETES]="📦"
    ICONS[INTERNET]="🌐"
    ICONS[NAVEGADOR]="🦁"
    ICONS[CONEXIÓN]="📱"
    ICONS[RESPALDO]="💾"
    
    # ========================================
    # APP 1: Obsidian
    # ========================================
    APPS[1]="Obsidian"
    CATEGORIES[1]="NOTAS"
    PKG_NAMES[1]="obsidian"
    INSTALL_CMDS[1]="install_yay obsidian"
    
    DESCRIPTIONS[1]="Editor de notas basado en Markdown con enlaces bidireccionales \
y visualización de grafos de conocimiento. Ideal para construir un Second Brain, \
sistemas Zettelkasten y gestión de conocimiento personal. Soporta plugins, temas \
personalizados, sincronización cifrada y trabajo offline completo."
    
    # ========================================
    # APP 2: Stacer
    # ========================================
    APPS[2]="Stacer"
    CATEGORIES[2]="SISTEMA"
    PKG_NAMES[2]="stacer"
    INSTALL_CMDS[2]="install_yay stacer"
    
    DESCRIPTIONS[2]="Administrador de sistema todo-en-uno con interfaz moderna \
y amigable. Incluye limpieza de archivos temporales y caché, monitor de recursos \
en tiempo real con gráficos, gestor de procesos, control de aplicaciones de inicio \
y herramientas de optimización del sistema."
    
    # ========================================
    # APP 3: OnlyOffice
    # ========================================
    APPS[3]="OnlyOffice"
    CATEGORIES[3]="OFIMÁTICA"
    PKG_NAMES[3]="onlyoffice-bin"
    INSTALL_CMDS[3]="install_yay onlyoffice-bin"
    
    DESCRIPTIONS[3]="Suite ofimática completa compatible al 100% con Microsoft \
Office. Soporta nativamente formatos DOCX, XLSX, PPTX. Incluye editor de documentos, \
hojas de cálculo y presentaciones. Cuenta con modo oscuro, colaboración en tiempo \
real y es completamente libre y gratuito."
    
    # ========================================
    # APP 4: Flatpak + Flathub
    # ========================================
    APPS[4]="Flatpak + Flathub"
    CATEGORIES[4]="PAQUETES"
    PKG_NAMES[4]="flatpak"
    INSTALL_CMDS[4]="install_pacman flatpak && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
    
    DESCRIPTIONS[4]="Sistema de empaquetado universal con sandboxing que permite \
instalar aplicaciones de manera segura. Proporciona acceso a miles de apps a través \
de Flathub. Ofrece aislamiento de seguridad, actualizaciones automáticas y \
compatibilidad total entre diferentes distribuciones Linux."
    
    # ========================================
    # APP 5: WebCatalog
    # ========================================
    APPS[5]="WebCatalog"
    CATEGORIES[5]="INTERNET"
    PKG_NAMES[5]="webcatalog"
    INSTALL_CMDS[5]="install_yay webcatalog"
    
    DESCRIPTIONS[5]="Convierte cualquier sitio web en aplicación de escritorio \
nativa. Cada app tiene su propio contenedor aislado, notificaciones nativas del \
sistema, badges de contador en el dock, atajos de teclado personalizados y menú \
contextual integrado. Perfecto para Gmail, WhatsApp, Notion, etc."
    
    # ========================================
    # APP 6: Brave Browser
    # ========================================
    APPS[6]="Brave Browser"
    CATEGORIES[6]="NAVEGADOR"
    PKG_NAMES[6]="brave-bin"
    INSTALL_CMDS[6]="install_yay brave-bin"
    
    DESCRIPTIONS[6]="Navegador web basado en Chromium con bloqueador de anuncios \
y trackers integrado nativamente. Incluye modo Tor para navegación privada, \
recompensas en criptomoneda BAT por ver anuncios opcionales, sincronización \
segura entre dispositivos y enfocado en privacidad por defecto."
    
    # ========================================
    # APP 7: KDE Connect
    # ========================================
    APPS[7]="KDE Connect"
    CATEGORIES[7]="CONEXIÓN"
    PKG_NAMES[7]="kdeconnect"
    INSTALL_CMDS[7]="install_pacman kdeconnect"
    
    DESCRIPTIONS[7]="Integración completa entre tu computadora y dispositivos \
móviles Android o iOS. Permite transferencia rápida de archivos, espejo de \
notificaciones, control remoto del cursor y teclado, uso del móvil como \
presentador, sincronización del portapapeles y más."
    
    # ========================================
    # APP 8: TimeShift
    # ========================================
    APPS[8]="TimeShift"
    CATEGORIES[8]="RESPALDO"
    PKG_NAMES[8]="timeshift"
    INSTALL_CMDS[8]="install_pacman timeshift"
    
    DESCRIPTIONS[8]="Sistema de snapshots del sistema operativo completo. Crea \
puntos de restauración automáticos antes de actualizaciones. Permite volver a \
un estado anterior del sistema en segundos si algo falla. Esencial para mantener \
Arch Linux estable y recuperarse de problemas."
    
    # Verificar estado de instalación
    update_all_install_status
}

# ============================================
# FUNCIONES DE CONTROL DE TERMINAL
# ============================================

# Limpia toda la pantalla
function clear_screen() {
    printf '\033[2J\033[H'
}

# Mueve el cursor a posición específica
function move_cursor() {
    local row="$1"
    local col="$2"
    printf '\033[%d;%dH' "$row" "$col"
}

# Limpia la línea actual desde el cursor hasta el final
function clear_to_end_of_line() {
    printf '\033[K'
}

# Limpia toda la línea
function clear_entire_line() {
    printf '\033[2K'
}

# Oculta el cursor
function hide_cursor() {
    printf '\033[?25l'
}

# Muestra el cursor
function show_cursor() {
    printf '\033[?25h'
}

# ============================================
# FUNCIONES DE DIBUJO DE COMPONENTES
# ============================================

# Dibuja una línea horizontal
function draw_horizontal_line() {
    local length="$1"
    local char="${2:-$LINE_SINGLE}"
    local color="${3:-$VIOLET}"
    
    printf "${color}"
    for ((i=0; i<length; i++)); do
        printf "%s" "$char"
    done
    printf "${RESET}"
}

# Dibuja el encabezado principal
function draw_header() {
    local title="⚡ ARCH LINUX INSTALLER KIT"
    local subtitle="↑↓:navegar • Espacio:seleccionar • Enter:instalar • q:salir"
    
    # Línea superior del marco
    move_cursor 1 1
    clear_entire_line
    printf "${VIOLET}╔"
    draw_horizontal_line $((TERMINAL_WIDTH - 2)) "═" "$VIOLET"
    printf "╗${RESET}\n"
    
    # Línea del título
    move_cursor 2 1
    clear_entire_line
    printf "${VIOLET}║${RESET}  ${GOLD}${BOLD}%-*s${RESET}" $((TERMINAL_WIDTH - 4)) "$title"
    move_cursor 2 $((TERMINAL_WIDTH - 1))
    printf "${VIOLET}║${RESET}\n"
    
    # Línea del subtítulo
    move_cursor 3 1
    clear_entire_line
    printf "${VIOLET}║${RESET}  ${GRAY}%-*s${RESET}" $((TERMINAL_WIDTH - 4)) "$subtitle"
    move_cursor 3 $((TERMINAL_WIDTH - 1))
    printf "${VIOLET}║${RESET}\n"
    
    # Línea inferior del marco
    move_cursor 4 1
    clear_entire_line
    printf "${VIOLET}╚"
    draw_horizontal_line $((TERMINAL_WIDTH - 2)) "═" "$VIOLET"
    printf "╝${RESET}\n"
}

# Dibuja un item de la lista (normal o seleccionado)
function draw_list_item() {
    local row="$1"
    local col="$2"
    local index="$3"
    local is_selected="$4"
    
    local app_name="${APPS[$index]}"
    local category="${CATEGORIES[$index]}"
    local installed=${INSTALLED_STATUS[$index]}
    local selected=${SELECTED_TO_INSTALL[$index]:-0}
    
    # Truncar nombre si es muy largo
    local display_name="$app_name"
    if [ ${#display_name} -gt 22 ]; then
        display_name="${display_name:0:21}…"
    fi
    
    # Mover a posición y limpiar línea
    move_cursor $row $col
    clear_entire_line
    
    if [ $is_selected -eq 1 ]; then
        # ====================================
        # ITEM SELECCIONADO (con contorno violeta)
        # ====================================
        
        # Fondo violeta oscuro para toda la línea
        printf "${BG_VIOLET_DARK}"
        
        # Número de ítem (alineado a 2 dígitos)
        printf " %2d. " "$index"
        
        # Icono de categoría
        printf "%s " "${ICONS[$category]}"
        
        # Nombre con fondo violeta brillante (efecto marcador)
        local name_padding=$((23 - ${#display_name}))
        printf "${BG_VIOLET}${WHITE}${BOLD} %s${RESET}${BG_VIOLET_DARK}" "$display_name"
        printf "%${name_padding}s" ""
        
        # Espaciado
        printf "  "
        
        # Indicador de selección para instalación batch
        if [ $selected -eq 1 ]; then
            printf "${MAGENTA_GLOW}[${CHECK}]${RESET}${BG_VIOLET_DARK}"
        else
            printf "   "
        fi
        
        # Indicador de estado instalado
        printf "  "
        if [ $installed -eq 1 ]; then
            printf "${GREEN}${CHECK}${RESET}${BG_VIOLET_DARK}"
        else
            printf "${GRAY}${CIRCLE}${RESET}${BG_VIOLET_DARK}"
        fi
        
        # Flecha indicadora de selección
        printf "  ${GOLD}${ARROW}${RESET}"
        
        # Rellenar resto de la línea para limpiar residuos
        local used_length=45
        local remaining=$((PANEL_LEFT_WIDTH - used_length))
        if [ $remaining -gt 0 ]; then
            printf "${BG_VIOLET_DARK}%*s${RESET}" $remaining ""
        fi
        
        printf "${RESET}"
        
    else
        # ====================================
        # ITEM NO SELECCIONADO (normal)
        # ====================================
        
        # Número e icono
        printf " %2d. %s " "$index" "${ICONS[$category]}"
        
        # Nombre (gris si está instalado, blanco si no)
        if [ $installed -eq 1 ]; then
            printf "${GRAY}${DIM}%-23s${RESET}" "$display_name"
        else
            printf "%-23s" "$display_name"
        fi
        
        # Espaciado
        printf "  "
        
        # Indicador de selección batch
        if [ $selected -eq 1 ]; then
            printf "${MAGENTA_GLOW}[${CHECK}]${RESET}"
        else
            printf "   "
        fi
        
        # Indicador de estado
        printf "  "
        if [ $installed -eq 1 ]; then
            printf "${GREEN}${CHECK}${RESET}"
        else
            printf "${GRAY}${CIRCLE}${RESET}"
        fi
        
        # Espacio donde iría la flecha en el seleccionado
        printf "   "
        
        # Limpiar resto de línea
        clear_to_end_of_line
    fi
}

# Dibuja el panel izquierdo (lista de aplicaciones)
function draw_left_panel() {
    local start_y=6
    local start_x=2
    local title="◆ PAQUETES DISPONIBLES"
    
    # Título del panel
    move_cursor $start_y $start_x
    clear_entire_line
    printf "${VIOLET_BRIGHT}${BOLD}  %s${RESET}" "$title"
    
    # Línea separadora
    move_cursor $((start_y + 1)) $start_x
    clear_entire_line
    printf "${VIOLET_DARK}  "
    draw_horizontal_line 40 "─" "$VIOLET_DARK"
    printf "${RESET}"
    
    # Calcular rango de ítems a mostrar
    local list_start=$((start_y + 3))
    local end_idx=$((SCROLL_OFFSET + VISIBLE_ITEMS - 1))
    
    if [ $end_idx -gt $TOTAL_APPS ]; then
        end_idx=$TOTAL_APPS
    fi
    
    # Dibujar cada ítem visible
    local current_row=$list_start
    local index
    
    for index in $(seq $SCROLL_OFFSET $end_idx); do
        if [ $index -eq $SELECTED_INDEX ]; then
            draw_list_item $current_row $start_x $index 1
        else
            draw_list_item $current_row $start_x $index 0
        fi
        ((current_row++))
    done
    
    # Limpiar líneas sobrantes si las hay
    while [ $current_row -lt $((list_start + VISIBLE_ITEMS)) ]; do
        move_cursor $current_row $start_x
        clear_entire_line
        ((current_row++))
    done
    
    # Indicador de scroll hacia arriba
    if [ $SCROLL_OFFSET -gt 1 ]; then
        move_cursor $((start_y + 2)) $((PANEL_LEFT_WIDTH - 3))
        printf "${VIOLET_NEON}▲${RESET}"
    fi
    
    # Indicador de scroll hacia abajo
    if [ $end_idx -lt $TOTAL_APPS ]; then
        move_cursor $((list_start + VISIBLE_ITEMS - 1)) $((PANEL_LEFT_WIDTH - 3))
        printf "${VIOLET_NEON}▼${RESET}"
    fi
}

# Dibuja el panel derecho (información detallada)
function draw_right_panel() {
    local start_y=6
    local start_x=$((PANEL_LEFT_WIDTH + 4))
    local width=$PANEL_RIGHT_WIDTH
    local height=$((VISIBLE_ITEMS + 2))
    
    local content_x=$((start_x + 2))
    local content_width=$((width - 4))
    
    # ========================================
    # LIMPIAR ÁREA DEL PANEL
    # ========================================
    
    local i
    for ((i=0; i<=height+2; i++)); do
        move_cursor $((start_y + i)) $start_x
        clear_entire_line
    done
    
    # ========================================
    # DIBUJAR MARCO
    # ========================================
    
    # Esquina superior izquierda
    move_cursor $start_y $start_x
    printf "${VIOLET}┌${RESET}"
    
    # Línea superior
    draw_horizontal_line $((width - 2)) "─" "$VIOLET"
    
    # Esquina superior derecha
    printf "${VIOLET}┐${RESET}\n"
    
    # Lados del marco
    for ((i=1; i<=height; i++)); do
        move_cursor $((start_y + i)) $start_x
        printf "${VIOLET}│${RESET}"
        
        # Espacio interior limpio
        printf "%*s" $((width - 2)) ""
        
        move_cursor $((start_y + i)) $((start_x + width - 1))
        printf "${VIOLET}│${RESET}\n"
    done
    
    # Esquina inferior izquierda
    move_cursor $((start_y + height + 1)) $start_x
    printf "${VIOLET}└${RESET}"
    
    # Línea inferior
    draw_horizontal_line $((width - 2)) "─" "$VIOLET"
    
    # Esquina inferior derecha
    printf "${VIOLET}┘${RESET}\n"
    
    # ========================================
    # CONTENIDO INTERNO
    # ========================================
    
    local current_y=$((start_y + 2))
    
    # ----------------------------------------
    # Nombre de la aplicación
    # ----------------------------------------
    move_cursor $current_y $content_x
    printf "${GOLD}${BOLD}%-*s${RESET}" "$content_width" "${APPS[$SELECTED_INDEX]}"
    
    # ----------------------------------------
    # Categoría con badge
    # ----------------------------------------
    current_y=$((current_y + 1))
    move_cursor $current_y $content_x
    printf "${BG_VIOLET_DARK} %s ${RESET} %s" \
        "${CATEGORIES[$SELECTED_INDEX]}" \
        "${ICONS[${CATEGORIES[$SELECTED_INDEX]}]}"
    
    # ----------------------------------------
    # Línea separadora
    # ----------------------------------------
    current_y=$((current_y + 1))
    move_cursor $current_y $content_x
    local separator=""
    for ((i=0; i<content_width; i++)); do
        separator="${separator}─"
    done
    printf "${VIOLET_DARK}%s${RESET}" "$separator"
    
    # ----------------------------------------
    # DESCRIPCIÓN (con word wrap)
    # ----------------------------------------
    current_y=$((current_y + 2))
    
    local description="${DESCRIPTIONS[$SELECTED_INDEX]}"
    local max_desc_lines=$((height - 6))
    local line_num=0
    
    # Procesar descripción línea por línea
    while [ ${#description} -gt 0 ] && [ $line_num -lt $max_desc_lines ]; do
        move_cursor $current_y $content_x
        
        if [ ${#description} -le $content_width ]; then
            # Última línea (cabe completa)
            printf "%-*s" "$content_width" "$description"
            clear_to_end_of_line
            break
        else
            # Buscar corte en espacio para no partir palabras
            local cut_pos=$content_width
            local found_space=0
            
            for ((j=content_width-1; j>=0; j--)); do
                if [ "${description:$j:1}" = " " ]; then
                    cut_pos=$j
                    found_space=1
                    break
                fi
            done
            
            # Si no hay espacio, cortar forzosamente
            if [ $found_space -eq 0 ]; then
                cut_pos=$content_width
            fi
            
            # Extraer línea y actualizar descripción restante
            local line="${description:0:$cut_pos}"
            description="${description:$cut_pos}"
            
            # Quitar espacios iniciales de la descripción restante
            while [ "${description:0:1}" = " " ]; do
                description="${description:1}"
            done
            
            # Imprimir línea
            printf "%-*s" "$content_width" "$line"
            clear_to_end_of_line
        fi
        
        ((line_num++))
        ((current_y++))
    done
    
    # Limpiar líneas restantes de la descripción
    while [ $line_num -lt $max_desc_lines ]; do
        move_cursor $current_y $content_x
        printf "%*s" "$content_width" ""
        clear_to_end_of_line
        ((line_num++))
        ((current_y++))
    done
    
    # ----------------------------------------
    # Estado de instalación (al final)
    # ----------------------------------------
    local status_y=$((start_y + height - 1))
    move_cursor $status_y $content_x
    
    if [ ${INSTALLED_STATUS[$SELECTED_INDEX]} -eq 1 ]; then
        printf "${BG_VIOLET_DARK}${GREEN} ${CHECK} INSTALADO ${RESET}"
    else
        printf "${BG_VIOLET_DARK}${ORANGE} ${CIRCLE} NO INSTALADO ${RESET}"
    fi
}

# Dibuja la barra de estado inferior
function draw_status_bar() {
    local y=$((TERMINAL_HEIGHT - 1))
    
    # Contar seleccionados
    local selected_count=0
    local index
    
    for index in $(seq 1 $TOTAL_APPS); do
        if [ ${SELECTED_TO_INSTALL[$index]:-0} -eq 1 ]; then
            ((selected_count++))
        fi
    done
    
    # Limpiar línea completa
    move_cursor $y 1
    clear_entire_line
    
    # Sección izquierda: posición actual
    printf "${BG_VIOLET_DARK}${WHITE} %d/%d ${RESET}" "$SELECTED_INDEX" "$TOTAL_APPS"
    
    # Separador
    printf "${VIOLET} │ ${RESET}"
    
    # Contador de seleccionados
    printf "${MAGENTA_GLOW}%d seleccionados${RESET}" "$selected_count"
    
    # Calcular espacio para alinear ayuda a la derecha
    local help_text="a:todos │ c:limpiar │ Enter:instalar │ q:salir"
    local left_part=" $SELECTED_INDEX/$TOTAL_APPS  │ $selected_count seleccionados "
    local padding=$((TERMINAL_WIDTH - ${#left_part} - ${#help_text} - 2))
    
    # Rellenar espacio
    if [ $padding -gt 0 ]; then
        printf "%*s" $padding ""
    fi
    
    # Texto de ayuda
    printf "${GRAY}%s${RESET}" "$help_text"
    
    # Asegurar limpieza del final
    clear_to_end_of_line
}

# ============================================
# FUNCIONES DE INSTALACIÓN
# ============================================

# Instala un paquete usando pacman
function install_pacman() {
    local package="$1"
    
    echo ""
    echo -e "${CYAN}▶ Instalando ${BOLD}$package${RESET} ${CYAN}con pacman...${RESET}"
    echo ""
    
    sudo pacman -S --noconfirm --needed "$package"
    
    return $?
}

# Instala un paquete desde AUR usando yay
function install_yay() {
    local package="$1"
    
    # Verificar que yay esté instalado
    if ! command -v yay &>/dev/null; then
        echo ""
        echo -e "${ORANGE}⚠ yay no encontrado. Instalando primero...${RESET}"
        echo ""
        
        install_yay_helper
    fi
    
    echo ""
    echo -e "${CYAN}▶ Instalando ${BOLD}$package${RESET} ${CYAN}desde AUR...${RESET}"
    echo ""
    
    yay -S --noconfirm "$package"
    
    return $?
}

# Instala yay (helper de AUR)
function install_yay_helper() {
    echo -e "${CYAN}▶ Instalando dependencias...${RESET}"
    sudo pacman -S --needed --noconfirm git base-devel
    
    echo -e "${CYAN}▶ Clonando repositorio de yay...${RESET}"
    cd /tmp || return 1
    rm -rf yay 2>/dev/null
    git clone https://aur.archlinux.org/yay.git
    
    echo -e "${CYAN}▶ Compilando e instalando yay...${RESET}"
    cd yay || return 1
    makepkg -si --noconfirm
    
    cd ..
    rm -rf yay
    
    echo -e "${GREEN}✓ yay instalado correctamente${RESET}"
    echo ""
}

# Instala una aplicación individual
function install_single_app() {
    local index="$1"
    local app_name="${APPS[$index]}"
    
    # Limpiar pantalla para mostrar progreso
    clear_screen
    show_cursor
    
    # Encabezado de instalación
    echo ""
    echo -e "${VIOLET}╔══════════════════════════════════════════════════════════════╗${RESET}"
    printf "${VIOLET}║${RESET}  ${GOLD}${BOLD}Instalando:${RESET} %-48s ${VIOLET}║${RESET}\n" "$app_name"
    echo -e "${VIOLET}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Ejecutar instalación
    eval "${INSTALL_CMDS[$index]}"
    local result=$?
    
    echo ""
    
    # Mostrar resultado
    if [ $result -eq 0 ]; then
        INSTALLED_STATUS[$index]=1
        echo -e "${GREEN}${CHECK} ${BOLD}$app_name${RESET}${GREEN} instalado correctamente${RESET}"
    else
        echo -e "${RED}✗ Error instalando $app_name${RESET}"
    fi
    
    echo ""
    read -rp "$(echo -e "${VIOLET}Presiona Enter para continuar...${RESET}")"
    
    hide_cursor
}

# Instala múltiples aplicaciones seleccionadas
function install_batch_apps() {
    local to_install=()
    local index
    
    # Recopilar índices seleccionados que no estén instalados
    for index in $(seq 1 $TOTAL_APPS); do
        if [ ${SELECTED_TO_INSTALL[$index]:-0} -eq 1 ] && \
           [ ${INSTALLED_STATUS[$index]} -eq 0 ]; then
            to_install+=($index)
        fi
    done
    
    # Si no hay nada que instalar, salir
    if [ ${#to_install[@]} -eq 0 ]; then
        return
    fi
    
    # Limpiar pantalla
    clear_screen
    show_cursor
    
    # Encabezado
    echo ""
    echo -e "${VIOLET}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${VIOLET}║${RESET}           ${GOLD}${BOLD}INSTALACIÓN MÚLTIPLE${RESET}                               ${VIOLET}║${RESET}"
    echo -e "${VIOLET}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    
    # Instalar cada aplicación
    local idx
    for idx in "${to_install[@]}"; do
        printf "${CYAN}▶ ${BOLD}%s${RESET}\n" "${APPS[$idx]}"
        echo ""
        
        eval "${INSTALL_CMDS[$idx]}"
        
        if [ $? -eq 0 ]; then
            INSTALLED_STATUS[$idx]=1
            echo -e "${GREEN}  ✓ Completado${RESET}"
        else
            echo -e "${RED}  ✗ Fallido${RESET}"
        fi
        
        echo ""
    done
    
    # Resumen final
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}           ${BOLD}INSTALACIÓN FINALIZADA${RESET}                            ${GREEN}║${RESET}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${RESET}"
    
    # Limpiar selecciones
    for index in $(seq 1 $TOTAL_APPS); do
        SELECTED_TO_INSTALL[$index]=0
    done
    
    echo ""
    read -rp "$(echo -e "${VIOLET}Presiona Enter para continuar...${RESET}")"
    
    hide_cursor
}

# ============================================
# BUCLE PRINCIPAL
# ============================================

function main_loop() {
    local key
    local rest
    
    # Bucle infinito hasta que se presione 'q'
    while true; do
        # Actualizar dimensiones por si se redimensionó la terminal
        update_terminal_size
        
        # Redibujar toda la interfaz
        draw_header
        draw_left_panel
        draw_right_panel
        draw_status_bar
        
        # Leer tecla presionada
        IFS= read -rs -n1 key
        
        case "$key" in
            # ========================================
            # TECLAS DE NAVEGACIÓN (flechas)
            # ========================================
            $'\x1b')
                # Leer secuencia de escape completa
                read -rs -n2 rest
                
                case "$rest" in
                    '[A')  # Flecha arriba
                        if [ $SELECTED_INDEX -gt 1 ]; then
                            ((SELECTED_INDEX--))
                            
                            # Ajustar scroll si es necesario
                            if [ $SELECTED_INDEX -lt $SCROLL_OFFSET ]; then
                                ((SCROLL_OFFSET--))
                            fi
                        fi
                        ;;
                        
                    '[B')  # Flecha abajo
                        if [ $SELECTED_INDEX -lt $TOTAL_APPS ]; then
                            ((SELECTED_INDEX++))
                            
                            # Ajustar scroll si es necesario
                            if [ $SELECTED_INDEX -ge $((SCROLL_OFFSET + VISIBLE_ITEMS)) ]; then
                                ((SCROLL_OFFSET++))
                            fi
                        fi
                        ;;
                esac
                ;;
            
            # ========================================
            # ESPACIO: Toggle selección
            # ========================================
            ' ')
                if [ ${SELECTED_TO_INSTALL[$SELECTED_INDEX]:-0} -eq 1 ]; then
                    SELECTED_TO_INSTALL[$SELECTED_INDEX]=0
                else
                    SELECTED_TO_INSTALL[$SELECTED_INDEX]=1
                fi
                ;;
            
            # ========================================
            # ENTER: Instalar
            # ========================================
            '')
                local has_selection=0
                local idx
                
                # Verificar si hay selecciones batch
                for idx in $(seq 1 $TOTAL_APPS); do
                    if [ ${SELECTED_TO_INSTALL[$idx]:-0} -eq 1 ]; then
                        has_selection=1
                        break
                    fi
                done
                
                # Instalar según el modo
                if [ $has_selection -eq 1 ]; then
                    install_batch_apps
                else
                    install_single_app $SELECTED_INDEX
                fi
                
                # Limpiar pantalla al volver
                clear_screen
                ;;
            
            # ========================================
            # 'A': Seleccionar todos
            # ========================================
            'a'|'A')
                local idx
                for idx in $(seq 1 $TOTAL_APPS); do
                    if [ ${INSTALLED_STATUS[$idx]} -eq 0 ]; then
                        SELECTED_TO_INSTALL[$idx]=1
                    fi
                done
                ;;
            
            # ========================================
            # 'C': Limpiar selección
            # ========================================
            'c'|'C')
                local idx
                for idx in $(seq 1 $TOTAL_APPS); do
                    SELECTED_TO_INSTALL[$idx]=0
                done
                ;;
            
            # ========================================
            # 'Q': Salir
            # ========================================
            'q'|'Q')
                break
                ;;
        esac
    done
}

# ============================================
# FUNCIÓN PRINCIPAL
# ============================================

function main() {
    # Inicializar datos
    initialize_data
    
    # Configurar terminal
    update_terminal_size
    hide_cursor
    clear_screen
    
    # Ejecutar bucle principal
    main_loop
    
    # Restaurar terminal al salir
    show_cursor
    clear_screen
    
    # Mensaje de despedida
    echo ""
    echo -e "${VIOLET}✨ Instalador finalizado${RESET}"
    echo ""
}

# ============================================
# MANEJO DE SEÑALES
# ============================================

# Restaurar cursor y limpiar pantalla al salir
trap 'show_cursor; clear; exit 0' INT TERM EXIT

# ============================================
# INICIO DEL PROGRAMA
# ============================================

main
