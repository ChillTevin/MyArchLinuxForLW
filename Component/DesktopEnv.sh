#!/bin/bash

# --- Configuración de Colores ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
GRAY='\033[38;5;244m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Recepción del Idioma ---
# Tomamos el primer argumento que envía TOMEX.sh ($1). Si está vacío, por defecto es 0 (Español)
idx_lang=${1:-0} 

case $idx_lang in
    0) title="E N T O R N O S   G R Á F I C O S"
       sub="Selecciona tu nueva experiencia"
       f_nav="Navegar"
       f_sel="Instalar"
       f_back="Volver al Menú" ;;
    1) title="D E S K T O P   E N V I R O N M E N T S"
       sub="Select your new experience"
       f_nav="Navigate"
       f_sel="Install"
       f_back="Back to Menu" ;;
    2) title="桌  面  环  境"
       sub="选择您的新体验"
       f_nav="导航"
       f_sel="安装"
       f_back="返回主菜单" ;;
esac

# --- Base de Datos de Entornos ---
envs=(
    "GNOME"                 "Pantheon" 
    "KDE Plasma"            "UKUI" 
    "Xfce"                  "Enlightenment" 
    "LXDE"                  "Trinity (TDE)" 
    "LXQt"                  "Cutefish" 
    "Cinnamon"              "Sugar" 
    "MATE"                  "Lumina" 
    "Budgie"                "Phosh" 
    "Deepin"                "<-- $f_back"
)

# Comandos de instalación automatizados (incluye el Display Manager óptimo para cada uno)
cmds=(
    "sudo pacman -S --needed --noconfirm gnome gnome-extra gdm"             # GNOME
    "yay -S --needed --noconfirm pantheon-session-git lightdm"              # Pantheon (AUR)
    "sudo pacman -S --needed --noconfirm plasma-meta sddm"                  # KDE
    "sudo pacman -S --needed --noconfirm ukui lightdm"                      # UKUI
    "sudo pacman -S --needed --noconfirm xfce4 xfce4-goodies lightdm"       # Xfce
    "sudo pacman -S --needed --noconfirm enlightenment terminology lightdm" # Enlightenment
    "sudo pacman -S --needed --noconfirm lxde lxdm"                         # LXDE
    "yay -S --needed --noconfirm tde-base"                                  # Trinity (AUR)
    "sudo pacman -S --needed --noconfirm lxqt sddm"                         # LXQt
    "sudo pacman -S --needed --noconfirm cutefish sddm"                     # Cutefish
    "sudo pacman -S --needed --noconfirm cinnamon lightdm"                  # Cinnamon
    "sudo pacman -S --needed --noconfirm sugar sugar-fructose"              # Sugar
    "sudo pacman -S --needed --noconfirm mate mate-extra lightdm"           # MATE
    "yay -S --needed --noconfirm lumina-desktop"                            # Lumina (AUR)
    "sudo pacman -S --needed --noconfirm budgie-desktop lightdm"            # Budgie
    "sudo pacman -S --needed --noconfirm phosh"                             # Phosh
    "sudo pacman -S --needed --noconfirm deepin deepin-extra lightdm"       # Deepin
    "volver"
)

sel=0
total=${#envs[@]}
tput civis # Ocultar cursor

while true; do
    clear
    # Header Dinámico
    echo -e "${VIOLET}${BOLD}  ╔══════════════════════════════════════════════════════╗"
    echo -e "  ║          ${WHITE}${title}${VIOLET}           ║"
    echo -e "  ║           ${CYAN}${sub}${VIOLET}            ║"
    echo -e "  ╚══════════════════════════════════════════════════════╝${RESET}\n"

    # Imprimir en 2 columnas (9 filas x 2 columnas = 18 items)
    for (( i=0; i<9; i++ )); do
        idx1=$((i * 2))       # Izquierda (0, 2, 4...)
        idx2=$((i * 2 + 1))   # Derecha (1, 3, 5...)

        # Formatear Columna Izquierda
        if [ "$sel" -eq "$idx1" ]; then
            str1=$(printf "${BG_SELECT}${GOLD}${BOLD}  ➜ %-22s ${RESET}" "${envs[$idx1]}")
        else
            str1=$(printf "    ${VIOLET}%-22s${RESET}" "${envs[$idx1]}")
        fi

        # Formatear Columna Derecha
        if [ "$idx2" -lt "$total" ]; then
            if [ "$sel" -eq "$idx2" ]; then
                str2=$(printf "${BG_SELECT}${GOLD}${BOLD}  ➜ %-22s ${RESET}" "${envs[$idx2]}")
            else
                str2=$(printf "    ${VIOLET}%-22s${RESET}" "${envs[$idx2]}")
            fi
        else
            str2=""
        fi

        echo -e "  $str1 $str2"
    done

    echo -e "\n  ${GRAY}[↑/↓/←/→] $f_nav   [Enter] $f_sel${RESET}"

    read -rsn1 tecla
    [[ $tecla == $'\e' ]] && { read -rsn2 r; tecla+="$r"; }

    # Lógica de matriz bidimensional (2 columnas)
    case "$tecla" in
        $'\e[A') sel=$(( (sel + total - 2) % total )) ;; # Arriba
        $'\e[B') sel=$(( (sel + 2) % total )) ;;         # Abajo
        $'\e[D') sel=$(( (sel + total - 1) % total )) ;; # Izquierda
        $'\e[C') sel=$(( (sel + 1) % total )) ;;         # Derecha
        "") 
            if [ "${cmds[$sel]}" == "volver" ]; then
                clear; tput cnorm; exit 0
            else
                clear
                tput cnorm
                echo -e "${VIOLET}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
                echo -e "${CYAN} ➜ Preparando: ${WHITE}${envs[$sel]}${RESET}"
                echo -e "${GRAY} ➜ Ejecutando: ${cmds[$sel]}${RESET}"
                echo -e "${VIOLET}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
                
                # Ejecuta el comando de instalación
                eval "${cmds[$sel]}"
                
                # Activa automáticamente el Display Manager (ej. GDM, SDDM) según el entorno
                if [[ "${cmds[$sel]}" == *"sddm"* ]]; then sudo systemctl enable sddm -f; fi
                if [[ "${cmds[$sel]}" == *"gdm"* ]]; then sudo systemctl enable gdm -f; fi
                if [[ "${cmds[$sel]}" == *"lightdm"* ]]; then sudo systemctl enable lightdm -f; fi
                if [[ "${cmds[$sel]}" == *"lxdm"* ]]; then sudo systemctl enable lxdm -f; fi

                echo -e "\n${GOLD}➜ Instalación finalizada. Presiona ENTER para continuar...${RESET}"
                read
                tput civis # Ocultar de nuevo al volver al sub-menú
            fi
            ;;
    esac
done