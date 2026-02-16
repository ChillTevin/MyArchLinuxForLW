#!/bin/bash

# ============================================
# KIT CLI INSTALLER - Arch Linux
# Estilo: Terminal Retro/Hacker
# ============================================

# Colores ANSI intensos
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# Colores brillantes
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BBLUE='\033[1;34m'
BMAGENTA='\033[1;35m'
BCYAN='\033[1;36m'
BWHITE='\033[1;37m'

# Símbolos
CHECK="▓▓▓"
BOX="█"
ARROW="➜"
STAR="★"
DOT="•"
LINE="─"
HEAVY="━"

# ============================================
# FUNCIONES DE DIBUJO
# ============================================

draw_box() {
    local width=$1
    local content=$2
    local color=$3
    
    echo -e "${color}┌$(printf '%*s' "$width" '' | tr ' ' "${HEAVY}")┐${RESET}"
    echo -e "${color}│${RESET} ${content} $(printf '%*s' $((width - ${#content} - 2)) '' | tr ' ' ' ')${color}│${RESET}"
    echo -e "${color}└$(printf '%*s' "$width" '' | tr ' ' "${HEAVY}")┘${RESET}"
}

draw_info_box() {
    local title=$1
    local desc=$2
    local status=$3
    local width=50
    
    local title_len=${#title}
    local padding=$(( (width - title_len - 4) / 2 ))
    
    # Borde superior con título
    echo -e "${CYAN}╭$(printf '%*s' "$padding" '' | tr ' ' '─')${BWHITE} ${title} ${CYAN}$(printf '%*s' $((width - padding - title_len - 2)) '' | tr ' ' '─')╮${RESET}"
    
    # Descripción con word wrap manual
    local remaining="$desc"
    while [ ${#remaining} -gt 0 ]; do
        if [ ${#remaining} -gt $((width - 4)) ]; then
            local line="${remaining:0:$((width - 4))}"
            # Cortar en el último espacio
            local last_space=$(echo "$line" | rev | grep -o " " | head -1)
            if [ -n "$last_space" ]; then
                local cut_pos=$((${#line} - $(echo "$line" | rev | grep -o -m1 " " | wc -c) + 1))
                line="${remaining:0:$cut_pos}"
                remaining="${remaining:$cut_pos}"
            else
                remaining="${remaining:$((width - 4))}"
            fi
        else
            local line="$remaining"
            remaining=""
        fi
        printf "${CYAN}│${RESET} ${DIM}%-$((width - 2))s${RESET}${CYAN}│${RESET}\n" "$line"
    done
    
    # Estado
    if [ "$status" = "installed" ]; then
        echo -e "${CYAN}├$(printf '%*s' "$width" '' | tr ' ' '─')┤${RESET}"
        printf "${CYAN}│${RESET} ${BGREEN}▓▓▓ INSTALADO${RESET}$(printf '%*s' $((width - 14)) '' | tr ' ' ' ')${CYAN}│${RESET}\n"
    else
        echo -e "${CYAN}├$(printf '%*s' "$width" '' | tr ' ' '─')┤${RESET}"
        printf "${CYAN}│${RESET} ${BRED}░░░ NO INSTALADO${RESET}$(printf '%*s' $((width - 17)) '' | tr ' ' ' ')${CYAN}│${RESET}\n"
    fi
    
    echo -e "${CYAN}╰$(printf '%*s' "$width" '' | tr ' ' '─')╯${RESET}"
}

# ============================================
# FUNCIONES DE UTILIDAD
# ============================================

check_installed() {
    if pacman -Q "$1" &>/dev/null || command -v "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

install_pacman() {
    echo -e "${BYELLOW}${ARROW} Instalando con pacman...${RESET}"
    sudo pacman -S --noconfirm --needed "$1"
}

install_aur() {
    echo -e "${BYELLOW}${ARROW} Instalando desde AUR...${RESET}"
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        echo -e "${BRED}✗ No se encontró yay/paru. Instalando yay...${RESET}"
        install_yay
    fi
    if command -v yay &>/dev/null; then
        yay -S --noconfirm "$1"
    else
        paru -S --noconfirm "$1"
    fi
}

install_yay() {
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp || exit
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

install_pipx() {
    echo -e "${BYELLOW}${ARROW} Instalando con pipx...${RESET}"
    pipx install "$1"
}

# ============================================
# DEFINICIÓN DE APLICACIONES
# ============================================

declare -A apps
declare -A descriptions
declare -A categories
declare -A install_methods
declare -A pkg_names

# 1. Ranger
apps[1]="Ranger"
descriptions[1]="Explorador de archivos TUI con preview, bookmarks y atajos de Vim. Navegación rápida con hjkl."
categories[1]="FILE_MANAGER"
install_methods[1]="pacman"
pkg_names[1]="ranger"

# 2. Cava
apps[2]="Cava"
descriptions[2]="Visualizador de audio en tiempo real. Barras que bailan con la música del sistema."
categories[2]="MULTIMEDIA"
install_methods[2]="aur"
pkg_names[2]="cava"

# 3. fzf
apps[3]="fzf"
descriptions[3]="Fuzzy finder interactivo. Busca archivos, historial, procesos con filtros inteligentes y rápidos."
categories[3]="SEARCH"
install_methods[3]="pacman"
pkg_names[3]="fzf"

# 4. fastfetch
apps[4]="Fastfetch"
descriptions[4]="Neofetch pero en C, ultra rápido. Muestra info del sistema con logos de distros en ASCII art."
categories[4]="SYSTEM"
install_methods[4]="pacman"
pkg_names[4]="fastfetch"

# 5. Btop
apps[5]="Btop"
descriptions[5]="Monitor de recursos con gráficos. CPU, RAM, red, discos con interfaz elegante y temas."
categories[5]="MONITOR"
install_methods[5]="pacman"
pkg_names[5]="btop"

# 6. TLDR
apps[6]="TLDR"
descriptions[6]="Resúmenes prácticos de comandos. Ejemplos comunes sin leer man pages completos."
categories[6]="HELP"
install_methods[6]="pacman"
pkg_names[6]="tldr"

# 7. bpytop
apps[7]="Bpytop"
descriptions[7]="Versión Python de htop mejorado. Gráficos históricos, filtros, temas personalizables."
categories[7]="MONITOR"
install_methods[7]="pacman"
pkg_names[7]="bpytop"

# 8. Broot
apps[8]="Broot"
descriptions[8]="Navegador de directorios con búsqueda fuzzy. Encuentra archivos rápido sin cd constante."
categories[8]="FILE_MANAGER"
install_methods[8]="pacman"
pkg_names[8]="broot"

# 9. calcurse
apps[9]="Calcurse"
descriptions[9]="Agenda y calendario TUI. Eventos, appointments, todo list con sincronización CalDAV."
categories[9]="PRODUCTIVITY"
install_methods[9]="pacman"
pkg_names[9]="calcurse"

# 10. lolcat
apps[10]="Lolcat"
descriptions[10]="Arcoíris en tu terminal. Pipea cualquier output para ver texto degradado animado."
categories[10]="FUN"
install_methods[10]="pacman"
pkg_names[10]="lolcat"

# 11. terminal-bg
apps[11]="Terminal-BG"
descriptions[11]="Cambia el fondo de la terminal con imágenes. Soporte para kitty, alacritty, etc."
categories[11]="CUSTOMIZATION"
install_methods[11]="pipx"
pkg_names[11]="git+https://github.com/DaarcyDev/terminal-bg.git"

# 12. yt-dlp
apps[12]="yt-dlp"
descriptions[12]="Descarga videos de YouTube y 1000+ sitios. Fork activo de youtube-dl, más rápido y features."
categories[12]="DOWNLOAD"
install_methods[12]="pacman"
pkg_names[12]="yt-dlp"

# 13. Pandoc
apps[13]="Pandoc"
descriptions[13]="Conversor universal de documentos. Markdown a PDF, DOCX, LaTeX, HTML y viceversa."
categories[13]="DOCUMENT"
install_methods[13]="pacman"
pkg_names[13]="pandoc"

# 14. Joshuto
apps[14]="Joshuto"
descriptions[14]="Explorador tipo ranger pero en Rust. Más rápido, preview de imágenes, async operations."
categories[14]="FILE_MANAGER"
install_methods[14]="aur"
pkg_names[14]="joshuto"

# 15. DUF
apps[15]="Duf"
descriptions[15]="Mejor 'df -h'. Uso de disco con gráficos de barras, filtros por filesystem, colores intuitivos."
categories[15]="SYSTEM"
install_methods[15]="pacman"
pkg_names[15]="duf"

# ============================================
# HEADER ART
# ============================================

clear

echo -e "${MAGENTA}"
cat << "EOF"
    ██╗  ██╗██╗████████╗     ██████╗██╗     ██╗
    ██║ ██╔╝██║╚══██╔══╝    ██╔════╝██║     ██║
    █████╔╝ ██║   ██║       ██║     ██║     ██║
    ██╔═██╗ ██║   ██║       ██║     ██║     ██║
    ██║  ██╗██║   ██║       ╚██████╗███████╗██║
    ╚═╝  ╚═╝╚═╝   ╚═╝        ╚═════╝╚══════╝╚═╝
EOF
echo -e "${RESET}"

echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BCYAN}║${RESET}  ${BWHITE}⚡ KIT DE APLICACIONES CLI PARA TERMINALES PODEROSAS ⚡${RESET}        ${BCYAN}║${RESET}"
echo -e "${BCYAN}╠══════════════════════════════════════════════════════════════════╣${RESET}"
echo -e "${BCYAN}║${RESET}  ${DIM}Navega con las flechas o números. 'a' para todos. 'q' salir.${RESET}  ${BCYAN}║${RESET}"
echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# ============================================
# MOSTRAR APLICACIONES
# ============================================

for i in {1..15}; do
    # Determinar color de categoría
    case "${categories[$i]}" in
        "FILE_MANAGER") cat_color="${BYELLOW}" ;;
        "MULTIMEDIA") cat_color="${BMAGENTA}" ;;
        "SEARCH") cat_color="${BGREEN}" ;;
        "SYSTEM") cat_color="${BCYAN}" ;;
        "MONITOR") cat_color="${BRED}" ;;
        "HELP") cat_color="${BBLUE}" ;;
        "PRODUCTIVITY") cat_color="${BYELLOW}" ;;
        "FUN") cat_color="${BMAGENTA}" ;;
        "CUSTOMIZATION") cat_color="${BCYAN}" ;;
        "DOWNLOAD") cat_color="${BGREEN}" ;;
        "DOCUMENT") cat_color="${BWHITE}" ;;
        *) cat_color="${WHITE}" ;;
    esac
    
    # Verificar instalación
    installed=false
    if check_installed "${pkg_names[$i]}" || [ -f "/usr/bin/${pkg_names[$i]}" ] || [ -f "/usr/local/bin/${pkg_names[$i]}" ]; then
        installed=true
    fi
    
    # Número con color
    printf "${BWHITE}[%2d]${RESET} " "$i"
    
    # Nombre de app
    printf "${BOLD}%-12s${RESET} " "${apps[$i]}"
    
    # Categoría tag
    printf "${cat_color}[%s]${RESET} " "${categories[$i]}"
    
    # Indicador de instalación
    if $installed; then
        printf "${BGREEN}▓▓▓${RESET}  "
        status="installed"
    else
        printf "${DIM}░░░${RESET}  "
        status="not_installed"
    fi
    
    echo ""
    
    # Caja de descripción
    draw_info_box "${apps[$i]}" "${descriptions[$i]}" "$status"
    
    echo ""
