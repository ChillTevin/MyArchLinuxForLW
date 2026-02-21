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

# --- Variables Globales ---
WINE_ENVS=("Glibc" "Bionic")
IDX_WINE=0
CURSOR=0

# Rutas por defecto (pueden ser cambiadas por el usuario)
PREFIX_DIR="$HOME/.wine_custom"

# --- FUNCIÓN 1: INICIALIZAR Y ELEGIR RUTA ---
init_env() {
    clear
    local env_name="${WINE_ENVS[$IDX_WINE]}"
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃          📦 INICIALIZAR ENTORNO: $env_name                ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    
    echo -e "${CYAN}➜ Por defecto, el entorno se crea en: $HOME/.wine_$env_name${RESET}"
    # read -e permite autocompletado con la tecla TAB
    read -e -p "➜ Introduce la ruta donde crear la carpeta (o presiona Enter para usar la por defecto): " custom_path
    
    if [ -z "$custom_path" ]; then
        PREFIX_DIR="$HOME/.wine_$env_name"
    else
        # Expande la tilde ~ si el usuario la usó
        PREFIX_DIR=$(eval echo "$custom_path")
    fi

    echo -e "\n${CYAN}➜ Creando estructura en: ${GOLD}$PREFIX_DIR${RESET}"
    mkdir -p "$PREFIX_DIR"
    export WINEPREFIX="$PREFIX_DIR"
    export WINEARCH=win64

    echo -e "${GOLD}➜ Ejecutando Wineboot (Configurando registro de Windows)...${RESET}"
    wineboot -u
    
    echo -e "\n${GREEN}✔ Entorno $env_name listo en $PREFIX_DIR.${RESET}"
    echo -e "${CYAN}Presiona ENTER para volver...${RESET}"; read
}

# --- FUNCIÓN 2: EJECUTAR APP (.EXE EN ROJO) ---
run_exe() {
    clear
    local env_name="${WINE_ENVS[$IDX_WINE]}"
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃          🚀 EJECUTAR APLICACIÓN WINDOWS              ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    
    echo -e "${CYAN}➜ Selecciona el archivo ejecutable. Puedes arrastrar el archivo a la terminal.${RESET}"
    read -e -p "Ruta del archivo: " exe_path
    exe_path=$(eval echo "$exe_path") # Limpiar comillas o expandir rutas

    if [ -f "$exe_path" ]; then
        export WINEPREFIX="$PREFIX_DIR"
        local nombre_exe=$(basename "$exe_path")
        
        echo -e "\n${GREEN}➜ Lanzando en entorno [$env_name]: ${RED}${BOLD}$nombre_exe${RESET}"
        wine "$exe_path" &> /dev/null &
        echo -e "${GOLD}Proceso iniciado en segundo plano. Presiona ENTER para volver...${RESET}"
        read
    else
        echo -e "\n${RED}❌ Error: El archivo ejecutable no existe o la ruta es inválida.${RESET}"
        sleep 2
    fi
}

