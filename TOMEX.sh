#!/bin/bash

# --- Configuración de Colores ---
VIOLET='\033[38;5;93m'
V_BRIGHT='\033[38;5;141m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
RESET='\033[0m'
BOLD='\033[1m'

# Función para el efecto Arcoiris al salir
rainbow_exit() {
    clear
    TEXT=">>> GRACIAS POR USAR TOMEX MANAGER - CERRANDO SESION <<<"
    COLORS=(196 202 226 190 82 21 93)
    for (( i=0; i<${#TEXT}; i++ )); do
        color=${COLORS[$((i % ${#COLORS[@]}))]}
        echo -ne "\033[38;5;${color}m${TEXT:$i:1}"
    done
    echo -e "${RESET}\n"
    sleep 2
    exit 0
}

# --- Bucle Principal ---
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                                                      ┃"
    echo -e "┃                ${WHITE}T  O  M  E  X${VIOLET}                         ┃"
    echo -e "┃          ${V_BRIGHT}Power Edition System Manager${VIOLET}                ┃"
    echo -e "┃                                                      ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"

    echo -e "\n${V_BRIGHT}── SCRIPTS DE INSTALACIÓN ───────────────────────────${RESET}"
    echo -e "${CYAN} [1]${WHITE} Iniciar InstallerApp.sh (GUI Mode)${RESET}"
    echo -e "${CYAN} [2]${WHITE} Iniciar InstallerAppCLI.sh (Terminal Mode)${RESET}"
    
    echo -e "\n${V_BRIGHT}── PROYECTOS EXTERNOS ───────────────────────────────${RESET}"
    echo -e "${CYAN} [3]${WHITE} Instalar HyDE Project (Automático)${RESET}"
    
    echo -e "\n${V_BRIGHT}── GESTIÓN DE REPOSITORIO ───────────────────────────${RESET}"
    echo -e "${CYAN} [4]${WHITE} Sincronizar y Subir cambios a GitHub${RESET}"
    
    echo -e "\n${RED} [q] Salir (Modo Arcoiris)${RESET}"
    echo -ne "\n${GOLD}⚡ Selección: ${RESET}"
    read opcion

    case $opcion in
        1)
            if [ -f "InstallerApp.sh" ]; then
                echo -e "${CYAN}➜ Lanzando InstallerApp.sh...${RESET}"
                chmod +x InstallerApp.sh && ./InstallerApp.sh
            else
                echo -e "${RED}✘ Error: InstallerApp.sh no encontrado.${RESET}"
                sleep 2
            fi
            ;;
        2)
            if [ -f "InstallerAppCLI.sh" ]; then
                echo -e "${CYAN}➜ Lanzando InstallerAppCLI.sh...${RESET}"
                chmod +x InstallerAppCLI.sh && ./InstallerAppCLI.sh
            else
                echo -e "${RED}✘ Error: InstallerAppCLI.sh no encontrado.${RESET}"
                sleep 2
            fi
            ;;
        3)
            echo -e "${CYAN}➜ Iniciando despliegue de HyDE Project...${RESET}"
            sudo git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
            cd ~/HyDE/Scripts
            chmod +x install.sh
            ./install.sh
            cd $GITHUB_WORKSPACE # Regresar al repo principal tras terminar
            echo -e "${GOLD}Presiona Enter para volver a TOMEX...${RESET}"
            read
            ;;
        4)
            echo -e "${CYAN}➜ Arreglando permisos y sincronizando...${RESET}"
            sudo chown -R $(whoami):$(whoami) .
            git add .
            git commit -m "Auto-save desde TOMEX: $(date +'%H:%M')"
            git push origin HEAD
            echo -e "${GREEN}✔ Cambios subidos correctamente.${RESET}"
            sleep 2
            ;;
        q|Q)
            rainbow_exit
            ;;
        *)
            echo -e "${RED}Opción no válida.${RESET}"
            sleep 1
            ;;
    esac
done
