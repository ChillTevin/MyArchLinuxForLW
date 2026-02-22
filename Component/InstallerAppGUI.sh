#!/bin/bash
# Recibe el idioma desde el menú principal de TOMEX
idx_lang=${1:-0}

# --- Colores ---
VIOLET='\033[38;5;93m'
CYAN='\033[38;5;51m'
GOLD='\033[38;5;220m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
RESET='\033[0m'
BOLD='\033[1m'
BG_SELECT='\033[48;5;236m'

# --- Directorio de componentes ---
DIR_COMP="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# --- Variables de Estado ---
down_count=0
uninstall_mode=false

# --- Función: Traducciones Dinámicas ---
get_text() {
    case $idx_lang in
        0) # ESPAÑOL
            t_main="CENTRO DE INSTALACIÓN"; t_maint="MODO MANTENIMIENTO (BORRAR)"
            i_app="󰀻  Instalador de APPs"; i_cli="󰆍  Instalador de CLI"
            h_yay="Instalar YAY"; h_paru="Instalar PARU"; h_black="Configurar BlackArch"
            u_yay="Desinstalar YAY"; u_paru="Desinstalar PARU"; u_black="Quitar BlackArch"
            m_back="󰈆  Volver"; m_wait="Por favor, instale un Helper primero..."
            ;;
        1) # ENGLISH
            t_main="INSTALLATION CENTER"; t_maint="MAINTENANCE MODE (REMOVE)"
            i_app="󰀻 App Installer"; i_cli="󰆍 CLI Installer"
            h_yay="Install YAY"; h_paru="Install PARU"; h_black="Setup BlackArch"
            u_yay="Uninstall YAY"; u_paru="Uninstall PARU"; u_black="Remove BlackArch"
            m_back="󰈆 Back"; m_wait="Please install a Helper first..."
            ;;
        2) # CHINESE
            t_main="安装中心"; t_maint="维护模式 (删除)"
            i_app="󰀻 应用商店"; i_cli="󰆍 专业安装程序"
            h_yay="安装 YAY"; h_paru="安装 PARU"; h_black="配置 BlackArch"
            u_yay="卸载 YAY"; u_paru="卸载 PARU"; u_black="移除 BlackArch"
            m_back="󰈆 返回"; m_wait="请先安装辅助工具..."
            ;;
    esac
}

# --- Función: Construir Menú ---
check_tools() {
    get_text
    opts=()
    local has_helper=false

    # Verificar si existe al menos uno
    if command -v yay &> /dev/null || command -v paru &> /dev/null || [ -f /etc/pacman.d/blackarch-mirrorlist ]; then
        has_helper=true
    fi

    if [ "$uninstall_mode" = false ]; then
        # Si NO hay helper, forzamos instalación. Si HAY, mostramos instaladores.
        if [ "$has_helper" = true ]; then
            opts+=("$i_app" "$i_cli")
        fi
        # Mostrar opciones de instalación solo si NO están instalados
        ! command -v yay &> /dev/null && opts+=("󱑤  $h_yay")
        ! command -v paru &> /dev/null && opts+=("󱑤  $h_paru")
        [ ! -f /etc/pacman.d/blackarch-mirrorlist ] && opts+=("󱑤  $h_black")
    else
        # MODO DESINSTALAR
        command -v yay &> /dev/null && opts+=("${RED}󰛌  $u_yay${RESET}")
        command -v paru &> /dev/null && opts+=("${RED}󰛌  $u_paru${RESET}")
        [ -f /etc/pacman.d/blackarch-mirrorlist ] && opts+=("${RED}󰛌  $u_black${RESET}")
    fi
    opts+=("$m_back")
}

