#!/bin/bash

# Configuración de Colores
VIOLET='\033[38;5;93m'
V_BRIGHT='\033[38;5;141m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
RESET='\033[0m'
BOLD='\033[1m'

# Bucle infinito para que siempre regrese al inicio
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                                                      ┃"
    echo -e "┃                ${WHITE}T  O  M  E  X${VIOLET}                         ┃"
    echo -e "┃          ${V_BRIGHT}Minimalist System Manager${VIOLET}                   ┃"
    echo -e "┃                                                      ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"

    echo -e "\n${V_BRIGHT}── SCRIPTS LOCALES ──────────────────────────────────${RESET}"
    echo -e "${CYAN} [1]${WHITE} Ejecutar Instalador (ins.sh)${RESET}"
    echo -e "${CYAN} [2]${WHITE} Ejecutar Vanta Engine (vanta.sh)${RESET}"
    
    echo -e "\n${V_BRIGHT}── REPOSITORIOS EXTERNOS ────────────────────────────${RESET}"
    echo -e "${CYAN} [3]${WHITE} Clonar Repo y Ejecutar install.sh${RESET}"
    
    echo -e "\n${RED} [q] Salir de TOMEX${RESET}"
    echo -ne "\n${GOLD}⚡ Selección: ${RESET}"
    read opcion

    case $opcion in
        1)
            if [ -f "ins.sh" ]; then
                echo -e "${CYAN}➜ Iniciando ins.sh...${RESET}"
                chmod +x ins.sh
                ./ins.sh
            else
                echo -e "${RED}✘ Error: ins.sh no encontrado.${RESET}"
                sleep 2
            fi
            ;;
        2)
            if [ -f "vanta.sh" ]; then
                echo -e "${CYAN}➜ Iniciando vanta.sh...${RESET}"
                chmod +x vanta.sh
                ./vanta.sh
            else
                echo -e "${RED}✘ Error: vanta.sh no encontrado.${RESET}"
                sleep 2
            fi
            ;;
        3)
            echo -ne "${VIOLET}Pega la URL del repo: ${RESET}"
            read repo_url
            temp_dir="/tmp/repo_$(date +%s)"
            echo -e "${CYAN}➜ Clonando en $temp_dir...${RESET}"
            if git clone "$repo_url" "$temp_dir"; then
                cd "$temp_dir"
                if [ -f "install.sh" ]; then
                    chmod +x install.sh
                    ./install.sh
                else
                    echo -e "${RED}✘ No se encontró install.sh en el repo.${RESET}"
                fi
                cd - > /dev/null # Regresar a la carpeta de TOMEX
            else
                echo -e "${RED}✘ Error al clonar el repositorio.${RESET}"
            fi
            echo -e "${GOLD}Presiona Enter para volver a TOMEX...${RESET}"
            read
            ;;
        q|Q)
            echo -e "${VIOLET}Cerrando TOMEX Manager... Adiós.${RESET}"
            break # Rompe el bucle while y sale
            ;;
        *)
            echo -e "${RED}Opción inválida.${RESET}"
            sleep 1
            ;;
    esac
done
