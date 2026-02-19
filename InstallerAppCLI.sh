#!/bin/bash

# =================================================================
# ARCH CYBER-VIOLET - Navigator & Installer Edition
# =================================================================

# Colores Cyber-Violet
VIOLET='\033[0;35m'
B_VIOLET='\033[1;35m'
CYAN='\033[0;36m'
B_CYAN='\033[1;36m'
B_WHITE='\033[1;37m'
B_RED='\033[1;31m'
B_GREEN='\033[1;32m'
DIM='\033[2m'
RESET='\033[0m'

# Datos de los Programas (ID | Nombre | Descripción | Web | Método)
APPS_DATA=(
    "1" "Ranger" "Explorador de archivos TUI con atajos tipo Vim." "https://ranger.github.io" "pacman"
    "2" "Cava" "Visualizador de audio para terminal basado en barras." "https://github.com/karlstav/cava" "aur"
    "3" "fzf" "Buscador difuso de archivos y comandos ultra veloz." "https://github.com/junegunn/fzf" "pacman"
    "4" "Fastfetch" "Muestra información del sistema con logos ASCII." "https://github.com/fastfetch-cli/fastfetch" "pacman"
    "5" "Btop" "Monitor de recursos (CPU, RAM, Red) con gráficos." "https://github.com/aristocratos/btop" "pacman"
    "6" "TLDR" "Ejemplos prácticos de comandos (alternativa a man)." "https://tldr.sh" "pacman"
    "7" "Broot" "Navegación interactiva de directorios con búsqueda." "https://dystroy.org/broot" "pacman"
    "8" "Calcurse" "Organizador de calendario y notas para terminal." "https://calcurse.org" "pacman"
    "9" "Lolcat" "Colorea el texto de la terminal con arcoíris." "https://github.com/busyloop/lolcat" "pacman"
    "10" "Terminal-BG" "Cambia el fondo de la terminal por imágenes." "https://github.com/DaarcyDev/terminal-bg" "pipx"
    "11" "yt-dlp" "Potente descargador de video y audio de YouTube." "https://github.com/yt-dlp/yt-dlp" "pacman"
    "12" "Pandoc" "Conversor universal de documentos (MD, PDF, Docx)." "https://pandoc.org" "pacman"
    "13" "Joshuto" "Gestor de archivos rápido escrito en Rust." "https://github.com/kamiyaa/joshuto" "aur"
    "14" "Duf" "Visualizador de uso de disco moderno y colorido." "https://github.com/muesli/duf" "pacman"
)

# 1. REQUISITOS (Autoinstalación)
check_essentials() {
    clear
    echo -e "${B_VIOLET}Iniciando protocolos de sistema...${RESET}"
    [[ ! -f /usr/bin/whiptail ]] && sudo pacman -S --noconfirm libnewt
    [[ ! -f /usr/bin/git ]] && sudo pacman -S --noconfirm git base-devel
    if ! command -v yay &>/dev/null; then
        echo -e "${CYAN}➜ Instalando AUR Helper (YAY)...${RESET}"
        cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
    fi
}

# 2. FUNCIÓN PARA MOSTRAR LA TARJETA DE INFORMACIÓN
show_info_card() {
    local id=$1
    # Buscar datos en el array
    for ((i=0; i<${#APPS_DATA[@]}; i+=5)); do
        if [[ "${APPS_DATA[$i]}" == "$id" ]]; then
            local name="${APPS_DATA[$i+1]}"
            local desc="${APPS_DATA[$i+2]}"
            local web="${APPS_DATA[$i+3]}"
            
            whiptail --title " INFO: $name " --msgbox \
            "\nPROGRAMA: $name\n\nDESCRIPCIÓN:\n$desc\n\nSITIO WEB:\n$web\n\n(Presiona ENTER para volver)" 15 60
            return
        fi
    done
}

# 3. MENÚ DE INFORMACIÓN (CATÁLOGO)
info_catalog() {
    while true; do
        INFO_LIST=()
        for ((i=0; i<${#APPS_DATA[@]}; i+=5)); do
            INFO_LIST+=("${APPS_DATA[$i]}" "${APPS_DATA[$i+1]}")
        done

        ID_SELECT=$(whiptail --title " CATÁLOGO CYBER-VIOLET " \
            --menu "Selecciona un programa para ver sus detalles:" 20 60 12 \
            "${INFO_LIST[@]}" 3>&1 1>&2 2>&3)

        if [ $? -ne 0 ]; then break; fi
        show_info_card "$ID_SELECT"
    done
}

# 4. MENÚ DE INSTALACIÓN
install_menu() {
    CHECK_LIST=()
    for ((i=0; i<${#APPS_DATA[@]}; i+=5)); do
        CHECK_LIST+=("${APPS_DATA[$i+1]}" "${APPS_DATA[$i+2]}" OFF)
    done

    SELECTED=$(whiptail --title " INSTALADOR CYBER-VIOLET " \
        --separate-output --checklist "ESPACIO para marcar, ENTER para instalar:" 22 75 12 \
        "${CHECK_LIST[@]}" 3>&1 1>&2 2>&3)

    if [ $? -eq 0 ]; then
        process_install "$SELECTED"
    fi
}

# 5. PROCESO DE INSTALACIÓN REAL
process_install() {
    local to_install=$1
    clear
    echo -e "${B_VIOLET}⚡ EJECUTANDO CARGA DE SOFTWARE ⚡${RESET}\n"
    
    for item in $to_install; do
        echo -e "${B_CYAN}➜ Preparando: ${B_WHITE}$item${RESET}"
        
        # Buscar método de instalación
        for ((i=0; i<${#APPS_DATA[@]}; i+=5)); do
            if [[ "${APPS_DATA[$i+1]}" == "$item" ]]; then
                local method="${APPS_DATA[$i+4]}"
                case $method in
                    "pacman") sudo pacman -S --noconfirm --needed $(echo $item | tr '[:upper:]' '[:lower:]') ;;
                    "aur")    yay -S --noconfirm $(echo $item | tr '[:upper:]' '[:lower:]') ;;
                    "pipx")   pipx install git+https://github.com/DaarcyDev/terminal-bg.git ;;
                esac
            fi
        done
    done
    echo -e "\n${B_GREEN}✔ Instalación completada.${RESET}"
    read -p "Presiona Enter para volver al menú..."
}

# MAIN LOOP
check_essentials

while true; do
    CHOICE=$(whiptail --title " ARCH CYBER-VIOLET v2.0 " \
        --menu "Bienvenido al Kit de Herramientas CLI\n¿Qué deseas hacer?" 18 60 4 \
        "1" "VER CATÁLOGO (Info & Web)" \
        "2" "INSTALAR PROGRAMAS" \
        "3" "SALIR" 3>&1 1>&2 2>&3)

    case $CHOICE in
        1) info_catalog ;;
        2) install_menu ;;
        *) exit 0 ;;
    esac
done
