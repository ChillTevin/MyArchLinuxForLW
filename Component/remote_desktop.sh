#!/bin/bash
# Recibe el idioma de TOMEX
idx_lang=${1:-0}

# --- Paleta de Colores Morados ---
VIOLETA_OSCURO='\033[38;5;57m'
MORADO_INTENSO='\033[38;5;93m'
MORADO_SUAVE='\033[38;5;129m'
LAVANDA='\033[38;5;141m'
MAGENTA_NEON='\033[38;5;201m'
CYAN_GLITCH='\033[38;5;51m'
WHITE='\033[38;5;255m'
GREEN='\033[38;5;82m'
RED='\033[38;5;196m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# --- Traducciones ---
case $idx_lang in
    0) t_tit=" P O R T A L   R E M O T O "; t_local="Red Local (LAN)"; t_global="Internet (Ngrok SA)"; t_cf="Internet (Cloudflare)"; t_kill="Limpiar Sesiones"; t_back="Volver al Menú" ;;
    1) t_tit=" R E M O T E   P O R T A L "; t_local="Local Network (LAN)"; t_global="Global (Ngrok SA)"; t_cf="Global (Cloudflare)"; t_kill="Clean Sessions"; t_back="Back to Menu" ;;
esac

options=(" 🖥️  RDP (Windows Style) " " 🧊  VNC (Universal) " " 🐚  SSH (Secure Shell) " " 🧹  $t_kill " " ⬅️  $t_back ")
cursor=0

# --- FUNCIÓN: Instalar dependencias base ---
check_deps() {
    for pkg in wget tar; do
        if ! command -v $pkg &>/dev/null; then
            echo -e "${MORADO_SUAVE}📦 Instalando $pkg necesario...${RESET}"
            sudo pacman -S --needed --noconfirm $pkg &>/dev/null
        fi
    done
}

# --- FUNCIÓN: Instalación y Configuración de Ngrok ---
install_ngrok() {
    check_deps
    if ! command -v ngrok &>/dev/null; then
        echo -e "${MAGENTA_NEON}🚀 Descargando Ngrok v3...${RESET}"
        wget -q --show-progress "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz" -O /tmp/ngrok.tgz
        sudo tar -xvzf /tmp/ngrok.tgz -C /usr/local/bin &>/dev/null
        rm /tmp/ngrok.tgz
        echo -e "${CYAN_GLITCH}🔑 Configurando AuthToken...${RESET}"
        ngrok config add-authtoken 1uNKiNAV8XVggSemelPcZmjYXuI_5zQY3FmebAtuHBhx2YuW5 &>/dev/null
    fi
}

# --- FUNCIÓN: Detectar Entorno de Escritorio ---
detect_de() {
    if command -v startxfce4 &>/dev/null; then echo "exec startxfce4"
    elif command -v gnome-session &>/dev/null; then echo "exec gnome-session"
    elif command -v startplasma-x11 &>/dev/null; then echo "exec startplasma-x11"
    elif command -v mate-session &>/dev/null; then echo "exec mate-session"
    elif command -v cinnamon-session &>/dev/null; then echo "exec cinnamon-session"
    else echo "exec xterm"; fi
}

# --- FUNCIÓN: Lógica Maestra XRDP (RDP) ---
setup_xrdp() {
    local CURRENT_USER=$(whoami)
    local USER_HOME=$(eval echo "~$CURRENT_USER")
    local DE_CMD=$(detect_de)

    echo -e "${MORADO_SUAVE}🛠️  Preparando entorno RDP...${RESET}"
    sudo pacman -S --needed --noconfirm xorg xorg-server dbus &>/dev/null
    # Verificamos yay para xorgxrdp (AUR)
    if command -v yay &>/dev/null; then yay -S --needed --noconfirm xrdp xorgxrdp &>/dev/null; 
    else sudo pacman -S --needed --noconfirm xrdp &>/dev/null; fi

    echo "$DE_CMD" > "$USER_HOME/.xinitrc"
    sudo chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.xinitrc"

    if pidof systemd &>/dev/null; then
        sudo systemctl enable --now xrdp xrdp-sesman &>/dev/null
    else
        echo -e "${AMARILLO}⚠️  Modo Servidor/Docker: Iniciando servicios manualmente...${RESET}"
        sudo pacman -S --needed --noconfirm dbus &>/dev/null
        sudo dbus-daemon --system &>/dev/null
        xrdp-sesman &>/dev/null
        xrdp --nodaemon &
    fi
}