install_helper() {
    clear
    echo -e "${CYAN}${BOLD}➜ Executing task...${RESET}"
    
    # Creamos un directorio temporal neutral para evitar líos de permisos
    local TEMP_DIR="/tmp/tomex_install"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR" || return

    case $1 in
        "YAY")
            echo -e "${CYAN}Clonando e instalando YAY...${RESET}"
            sudo pacman -S --needed --noconfirm base-devel git
            # Clonamos de forma limpia
            git clone https://aur.archlinux.org/yay.git
            cd yay || exit
            # makepkg NO DEBE ser root, pero -si instalará con sudo automáticamente
            makepkg -si --noconfirm
            cd .. && rm -rf yay
            ;;
        "PARU")
            echo -e "${CYAN}Clonando e instalando PARU...${RESET}"
            sudo pacman -S --needed --noconfirm base-devel git
            git clone https://aur.archlinux.org/paru.git
            cd paru || exit
            makepkg -si --noconfirm
            cd .. && rm -rf paru
            ;;
        "BLACK")
            echo -e "${CYAN}Configurando BlackArch (Requiere privilegios)...${RESET}"
            # Aquí sí usamos sudo para descargar y ejecutar el script de strap
            curl -O https://blackarch.org/strap.sh
            chmod +x strap.sh
            sudo ./strap.sh
            rm strap.sh
            ;;
    esac
    
    # Volvemos al directorio del componente
    cd "$DIR_COMP" || exit
    echo -e "${GREEN}Done!${RESET}"; sleep 2
}

# --- Lógica de Desinstalación ---
remove_helper() {
    clear
    case $1 in
        "YAY") sudo pacman -Rs --noconfirm yay ;;
        "PARU") sudo pacman -Rs --noconfirm paru ;;
        "BLACK") sudo sed -i '/blackarch/d' /etc/pacman.conf && sudo rm /etc/pacman.d/blackarch-mirrorlist ;;
    esac
    echo -e "${RED}Removed.${RESET}"; sleep 2
}

# --- Bucle Principal ---
cursor=0
tput civis
while true; do
    check_tools
    clear
    
    # Ajustar cursor si se sale del rango tras cambios dinámicos
    [ $cursor -ge ${#opts[@]} ] && cursor=$((${#opts[@]}-1))

    # Header
    if [ "$uninstall_mode" = true ]; then
        echo -e "${RED}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃           $t_maint            ┃"
        echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    else
        echo -e "${VIOLET}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
        echo -e "┃             $t_main                 ┃"
        echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    fi

    # Renderizar Opciones
    for i in "${!opts[@]}"; do
        if [ $i -eq $cursor ]; then
            echo -e "${BG_SELECT}${GOLD}  ➜  ${WHITE}${BOLD}${opts[$i]}  ${RESET}"
        else
            echo -e "     ${VIOLET}${opts[$i]}${RESET}"
        fi
    done

    read -rsn1 k
    [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }

    case $k in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)); down_count=0 ;;
        $'\x1b[B') 
            if [ $cursor -lt $((${#opts[@]}-1)) ]; then
                ((cursor++)); down_count=0
            else
                ((down_count++))
                if [ $down_count -ge 2 ]; then
                    uninstall_mode=$([ "$uninstall_mode" = true ] && echo false || echo true)
                    down_count=0; cursor=0
                fi
            fi ;;
        "") 
            selection="${opts[$cursor]}"
            case "$selection" in
                *"$i_app"*) bash "$DIR_COMP/InstallerApp.sh" "$idx_lang" ;;
                *"$i_cli"*) bash "$DIR_COMP/InstallerAppCLI.sh" "$idx_lang" ;;
                *"$h_yay"*) install_helper "YAY" ;;
                *"$h_paru"*) install_helper "PARU" ;;
                *"$h_black"*) install_helper "BLACK" ;;
                *"$u_yay"*) remove_helper "YAY" ;;
                *"$u_paru"*) remove_helper "PARU" ;;
                *"$u_black"*) remove_helper "BLACK" ;;
                *"$m_back"*) tput cnorm; exit 0 ;;
            esac ;;
    esac
done