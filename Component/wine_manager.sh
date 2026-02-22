#!/bin/bash

# --- Recepción del Idioma ---
idx_lang=${1:-0}

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

# --- Diccionario de Idiomas ---
case $idx_lang in
    0) # ESPAÑOL
        t_title="🍷  GESTOR DE ENTORNOS WINE"
        t_sub="Sistema de Aislamiento & Compatibilidad"
        opciones=("Elegir Entorno" "Instalar Dependencias Base" "Inicializar / Reparar Prefijo" "Ejecutar Aplicación (.exe)" "Configuración Avanzada" "Volver a Tools")
        f_nav="Navegar"; f_chg="Cambiar"; f_conf="Seleccionar"
        msg_init_t="INICIALIZAR ENTORNO"
        msg_path="Introduce la ruta (Enter para defecto)"
        msg_installing="Instalando dependencias de sistema..."
        msg_ready="Entorno listo en:"
        msg_exe_t="EJECUTAR APLICACIÓN WINDOWS"
        msg_exe_info="Selecciona el .exe (puedes arrastrarlo aquí)"
        ;;
    1) # ENGLISH
        t_title="🍷  WINE ENVIRONMENT MANAGER"
        t_sub="Isolation & Compatibility System"
        opciones=("Choose Environment" "Install Base Dependencies" "Initialize / Fix Prefix" "Run Windows App (.exe)" "Advanced Settings" "Back to Tools")
        f_nav="Navigate"; f_chg="Change"; f_conf="Select"
        msg_init_t="INITIALIZE ENVIRONMENT"
        msg_path="Enter path (Enter for default)"
        msg_installing="Installing system dependencies..."
        msg_ready="Environment ready at:"
        msg_exe_t="RUN WINDOWS APPLICATION"
        msg_exe_info="Select the .exe file (you can drag it here)"
        ;;
    2) # CHINESE (中文)
        t_title="🍷  WINE 环境管理器"
        t_sub="隔离与兼容系统"
        opciones=("选择环境" "安装基础依赖" "初始化 / 修复前缀" "运行 Windows 程序 (.exe)" "高级设置" "返回工具箱")
        f_nav="导航"; f_chg="更改"; f_conf="选择"
        msg_init_t="初始化环境"
        msg_path="输入路径 (回车使用默认值)"
        msg_installing="正在安装系统依赖..."
        msg_ready="环境已就绪："
        msg_exe_t="运行 Windows 应用程序"
        msg_exe_info="选择 .exe 文件 (可以直接拖入)"
        ;;
esac

# --- Variables Globales ---
WINE_ENVS=("Glibc" "Bionic")
IDX_WINE=0
CURSOR=0
PREFIX_DIR="$HOME/.wine_custom"

# --- FUNCIÓN 0: INSTALADOR DE DEPENDENCIAS ---
install_deps() {
    clear
    echo -e "${GOLD}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃          📦 $msg_installing                ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    
    # Dependencias esenciales de Arch para Wine
    local pkgs=(wine winetricks wine-mono wine-gecko vulkan-icd-loader lib32-vulkan-icd-loader giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libxinerama ncurses lib32-ncurses opencl-icd-loader lib32-opencl-icd-loader libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs)

    echo -e "${CYAN}➜ Sincronizando repositorios e instalando paquetes necesarios...${RESET}"
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
    
    echo -e "\n${GREEN}✔ Dependencias instaladas correctamente.${RESET}"
    sleep 2
}

