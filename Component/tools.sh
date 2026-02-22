#!/bin/bash

idx_lang=${1:-0}

# --- Configuración de Colores ---
ROSA='\033[38;5;205m'
MORADO='\033[38;5;93m'
AMARILLO='\033[38;5;220m'
CYAN='\033[38;5;51m'
WHITE='\033[38;5;255m'
RED='\033[38;5;196m'
GREEN='\033[38;5;82m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Recepción del Idioma ---
case $idx_lang in
    0) # ESPAÑOL
        title="🧰  T O M E X   T O O L S"
        sub="Sistema de Gestión Avanzada"
        f_nav="Navegar"; f_chg="Cambiar"; f_conf="Confirmar"
        opciones=("Elegir Entorno Wine" "Abrir Gestor de Archivos" "Instalador de Widgets" "Escritorio Remoto (XRDP/VNC)" "Volver a TOMEX")
        msg_gui_err="ERROR: No se detectó un entorno gráfico."
        ;;
    1) # ENGLISH
        title="🧰  T O M E X   T O O L S"
        sub="Advanced Management System"
        f_nav="Navigate"; f_chg="Change"; f_conf="Confirm"
        opciones=("Choose Wine Environment" "Open File Manager" "Terminal Widget Installer" "Remote Desktop (XRDP/VNC)" "Back to TOMEX")
        msg_gui_err="ERROR: No graphical environment detected."
        ;;
    2) # CHINESE (中文)
        title="🧰  T O M E X   工 具 箱"
        sub="高级管理系统"
        f_nav="导航"; f_chg="更改"; f_conf="确认"
        opciones=("选择 Wine 环境" "打开文件管理器" "终端组件安装程序" "远程桌面 (XRDP/VNC)" "返回 TOMEX")
        msg_gui_err="错误：未检测到图形环境。"
        ;;
esac

# Localización de archivos modulares
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WINE_MANAGER="$DIR_BASE/wine_manager.sh"
REMOTE_MANAGER="$DIR_BASE/remote_desktop.sh" # <-- Nueva variable para tu script

# --- Variables de Estado ---
cursor=0        
sub_idx=0       # 0=Glibc, 1=Bionic, 2=Settings

# --- FUNCIÓN: Comprobar Entorno Gráfico para Wine ---
check_gui() {
    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        echo -e "\n${RED}${BOLD}  [!] $msg_gui_err${RESET}"
        echo -e "  ${WHITE}Wine requiere una interfaz gráfica para funcionar (X11 o Wayland).${RESET}"
        echo -e "  ${CYAN}➜ Por favor, inicia un entorno de escritorio o Window Manager primero.${RESET}"
        echo -e "\n  ${AMARILLO}Presiona ENTER para volver...${RESET}"
        read
        return 1
    fi
    return 0
}

# --- BUCLE PRINCIPAL ---
while true; do
    clear
    echo -e "${MORADO}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}$title${MORADO}             ┃"
    echo -e "┃           ${CYAN}$sub${MORADO}             ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"

    for i in "${!opciones[@]}"; do
        if [ $i -eq $cursor ]; then
            if [ $i -eq 0 ]; then
                case $sub_idx in
                    0) selector_txt="${ROSA} < Glibc > ${RESET}" ;;
                    1) selector_txt="${MORADO} < Bionic > ${RESET}" ;;
                    2) selector_txt="${AMARILLO} < Settings > ${RESET}" ;;
                esac
                echo -e "${BG_SELECT}${AMARILLO}  ➜  ${WHITE}${BOLD}${opciones[$i]}:${RESET}${selector_txt}${BG_SELECT} ${RESET}"
            else
                echo -e "${BG_SELECT}${AMARILLO}  ➜  ${WHITE}${BOLD}${opciones[$i]}  ${RESET}"
            fi
        else
            if [ $i -eq 0 ]; then
                case $sub_idx in
                    0) simple_txt="Glibc" ;;
                    1) simple_txt="Bionic" ;;
                    2) simple_txt="Settings" ;;
                esac
                echo -e "     ${MORADO}${opciones[$i]}: ${WHITE}$simple_txt${RESET}"
            else
                echo -e "     ${MORADO}${opciones[$i]}${RESET}"
            fi
        fi
    done

    echo -e "\n${AMARILLO}  [↑/↓] $f_nav  [←/→] $f_chg  [Enter] $f_conf${RESET}"

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }

    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;; 
        $'\x1b[B') [ $cursor -lt $((${#opciones[@]}-1)) ] && ((cursor++)) ;; 
        $'\x1b[C') [ $cursor -eq 0 ] && sub_idx=$(( (sub_idx + 1) % 3 )) ;;
        $'\x1b[D') [ $cursor -eq 0 ] && sub_idx=$(( (sub_idx + 2) % 3 )) ;;
        "") 
            case $cursor in
                0) 
                    case $sub_idx in
                        0) 
                            if check_gui; then
                                export WINEPREFIX="$HOME/.wine_Glibc"
                                echo -e "\n${GREEN}➜ Iniciando entorno Glibc en $WINEPREFIX...${RESET}"
                                winecfg &> /dev/null &
                                sleep 1.5
                            fi ;;
                        1) 
                            if check_gui; then
                                export WINEPREFIX="$HOME/.wine_Bionic"
                                echo -e "\n${GREEN}➜ Iniciando entorno Bionic en $WINEPREFIX...${RESET}"
                                winecfg &> /dev/null &
                                sleep 1.5
                            fi ;;
                        2) 
                           if [ -f "$WINE_MANAGER" ]; then
                               bash "$WINE_MANAGER" "$idx_lang"
                           else
                               echo -e "\n${RED}  [!] Error: $WINE_MANAGER no encontrado.${RESET}"
                               echo -e "  ${AMARILLO}Presiona ENTER para continuar...${RESET}"; read
                           fi ;;
                    esac ;;
                1) if command -v ranger &> /dev/null; then ranger; else ls -F; read; fi ;;
                2) echo -e "${CYAN}Abriendo instalador de widgets...${RESET}"; sleep 1 ;;
                
                # --- NUEVA LÓGICA MODULAR PARA ESCRITORIO REMOTO ---
                3) 
                    if [ ! -f "$REMOTE_MANAGER" ]; then
                        clear
                        echo -e "${CYAN}➜ Generando archivo base en $REMOTE_MANAGER...${RESET}"
                        # Creamos la plantilla del script
                        cat << 'EOF' > "$REMOTE_MANAGER"
#!/bin/bash
# Recibe el idioma de TOMEX
idx_lang=${1:-0}

clear
echo -e "\033[38;5;51m🔧 Módulo de Escritorio Remoto\033[0m"
echo -e "Este es tu nuevo archivo modular."
echo -e "Edita 'Component/remote_desktop.sh' para añadir la lógica de XRDP/VNC/Ngrok."
echo ""
read -p "Presiona ENTER para volver a Tools..."
EOF
                        chmod +x "$REMOTE_MANAGER"
                        echo -e "${GREEN}✔ Archivo 'remote_desktop.sh' creado exitosamente.${RESET}"
                        echo -e "${AMARILLO}La próxima vez que selecciones esta opción, se ejecutará tu código.${RESET}"
                        sleep 3
                    else
                        # Si ya existe, lo ejecuta pasándole el idioma
                        bash "$REMOTE_MANAGER" "$idx_lang"
                    fi
                    ;;
                4) exit 0 ;;
            esac ;;
    esac
done