done

# ============================================
# SELECCIÓN
# ============================================

echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BCYAN}║${RESET}  ${BYELLOW}COMANDOS:${RESET}                                                       ${BCYAN}║${RESET}"
echo -e "${BCYAN}║${RESET}  ${BWHITE}1-15${RESET} = Seleccionar número  |  ${BWHITE}a${RESET} = Todo  |  ${BWHITE}q${RESET} = Salir          ${BCYAN}║${RESET}"
echo -e "${BCYAN}║${RESET}  ${BWHITE}Ej:${RESET} ${CYAN}1 3 5 7${RESET} instala varios  |  ${BWHITE}Ej:${RESET} ${CYAN}2-6${RESET} instala rango      ${BCYAN}║${RESET}"
echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

read -rp "$(echo -e "${BWHITE}➜ Selección:${RESET} ")" selection

# Procesar selección
selected=()

if [[ "$selection" == "q" ]]; then
    echo -e "\n${BRED}✗ Cancelado${RESET}"
    exit 0
elif [[ "$selection" == "a" || "$selection" == "all" ]]; then
    selected=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
elif [[ "$selection" == *"-"* ]]; then
    # Rango (ej: 2-6)
    start=$(echo "$selection" | cut -d'-' -f1)
    end=$(echo "$selection" | cut -d'-' -f2)
    for ((i=start; i<=end; i++)); do
        selected+=($i)
    done
