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
        msg_gui_sub="Wine requiere una interfaz gráfica (X11/Wayland)."
        msg_remote_t="CONFIGURACIÓN DE ESCRITORIO REMOTO"
        msg_prot="Selecciona el protocolo"
        msg_scope="Selecciona el alcance"
        msg_local="Local (Red LAN / Misma Wi-Fi)"
        msg_global="No Local (Internet Global vía Ngrok)"
        msg_install="Instalando paquetes necesarios"
        msg_detected="Entorno detectado automáticamente"
        msg_enter="Presiona ENTER para volver..."
        ;;
    1) # ENGLISH
        title="🧰  T O M E X   T O O L S"
        sub="Advanced Management System"
        f_nav="Navigate"; f_chg="Change"; f_conf="Confirm"
        opciones=("Choose Wine Environment" "Open File Manager" "Terminal Widget Installer" "Remote Desktop (XRDP/VNC)" "Back to TOMEX")
        msg_gui_err="ERROR: No graphical environment detected."
        msg_gui_sub="Wine requires a GUI (X11/Wayland) to run."
        msg_remote_t="REMOTE DESKTOP SETUP"
        msg_prot="Select the protocol"
        msg_scope="Select the scope"
        msg_local="Local (LAN Network / Same Wi-Fi)"
        msg_global="No Local (Global Internet via Ngrok)"
        msg_install="Installing required packages"
        msg_detected="Automatically detected environment"
        msg_enter="Press ENTER to return..."
        ;;
    2) # CHINESE (中文)
        title="🧰  T O M E X   工 具 箱"
        sub="高级管理系统"
        f_nav="导航"; f_chg="更改"; f_conf="确认"
        opciones=("选择 Wine 环境" "打开文件管理器" "终端组件安装程序" "远程桌面 (XRDP/VNC)" "返回 TOMEX")
        msg_gui_err="错误：未检测到图形环境。"
        msg_gui_sub="Wine 需要图形界面 (X11/Wayland) 才能运行。"
        msg_remote_t="远程桌面设置"
        msg_prot="选择协议"
        msg_scope="选择范围"
        msg_local="本地 (局域网 / 同一 Wi-Fi)"
        msg_global="非本地 (通过 Ngrok 的全球互联网)"
        msg_install="正在安装必要的软件包"
        msg_detected="自动检测到的环境"
        msg_enter="按回车键返回..."
        ;;
esac

# Localización
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WINE_MANAGER="$DIR_BASE/wine_manager.sh"

# --- Variables de Estado ---
cursor=0        
sub_idx=0       # 0=Glibc, 1=Bionic, 2=Settings

# --- FUNCIÓN 1: Comprobar Entorno Gráfico para Wine ---
check_gui() {
    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        echo -e "\n${RED}${BOLD}  [!] ERROR: No se detectó un entorno gráfico.${RESET}"
        echo -e "  ${WHITE}Wine requiere una interfaz gráfica para funcionar (X11 o Wayland).${RESET}"
        echo -e "  ${CYAN}➜ Por favor, inicia un entorno de escritorio o Window Manager primero.${RESET}"
        echo -e "\n  ${AMARILLO}Presiona ENTER para volver...${RESET}"
        read
        return 1
    fi
    return 0
}