# --- FUNCIÓN 3: SETTING WINE (ESTILO WINLATOR) ---
settings_wine() {
    local set_cursor=0
    local set_opciones=(
        "Resolución de pantalla (Virtual Desktop)"
        "Modo Gráfico (GPU / DXVK / Vulkan)"
        "Asignación de CPU y RAM"
        "Compatibilidad de Audio"
        "Directorio de instalación (Gestor de Unidades)"
        "Controladores y Entrada (Mandos/Teclado)"
        "Compatibilidad con librerías (Winetricks)"
        "Perfiles de Configuración"
        "<-- Volver al Manager"
    )

    while true; do
        clear
        echo -e "${GOLD}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃                 ⚙️  SETTING WINE                     ┃"
        echo -e "┃         ${WHITE}Advanced Emulation Configuration${GOLD}             ┃"
        echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

        for i in "${!set_opciones[@]}"; do
            if [ $i -eq $set_cursor ]; then
                echo -e "${BG_SELECT}${CYAN}  ➜  ${WHITE}${BOLD}${set_opciones[$i]}  ${RESET}"
            else
                echo -e "     ${GOLD}${set_opciones[$i]}${RESET}"
            fi
        done

        read -rsn1 k; [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }
        case $k in
            $'\x1b[A') [ $set_cursor -gt 0 ] && ((set_cursor--)) ;;
            $'\x1b[B') [ $set_cursor -lt $((${#set_opciones[@]}-1)) ] && ((set_cursor++)) ;;
            "") 
                # Acciones del submenú Settings (Simuladas/Preparadas para comandos reales)
                export WINEPREFIX="$PREFIX_DIR"
                case $set_cursor in
                    0) echo -e "${CYAN}Abriendo panel de resolución (winecfg)...${RESET}"; winecfg & ;;
                    1) echo -e "${CYAN}Instalando renderizador Vulkan (DXVK)...${RESET}"; winetricks dxvk ;;
                    2) echo -e "${CYAN}Configurando Taskset (Núcleos CPU)...${RESET}"; sleep 1 ;;
                    3) echo -e "${CYAN}Ajustando latencia de PulseAudio/ALSA...${RESET}"; wine regedit ;;
                    4) echo -e "${CYAN}Mapeando discos Z: y C:...${RESET}"; winecfg ;;
                    5) echo -e "${CYAN}Configurando XInput para mandos...${RESET}"; winetricks xinput ;;
                    6) echo -e "${CYAN}Abriendo instalador de librerías (.NET, DirectX)...${RESET}"; winetricks ;;
                    7) echo -e "${CYAN}Guardando perfil actual...${RESET}"; sleep 1 ;;
                    8) return ;;
                esac
                echo -e "${GREEN}Configuración aplicada.${RESET}"; sleep 1 ;;
        esac
    done
}

# --- BUCLE PRINCIPAL ---
OPCIONES=(
    "Choose Environment" 
    "Initialize / Fix Environment" 
    "Run Windows App (.exe)" 
    "Setting Wine" 
    "Back to Tools"
)

while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃             🍷  WINE ENVIRONMENT MANAGER             ┃"
    echo -e "┃           ${CYAN}Isolation & Compatibility System${VIOLET}           ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!OPCIONES[@]}"; do
        if [ $i -eq $CURSOR ]; then
            if [ $i -eq 0 ]; then
                echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${OPCIONES[$i]}: ${CYAN}< ${WINE_ENVS[$IDX_WINE]} >${RESET}"
            else
                echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${OPCIONES[$i]}  ${RESET}"
            fi
        else
            if [ $i -eq 0 ]; then
                echo -e "     ${VIOLET}${OPCIONES[$i]}: ${WHITE}${WINE_ENVS[$IDX_WINE]}${RESET}"
            else
                echo -e "     ${VIOLET}${OPCIONES[$i]}${RESET}"
            fi
        fi
    done

    echo -e "\n${GOLD}  [↑/↓] Navegar  [←/→] Cambiar Wine  [Enter] Seleccionar${RESET}"

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }

    case $key in
        $'\x1b[A') [ $CURSOR -gt 0 ] && ((CURSOR--)) ;;
        $'\x1b[B') [ $CURSOR -lt $((${#OPCIONES[@]}-1)) ] && ((CURSOR++)) ;;
        $'\x1b[C') [ $CURSOR -eq 0 ] && IDX_WINE=$(( (IDX_WINE + 1) % 2 )) ;;
        $'\x1b[D') [ $CURSOR -eq 0 ] && IDX_WINE=$(( (IDX_WINE + 1) % 2 )) ;;
        "") 
            case $CURSOR in
                0) echo -e "${GREEN}➜ Entorno seleccionado: ${WINE_ENVS[$IDX_WINE]}${RESET}"; sleep 1 ;;
                1) init_env ;;
                2) run_exe ;;
                3) settings_wine ;;
                4) exit 0 ;;
            esac ;;
    esac
done