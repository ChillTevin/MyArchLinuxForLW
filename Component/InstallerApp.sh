#!/bin/bash

# =================================================================
# ARCH PURPLE TUI - Instalador Interactivo (Teclas de Flecha)
# =================================================================

# Colores para la terminal
VIOLET='\033[0;35m'
BOLD_VIOLET='\033[1;35m'
NC='\033[0m' # No Color

# Función para verificar e instalar requisitos básicos
pre_flight_check() {
    echo -e "${VIOLET}Comprobando requisitos del sistema...${NC}"
    
    # 1. Verificar Whiptail (necesario para el menú de flechas)
    if ! command -v whiptail &>/dev/null; then
        sudo pacman -S --noconfirm libnewt
    fi

    # 2. Verificar Base-devel y Git
    if ! pacman -Q base-devel git &>/dev/null; then
        sudo pacman -S --needed --noconfirm base-devel git
    fi

    # 3. Verificar Yay (AUR Helper)
    if ! command -v yay &>/dev/null; then
        echo -e "${VIOLET}Instalando yay automáticamente...${NC}"
        cd /tmp && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
    fi
}

pre_flight_check

# Definición de Aplicaciones
# Formato: "Etiqueta" "Descripción y Web" "Estado(ON/OFF)" "Comando"
# Nota: El comando se guarda en un array separado por conveniencia
APPS=(
    "Obsidian"    "Markdown Notas | obsidian.md"            OFF "yay -S --noconfirm obsidian"
    "Stacer"      "Optimización | github.com/stacer"        OFF "yay -S --noconfirm stacer"
    "OnlyOffice"  "Ofimática MS | onlyoffice.com"           OFF "yay -S --noconfirm onlyoffice-bin"
    "Brave"       "Navegador Privado | brave.com"           OFF "yay -S --noconfirm brave-bin"
    "KDEConnect"  "Sync Android/iOS | kdeconnect.kde.org"   OFF "sudo pacman -S --noconfirm kdeconnect"
    "TimeShift"   "Backups Sistema | github.com/timeshift"  OFF "sudo pacman -S --noconfirm timeshift"
    "WebCatalog"  "Webs a Apps | webcatalog.io"             OFF "yay -S --noconfirm webcatalog-bin"
    "Flatpak"     "Repo Universal | flatpak.org"            OFF "sudo pacman -S --noconfirm flatpak && sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo"
)

# Crear el menú interactivo con Whiptail
# Las flechas mueven, ESPACIO selecciona, TAB cambia a <Aceptar>
CHOICES=$(whiptail --title " ARCH PURPLE INSTALLER " \
    --separate-output \
    --checklist "\nUsa las FLECHAS para navegar y ESPACIO para seleccionar.\nPresiona ENTER para comenzar la instalación." \
    20 75 10 \
    "${APPS[0]}" "${APPS[1]}" "${APPS[2]}" \
    "${APPS[4]}" "${APPS[5]}" "${APPS[6]}" \
    "${APPS[8]}" "${APPS[9]}" "${APPS[10]}" \
    "${APPS[12]}" "${APPS[13]}" "${APPS[14]}" \
    "${APPS[16]}" "${APPS[17]}" "${APPS[18]}" \
    "${APPS[20]}" "${APPS[21]}" "${APPS[22]}" \
    "${APPS[24]}" "${APPS[25]}" "${APPS[26]}" \
    "${APPS[28]}" "${APPS[29]}" "${APPS[30]}" \
    3>&1 1>&2 2>&3)

# Salir si el usuario cancela (ESC o No)
if [ $? -ne 0 ]; then
    echo -e "${VIOLET}Operación cancelada.${NC}"
    exit 0
fi

# Procesar la instalación de los seleccionados
clear
echo -e "${BOLD_VIOLET}"
echo "      __              __      ____                 __"
echo "     / /_  ____  ____/ /___ _/ / /___  ____  _____/ /"
echo "    / __ \/ __ \/ __  / __ \/ / / __ \/ __ \/ ___/ / "
echo "   / / / / /_/ / /_/ / /_/ / / / /_/ / /_/ / /  /_/  "
echo "  /_/ /_/\____/\__,_/\__,_/_/_/\____/\____/_/  (_)   "
echo -e "                                         INSTALLER${NC}"
echo "------------------------------------------------------------"

for CHOICE in $CHOICES; do
    # Buscar el comando correspondiente a la etiqueta elegida
    for ((i=0; i<${#APPS[@]}; i+=4)); do
        if [[ "${APPS[$i]}" == "$CHOICE" ]]; then
            echo -e "${VIOLET}▶ Instalando: ${NC}$CHOICE..."
            eval "${APPS[$i+3]}"
            
            if [ $? -eq 0 ]; then
                echo -e "${BOLD_VIOLET}✔ $CHOICE completado.${NC}\n"
            else
                echo -e "\e[31m✘ Falló la instalación de $CHOICE${NC}\n"
            fi
        fi
    done
done

echo "------------------------------------------------------------"
echo -e "${BOLD_VIOLET}¡Proceso terminado! Pulsa cualquier tecla para salir.${NC}"
read -n 1
