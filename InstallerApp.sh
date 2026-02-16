#!/bin/bash

# ============================================
# Kit de Instalación para Arch Linux
# ============================================

# Colores para la terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
CHECKMARK="✓"

# Función para verificar si un paquete está instalado
check_installed() {
    if pacman -Q "$1" &>/dev/null || yay -Q "$1" &>/dev/null 2>/dev/null || flatpak list | grep -i "$1" &>/dev/null; then
        echo -e "${GREEN}${CHECKMARK}${NC}"
        return 0
    else
        echo " "
        return 1
    fi
}

# Función para instalar con pacman
install_pacman() {
    sudo pacman -S --noconfirm "$1"
}

# Función para instalar con yay
install_yay() {
    if ! command -v yay &>/dev/null; then
        echo -e "${RED}Error: yay no está instalado. Instalando yay primero...${NC}"
        install_yay_helper
    fi
    yay -S --noconfirm "$1"
}

# Función para instalar yay si no existe
install_yay_helper() {
    echo -e "${YELLOW}Instalando yay (AUR helper)...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
}

# Función para instalar con flatpak
install_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        echo -e "${YELLOW}Instalando Flatpak primero...${NC}"
        sudo pacman -S --noconfirm flatpak
    fi
    sudo flatpak install -y flathub "$1"
}

# ============================================
# LISTA DE APLICACIONES
# ============================================

declare -A apps
declare -A descriptions
declare -A install_cmds
declare -A pkg_names

# 1. Obsidian
apps[1]="Obsidian"
descriptions[1]="Editor de notas en Markdown con grafos de conocimiento, ideal para Zettelkasten y Second Brain"
pkg_names[1]="obsidian"
install_cmds[1]="install_yay obsidian"

# 2. Stacer
apps[2]="Stacer"
descriptions[2]="Administrador de sistema con interfaz gráfica: limpieza de archivos, monitor de recursos, gestor de startups"
pkg_names[2]="stacer"
install_cmds[2]="install_yay stacer"

# 3. OnlyOffice
apps[3]="OnlyOffice"
descriptions[3]="Suite ofimática compatible con MS Office, gratuita y de código abierto (alternativa a LibreOffice)"
pkg_names[3]="onlyoffice-bin"
install_cmds[3]="install_yay onlyoffice-bin"

# 4. Flathub (Flatpak)
apps[4]="Flatpak + Flathub"
descriptions[4]="Sistema de empaquetado universal para Linux con repositorio Flathub habilitado"
pkg_names[4]="flatpak"
install_cmds[4]="install_pacman flatpak && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"

# 5. WebCatalog
apps[5]="WebCatalog"
descriptions[5]="Convierte sitios web en aplicaciones de escritorio independientes (como PWAs pero nativas)"
pkg_names[5]="webcatalog"
install_cmds[5]="install_yay webcatalog"

# 6. Brave
apps[6]="Brave Browser"
descriptions[6]="Navegador web rápido con bloqueador de anuncios integrado y enfocado en privacidad"
pkg_names[6]="brave-bin"
install_cmds[6]="install_yay brave-bin"

# 7. KDE Connect
apps[7]="KDE Connect"
descriptions[7]="Conecta tu teléfono Android/iOS con tu PC: compartir archivos, notificaciones, control remoto"
pkg_names[7]="kdeconnect"
install_cmds[7]="install_pacman kdeconnect"

# 8. TimeShift
apps[8]="TimeShift"
descriptions[8]="Crea y restaura snapshots del sistema, ideal para recuperarse de actualizaciones fallidas"
pkg_names[8]="timeshift"
install_cmds[8]="install_pacman timeshift"

# ============================================
# MENÚ INTERACTIVO
# ============================================

clear
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      🛠️  KIT DE INSTALACIÓN PARA ARCH LINUX              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Instrucciones:${NC}"
echo "  [✓] = Ya instalado  |  [ ] = No instalado"
echo "  Ingresa los números de las apps que quieres instalar"
echo "  Ejemplo: 1 3 6  (para instalar Obsidian, OnlyOffice y Brave)"
echo "  Escribe 'all' para instalar todo o 'q' para salir"
echo ""

# Mostrar lista de apps con estado
for i in {1..8}; do
    status=$(check_installed "${pkg_names[$i]}")
    printf "  %s [%s] %d. %-20s %s\n" "$status" "$status" "$i" "${apps[$i]}" ""
    echo -e "      ${YELLOW}→${NC} ${descriptions[$i]}"
    echo ""
done

echo -e "${BLUE}────────────────────────────────────────────────────────────${NC}"
echo ""

# Leer selección del usuario
read -rp "Selecciona las aplicaciones (ej: 1 3 5): " selection

# Procesar selección
if [[ "$selection" == "q" ]]; then
    echo "Saliendo..."
    exit 0
elif [[ "$selection" == "all" ]]; then
    selected=(1 2 3 4 5 6 7 8)
else
    selected=($selection)
fi

echo ""
echo -e "${BLUE}Iniciando instalación...${NC}"
echo ""

# Instalar cada app seleccionada
for num in "${selected[@]}"; do
    if [[ -n "${apps[$num]}" ]]; then
        app_name="${apps[$num]}"
        echo -e "${YELLOW}▶ Instalando: $app_name${NC}"
        echo "  ${descriptions[$num]}"
        
        # Ejecutar comando de instalación
        eval "${install_cmds[$num]}"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $app_name instalado correctamente${NC}"
        else
            echo -e "${RED}✗ Error instalando $app_name${NC}"
        fi
        echo ""
    fi
done

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           🎉 INSTALACIÓN COMPLETADA 🎉                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
