#!/bin/bash

# --- Configuración de Colores ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# Seguridad: No ejecutar con sudo
if [ "$EUID" -eq 0 ]; then 
  echo -e "${RED}Error: Ejecuta el script sin sudo: ./TOMEX.sh${RESET}"
  exit 1
fi

# Directorio de trabajo
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$BASE_DIR"

# URL de Repositorio (Ruta de tu GitHub)
BRANCH_URL="https://raw.githubusercontent.com/ChillTevin/MyArchLinuxForLW/refs/heads/%F0%9D%93%A3%F0%9D%93%B8%F0%9D%93%B6%F0%9D%93%B2%F0%9D%94%81%F0%9D%93%90%F0%9D%93%BB%F0%9D%93%AC%F0%9D%93%B1"

# --- FUNCIÓN SMART (Gestión de Descargas y Ejecución) ---
run_smart() {
    local FILE=$1
    local URL=$2

    if [ ! -f "$FILE" ]; then
        echo -e "${CYAN}➜ Descargando $FILE...${RESET}"
        sudo wget -q --show-progress "$URL" -O "$FILE"
        sudo chown $USER:$USER "$FILE"
        chmod +x "$FILE"
    else
        echo -e "${GREEN}✔ $FILE detectado.${RESET}"
        chmod +x "$FILE"
    fi

    echo -e "${VIOLET}➜ Iniciando $FILE...${RESET}"
    bash "$BASE_DIR/$FILE"
    echo -e "\n${GOLD}➜ Proceso finalizado. Presiona ENTER...${RESET}"
    read
}

# --- NUEVA FUNCIÓN: TOOLS LOCALES ---
menu_tools() {
    local TOOLS_FILE="$BASE_DIR/tools.sh"
    
    # Si el archivo no existe, creamos una plantilla base para que no de error
    if [ ! -f "$TOOLS_FILE" ]; then
        echo -e "${CYAN}➜ Creando archivo tools.sh inicial...${RESET}"
        cat <<EOF > "$TOOLS_FILE"
#!/bin/bash
# --- ARCHIVO DE HERRAMIENTAS TOMEX ---
echo -e "\n${VIOLET}${BOLD}  HERRAMIENTAS DISPONIBLES${RESET}"
echo -e "  ${CYAN}1)${RESET} Limpiar cache de Pacman"
echo -e "  ${CYAN}2)${RESET} Verificar conexión"
echo -e "  ${CYAN}3)${RESET} Volver"
read -p "  Selecciona: " t_opt
case \$t_opt in
    1) sudo pacman -Sc --noconfirm ;;
    2) ping -c 3 google.com ;;
    3) exit 0 ;;
esac
EOF
        chmod +x "$TOOLS_FILE"
    fi

    # Ejecutar el archivo de herramientas
    bash "$TOOLS_FILE"
    echo -e "\n${GOLD}Presiona ENTER para volver a TOMEX...${RESET}"
    read
}

# --- SUBMENÚ: INSTALLERS ---
submenu_installers() {
    local SUB_OPCIONES=("InstallerApp.sh (GUI Mode)" "InstallerAppCLI.sh (CLI Mode)" "<-- Volver")
    local SUB_CURSOR=0
    while true; do
        clear
        echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃                ${WHITE}T O M E X  INSTALLERS${VIOLET}                 ┃"
        echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

        for i in "${!SUB_OPCIONES[@]}"; do
            if [ $i -eq $SUB_CURSOR ]; then
                echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${SUB_OPCIONES[$i]}  ${RESET}"
            else echo -e "     ${VIOLET}${SUB_OPCIONES[$i]}${RESET}"; fi
        done

        read -rsn1 key
        [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }
        case $key in
            $'\x1b[A') [ $SUB_CURSOR -gt 0 ] && ((SUB_CURSOR--)) ;;
            $'\x1b[B') [ $SUB_CURSOR -lt $((${#SUB_OPCIONES[@]}-1)) ] && ((SUB_CURSOR++)) ;;
            "") case $SUB_CURSOR in
                    0) run_smart "InstallerApp.sh" "$BRANCH_URL/InstallerApp.sh" ;;
                    1) run_smart "InstallerAppCLI.sh" "$BRANCH_URL/InstallerAppCLI.sh" ;;
                    2) return ;;
                esac ;;
        esac
    done
}

# --- MENÚ PRINCIPAL ---
MAIN_OPCIONES=("Installers" "Buscador (AUR/Pacman)" "Tools (Herramientas Locales)" "Instalar HyDE Project" "Salir")
CURSOR=0
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}T  O  M  E  X   V 10.7${VIOLET}                ┃"
    echo -e "┃           ${CYAN}Kinetic Navigation System${VIOLET}              ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!MAIN_OPCIONES[@]}"; do
        if [ $i -eq $CURSOR ]; then
            echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${MAIN_OPCIONES[$i]}  ${RESET}"
        else echo -e "     ${VIOLET}${MAIN_OPCIONES[$i]}${RESET}"; fi
    done

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }
    case $key in
        $'\x1b[A') [ $CURSOR -gt 0 ] && ((CURSOR--)) ;;
        $'\x1b[B') [ $CURSOR -lt $((${#MAIN_OPCIONES[@]}-1)) ] && ((CURSOR++)) ;;
        "") case $CURSOR in
                0) submenu_installers ;;
                1) run_smart "TOMEX_Search.sh" "$BRANCH_URL/TOMEX_Search.sh" ;;
                2) menu_tools ;; # <--- Nuestra nueva opción
                3) # HyDE Project
                    [[ ! -d "$HOME/HyDE" ]] && git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
                    cd ~/HyDE/Scripts && chmod +x install.sh && ./install.sh; cd "$BASE_DIR" ;;
                4) exit 0 ;;
            esac ;;
    esac
done