# --- FUNCIÓN 2: Configurar y Lanzar Escritorio Remoto ---
setup_remote_desktop() {
    clear
    echo -e "${MORADO}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃             🌐  REMOTE DESKTOP SETUP                 ┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}\n"
    
    echo -e "${CYAN}1) XRDP (Protocolo RDP - Ideal para conectar desde Windows)${RESET}"
    echo -e "${CYAN}2) VNC (Protocolo VNC - Universal, rápido y ligero)${RESET}"
    read -p "➜ Selecciona el protocolo (1/2): " prot_choice

    echo -e "\n${CYAN}1) Local (Solo red LAN / Wi-Fi de tu casa)${RESET}"
    echo -e "${CYAN}2) No Local (Internet Global usando túnel Ngrok)${RESET}"
    read -p "➜ Selecciona el alcance (1/2): " net_choice

    # --- Detección Inteligente del Entorno Gráfico (DE) ---
    local de_exec=""
    if command -v startxfce4 &> /dev/null; then de_exec="startxfce4"
    elif command -v startplasma-x11 &> /dev/null; then de_exec="startplasma-x11"
    elif command -v gnome-session &> /dev/null; then de_exec="gnome-session"
    elif command -v mate-session &> /dev/null; then de_exec="mate-session"
    elif command -v cinnamon-session &> /dev/null; then de_exec="cinnamon-session"
    elif command -v budgie-desktop &> /dev/null; then de_exec="budgie-desktop"
    elif command -v lxqt-session &> /dev/null; then de_exec="lxqt-session"
    else de_exec="xterm" # Fallback de emergencia
    fi

    echo -e "\n${AMARILLO}➜ Entorno gráfico detectado automáticamente: ${WHITE}$de_exec${RESET}"
    sleep 1

    local port=""

    # --- LÓGICA XRDP ---
    if [ "$prot_choice" == "1" ]; then
        echo -e "${GREEN}➜ Instalando paquetes XRDP desde AUR...${RESET}"
        yay -S --needed --noconfirm xrdp xorgxrdp
        
        echo -e "${CYAN}➜ Adaptando ~/.xinitrc para iniciar $de_exec...${RESET}"
        echo "exec $de_exec" > ~/.xinitrc
        
        echo -e "${CYAN}➜ Habilitando e iniciando servicio xrdp...${RESET}"
        sudo systemctl enable --now xrdp
        port="3389"
    
    # --- LÓGICA VNC ---
    else
        echo -e "${GREEN}➜ Instalando TigerVNC...${RESET}"
        sudo pacman -S --needed --noconfirm tigervnc
        
        echo -e "${CYAN}➜ Generando script de inicio ~/.vnc/xstartup...${RESET}"
        mkdir -p ~/.vnc
        echo -e "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec $de_exec" > ~/.vnc/xstartup
        chmod +x ~/.vnc/xstartup
        
        echo -e "${AMARILLO}➜ Por favor, configura una contraseña para tu servidor VNC:${RESET}"
        vncpasswd
        
        echo -e "${CYAN}➜ Reiniciando servidor VNC en el puerto :1...${RESET}"
        vncserver -kill :1 &> /dev/null
        vncserver :1
        port="5901"
    fi

    # --- LÓGICA LOCAL VS NO LOCAL (NGROK) ---
    if [ "$net_choice" == "2" ]; then
        echo -e "\n${GREEN}➜ Configurando acceso global con Ngrok...${RESET}"
        if ! command -v ngrok &> /dev/null; then
            yay -S --needed --noconfirm ngrok
        fi
        
        echo -e "\n${ROSA}${BOLD}⚠️ IMPORTANTE:${RESET} Ngrok requiere un 'Authtoken' para conexiones TCP."
        echo -e "Si te da error, ve a https://dashboard.ngrok.com, copia tu token y ejecuta:"
        echo -e "${WHITE}ngrok config add-authtoken <tu_token>${RESET} en otra terminal.\n"
        
        echo -e "${GREEN}Iniciando túnel seguro hacia el mundo exterior en el puerto $port...${RESET}"
        sleep 4
        ngrok tcp $port
    else
        local ip_local=$(ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -n1)
        echo -e "\n${GREEN}✔ Servicio iniciado localmente con éxito.${RESET}"
        
        if [ "$prot_choice" == "1" ]; then
            echo -e "➜ Abre Conexión a Escritorio Remoto (Windows) y conéctate a: ${WHITE}${BOLD}$ip_local${RESET}"
        else
            echo -e "➜ Abre tu visor VNC (TigerVNC/RealVNC) y conéctate a: ${WHITE}${BOLD}$ip_local:5901${RESET}"
        fi
        echo -e "\n${AMARILLO}Presiona ENTER para volver al menú de Tools...${RESET}"; read
    fi
}

# --- BUCLE PRINCIPAL ---
opciones=(
    "Choose Wine Environment" 
    "Open File Manager" 
    "Terminal Widget Installer" 
    "Remote Desktop (XRDP / VNC)" 
    "Back to TOMEX"
)

while true; do
    clear
    echo -e "${MORADO}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃                ${WHITE}🧰  T O M E X   T O O L S${MORADO}             ┃"
    echo -e "┃           ${CYAN}Advanced Management System${MORADO}             ┃"
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

    echo -e "\n${AMARILLO}  [↑/↓] Menú  [←/→] Cambiar Wine  [Enter] Confirmar${RESET}"

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
                                echo -e "${CYAN}Abriendo panel de control (winecfg)...${RESET}"
                                winecfg &> /dev/null &
                                sleep 1.5
                            fi ;;
                        1) 
                            if check_gui; then
                                export WINEPREFIX="$HOME/.wine_Bionic"
                                echo -e "\n${GREEN}➜ Iniciando entorno Bionic en $WINEPREFIX...${RESET}"
                                echo -e "${CYAN}Abriendo panel de control (winecfg)...${RESET}"
                                winecfg &> /dev/null &
                                sleep 1.5
                            fi ;;
                        2) 
                           if [ -f "$WINE_MANAGER" ]; then
                               bash "$WINE_MANAGER"
                           else
                               echo -e "\n${RED}  [!] Error: $WINE_MANAGER no encontrado.${RESET}"
                               echo -e "  ${AMARILLO}Presiona ENTER para continuar...${RESET}"; read
                           fi ;;
                    esac ;;
                1) if command -v ranger &> /dev/null; then ranger; else ls -F; read; fi ;;
                2) echo -e "${CYAN}Abriendo instalador de widgets...${RESET}"; sleep 1 ;;
                3) setup_remote_desktop ;; # NUEVA OPCIÓN: Lanza el proceso de conexión remota
                4) exit 0 ;;
            esac ;;
    esac
done