# --- FUNCIÓN 1: INICIALIZAR ENTORNO ---
init_env() {
    clear
    local env_name="${WINE_ENVS[$IDX_WINE]}"
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃           📦 $msg_init_t: $env_name                ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    
    echo -e "${CYAN}➜ $msg_path: $HOME/.wine_$env_name${RESET}"
    read -e -p "➜ " custom_path
    
    PREFIX_DIR="${custom_path:-$HOME/.wine_$env_name}"
    PREFIX_DIR=$(eval echo "$PREFIX_DIR")

    echo -e "\n${CYAN}➜ Creando estructura en: ${GOLD}$PREFIX_DIR${RESET}"
    mkdir -p "$PREFIX_DIR"
    export WINEPREFIX="$PREFIX_DIR"
    export WINEARCH=win64

    echo -e "${GOLD}➜ Wineboot (Configurando Registro)...${RESET}"
    wineboot -u
    
    echo -e "\n${GREEN}✔ $msg_ready $PREFIX_DIR.${RESET}"
    read -p "ENTER..."
}

# --- FUNCIÓN 2: EJECUTAR APP ---
run_exe() {
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃           🚀 $msg_exe_t               ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    
    echo -e "${CYAN}➜ $msg_exe_info${RESET}"
    read -e -p "➜ " exe_path
    exe_path=$(eval echo "$exe_path")

    if [ -f "$exe_path" ]; then
        export WINEPREFIX="$PREFIX_DIR"
        echo -e "\n${GREEN}➜ Lanzando: ${RED}${BOLD}$(basename "$exe_path")${RESET}"
        wine "$exe_path" &> /dev/null &
        sleep 2
    else
        echo -e "\n${RED}❌ Error: Archivo no encontrado.${RESET}"
        sleep 2
    fi
}

# --- FUNCIÓN 3: SETTINGS (WINETRICKS) ---
settings_wine() {
    local set_cursor=0
    local set_opciones=("winecfg" "DXVK (Vulkan)" "Winetricks Menu" "Regedit" "Controladores" "<-- Back")

    while true; do
        clear
        echo -e "${GOLD}${BOLD}⚙️  SETTINGS: $PREFIX_DIR${RESET}\n"
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
                export WINEPREFIX="$PREFIX_DIR"
                case $set_cursor in
                    0) winecfg & ;;
                    1) winetricks dxvk ;;
                    2) winetricks --gui ;;
                    3) wine regedit & ;;
                    4) wine control & ;;
                    5) return ;;
                esac
                echo -e "${GREEN}OK.${RESET}"; sleep 1 ;;
        esac
    done
}

# --- BUCLE PRINCIPAL ---
tput civis
while true; do
    clear
    echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃              ${WHITE}$t_title${VIOLET}            ┃"
    echo -e "┃           ${CYAN}$t_sub${VIOLET}           ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!opciones[@]}"; do
        if [ $i -eq $CURSOR ]; then
            if [ $i -eq 0 ]; then
                echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${opciones[$i]}: ${CYAN}< ${WINE_ENVS[$IDX_WINE]} >${RESET}"
            else
                echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${opciones[$i]}  ${RESET}"
            fi
        else
            if [ $i -eq 0 ]; then
                echo -e "     ${VIOLET}${opciones[$i]}: ${WHITE}${WINE_ENVS[$IDX_WINE]}${RESET}"
            else
                echo -e "     ${VIOLET}${opciones[$i]}${RESET}"
            fi
        fi
    done

    echo -e "\n${GOLD}  [↑/↓] $f_nav  [←/→] $f_chg  [Enter] $f_conf${RESET}"

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }

    case $key in
        $'\x1b[A') [ $CURSOR -gt 0 ] && ((CURSOR--)) ;;
        $'\x1b[B') [ $CURSOR -lt $((${#opciones[@]}-1)) ] && ((CURSOR++)) ;;
        $'\x1b[C'|$'\x1b[D') [ $CURSOR -eq 0 ] && IDX_WINE=$(( (IDX_WINE + 1) % 2 )) ;;
        "") 
            case $CURSOR in
                0) echo -e "${GREEN}➜ ${WINE_ENVS[$IDX_WINE]}${RESET}"; sleep 1 ;;
                1) install_deps ;;
                2) init_env ;;
                3) run_exe ;;
                4) settings_wine ;;
                5) tput cnorm; exit 0 ;;
            esac ;;
    esac
done