else
    selected=($selection)
fi

# ============================================
# INSTALACIÓN
# ============================================

echo ""
echo -e "${BCYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BCYAN}║${RESET}           ${BGREEN}⚡ INICIANDO INSTALACIÓN ⚡${RESET}                           ${BCYAN}║${RESET}"
echo -e "${BCYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
echo ""

# Pre-instalación especial para terminal-bg
if [[ " ${selected[*]} " =~ " 11 " ]]; then
    echo -e "${BYELLOW}▶ Preparando dependencias para Terminal-BG...${RESET}"
    install_pacman "python-pipx"
    pipx ensurepath
    sudo pipx ensurepath --global 2>/dev/null || true
    echo ""
fi

for num in "${selected[@]}"; do
    if [[ -n "${apps[$num]}" ]]; then
        app_name="${apps[$num]}"
        pkg="${pkg_names[$num]}"
        method="${install_methods[$num]}"
        
        echo -e "${BCYAN}┌────────────────────────────────────────────────────────────┐${RESET}"
        printf "${BCYAN}│${RESET} ${BWHITE}%-58s${RESET} ${BCYAN}│${RESET}\n" "INSTALANDO: $app_name"
        echo -e "${BCYAN}└────────────────────────────────────────────────────────────┘${RESET}"
        
        case "$method" in
            "pacman")
                install_pacman "$pkg"
                ;;
            "aur")
                install_aur "$pkg"
                ;;
            "pipx")
                install_pipx "$pkg"
                ;;
        esac
        
        if [ $? -eq 0 ]; then
            echo -e "${BGREEN}✓ $app_name instalado correctamente${RESET}"
        else
            echo -e "${BRED}✗ Error instalando $app_name${RESET}"
        fi
        echo ""
    fi
done

# ============================================
# FOOTER
# ============================================

echo -e "${BGREEN}"
cat << "EOF"
    ██╗   ██╗███████╗██╗   ██╗██╗      ██████╗ ███████╗██████╗ 
    ██║   ██║██╔════╝██║   ██║██║     ██╔═══██╗██╔════╝██╔══██╗
    ██║   ██║█████╗  ██║   ██║██║     ██║   ██║█████╗  ██████╔╝
    ╚██╗ ██╔╝██╔══╝  ██║   ██║██║     ██║   ██║██╔══╝  ██╔══██╗
     ╚████╔╝ ███████╗╚██████╔╝███████╗╚██████╔╝███████╗██║  ██║
      ╚═══╝  ╚══════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝
EOF
echo -e "${RESET}"

echo -e "\n${BCYAN}Recomendación:${RESET} ${DIM}Reinicia tu terminal o ejecuta 'source ~/.bashrc' para cargar nuevos paths${RESET}"
echo -e "${BYELLOW}Pro tip:${RESET} ${DIM}Prueba 'ranger' para explorar archivos o 'btop' para ver recursos${RESET}\n"