# --- Submenú de Alcance ---
select_scope() {
    local scope_opts=(" 🏠 $t_local " " 🌌 $t_global " " ☁️  $t_cf " " 🔙 $t_back ")
    local sc_cursor=0
    while true; do
        clear
        echo -e "${MORADO_INTENSO}${BOLD}╭──────────────────────────────────────────╮"
        echo -e "│      🌐 SELECCIONA EL ALCANCE            │"
        echo -e "╰──────────────────────────────────────────╯${RESET}\n"
        for i in "${!scope_opts[@]}"; do
            if [ $i -eq $sc_cursor ]; then
                echo -e "  ${CYAN_GLITCH}🚀 ${BG_SELECT}${WHITE}${BOLD} ${scope_opts[$i]} ${RESET}"
            else echo -e "     ${LAVANDA}${scope_opts[$i]}${RESET}"; fi
        done
        read -rsn1 k
        [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }
        case $k in
            $'\x1b[A') [ $sc_cursor -gt 0 ] && ((sc_cursor--)) ;;
            $'\x1b[B') [ $sc_cursor -lt $((${#scope_opts[@]}-1)) ] && ((sc_cursor++)) ;;
            "") return $sc_cursor ;;
        esac
    done
}

# --- Bucle Principal ---
while true; do
    clear
    echo -e "${VIOLETA_OSCURO}╭──────────────────────────────────────────────────────╮"
    echo -e "│${RESET}${BOLD}${MAGENTA_NEON}          💜  $t_tit  💜          ${RESET}${VIOLETA_OSCURO}│"
    echo -e "╰──────────────────────────────────────────────────────╯${RESET}"
    for i in "${!options[@]}"; do
        if [ $i -eq $cursor ]; then echo -e "  ${MAGENTA_NEON}➜ ${BG_SELECT}${WHITE}${BOLD} ${options[$i]} ${RESET}"
        else echo -e "     ${LAVANDA}${options[$i]}${RESET}"; fi
    done

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }
    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;;
        $'\x1b[B') [ $cursor -lt $((${#options[@]}-1)) ] && ((cursor++)) ;;
        "") 
            case $cursor in
                0|1|2) # RDP, VNC, SSH
                    port=3389; [[ $cursor -eq 1 ]] && port=5901; [[ $cursor -eq 2 ]] && port=22
                    
                    # Instalación según opción
                    if [ $cursor -eq 0 ]; then setup_xrdp;
                    elif [ $cursor -eq 1 ]; then sudo pacman -S --needed --noconfirm tigervnc &>/dev/null; vncserver :1 &>/dev/null;
                    else sudo pacman -S --needed --noconfirm openssh &>/dev/null; [[ -f /usr/bin/sshd ]] && (sudo systemctl enable --now sshd &>/dev/null || /usr/bin/sshd &>/dev/null); fi

                    select_scope
                    scope=$?
                    if [ $scope -eq 1 ]; then 
                        install_ngrok
                        echo -e "${MAGENTA_NEON}📡 Iniciando Túnel en São Paulo (SA)...${RESET}"
                        ngrok tcp --region sa $port
                    elif [ $scope -eq 2 ]; then 
                        sudo pacman -S --needed --noconfirm cloudflared &>/dev/null
                        cloudflared tunnel --url tcp://localhost:$port
                    fi
                    ;;
                3) # Limpiar
                    sudo pkill ngrok; sudo pkill cloudflared; sudo pkill xrdp; vncserver -kill :1 &>/dev/null
                    echo -e "${RED}🧹 Sesiones limpias.${RESET}"; sleep 1 ;;
                4) exit 0 ;;
            esac ;;
    esac
done