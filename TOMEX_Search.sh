#!/bin/bash

# --- Configuración de Colores (Estilo TOMEX) ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# 1. Verificar dependencias necesarias para el buscador
if ! command -v fzf &>/dev/null; then
    echo -e "${VIOLET}Instalando motor de búsqueda (fzf)...${RESET}"
    sudo pacman -S --noconfirm fzf
fi

clear
echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "┃                ${WHITE}T  O  M  E  X   V 10.0${VIOLET}                ┃"
echo -e "┃             ${CYAN}UNIVERSAL REPO EXPLORER${VIOLET}                ┃"
echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
echo -e "${GOLD}  [TAB] para seleccionar varios | [ENTER] para instalar ${RESET}\n"

# --- FUNCIÓN DE BÚSQUEDA INTERACTIVA ---
# Combinamos Pacman y Yay, y usamos FZF para la interfaz de búsqueda
search_and_install() {
    # Obtenemos lista de paquetes de Pacman y AUR (yay)
    # Mostramos: Nombre | Repositorio | Descripción
    local SELECTION=$( (pacman -Sl; yay -Sl) | awk '{print $2 " [" $1 "]"}' | fzf \
        --multi \
        --height=80% \
        --border=rounded \
        --prompt="🔍 Buscar Programa: " \
        --header="Utiliza las flechas para navegar y TAB para marcar múltiples" \
        --color="bg+:-1,fg:white,hl:51,info:220,prompt:93,pointer:51,marker:82,header:93" \
        --preview="pacman -Si {1} 2>/dev/null || yay -Si {1}" \
        --preview-window=right:60% )

    if [ -n "$SELECTION" ]; then
        # Limpiar la selección para obtener solo los nombres
        local PKGS_TO_INSTALL=$(echo "$SELECTION" | awk '{print $1}' | tr '\n' ' ')
        
        clear
        echo -e "${VIOLET}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃              ${WHITE}PREPARANDO INSTALACIÓN${VIOLET}                ┃"
        echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
        echo -e "${CYAN}Paquetes elegidos:${WHITE} $PKGS_TO_INSTALL${RESET}\n"
        
        # Intentar instalar con yay (que maneja ambos repos)
        if yay -S --noconfirm $PKGS_TO_INSTALL; then
            echo -e "\n${GREEN}✔ ¡Todo se instaló correctamente!${RESET}"
        else
            echo -e "\n${RED}✘ Hubo un error en la instalación.${RESET}"
        fi
    else
        echo -e "${RED}Búsqueda cancelada.${RESET}"
    fi

    echo -e "\n${GOLD}Presiona ENTER para volver al menú...${RESET}"
    read
}

search_and_install
