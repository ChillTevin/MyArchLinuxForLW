#!/bin/bash
# Recibe el idioma de TOMEX
idx_lang=${1:-0}

# --- Paleta de Colores Morados Premium ---
VIOLETA_OSCURO='\033[38;5;57m'
MORADO_INTENSO='\033[38;5;93m'
MORADO_SUAVE='\033[38;5;129m'
LAVANDA='\033[38;5;141m'
MAGENTA_NEON='\033[38;5;201m'
CYAN_GLITCH='\033[38;5;51m'
WHITE='\033[38;5;255m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# --- Traducciones ---
case $idx_lang in
    0) t_tit=" P O R T A L   R E M O T O "; t_local="Red Local (LAN)"; t_global="Internet (Ngrok)"; t_cf="Internet (Cloudflare)"; t_kill="Limpiar Sesiones"; t_back="Volver al Menú" ;;
    1) t_tit=" R E M O T E   P O R T A L "; t_local="Local Network (LAN)"; t_global="Global (Ngrok)"; t_cf="Global (Cloudflare)"; t_kill="Clean Sessions"; t_back="Back to Menu" ;;
esac

options=(" 🖥️  RDP (Auto-Config) " " 🧊  VNC (Universal) " " 🐚  SSH (Secure Shell) " " 🧹  $t_kill " " ⬅️  $t_back ")
cursor=0

# --- Función: Detectar Entorno de Escritorio ---
detect_de() {
    if command -v startxfce4 &>/dev/null; then echo "exec startxfce4"
    elif command -v gnome-session &>/dev/null; then echo "exec gnome-session"
    elif command -v startplasma-x11 &>/dev/null; then echo "exec startplasma-x11"
    elif command -v mate-session &>/dev/null; then echo "exec mate-session"
    elif command -v cinnamon-session &>/dev/null; then echo "exec cinnamon-session"
    elif command -v openbox-session &>/dev/null; then echo "exec openbox-session"
    else echo "exec xterm"; fi # Fallback
}

# --- Función: Configuración Maestra de XRDP ---
setup_xrdp_auto() {
    local CURRENT_USER=$(whoami)
    local USER_HOME=$(eval echo "~$CURRENT_USER")
    local DE_COMMAND=$(detect_de)

    echo -e "${MORADO_SUAVE}🛠️ Instalando dependencias de X11 y XRDP...${RESET}"
    sudo pacman -S --needed --noconfirm xorg xorg-server dbus &>/dev/null
    yay -S --needed --noconfirm xrdp xorgxrdp &>/dev/null

    echo -e "${MORADO_SUAVE}📝 Configurando .xinitrc para: ${WHITE}$DE_COMMAND${RESET}"
    echo "$DE_COMMAND" > "$USER_HOME/.xinitrc"
    sudo chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.xinitrc"

    # --- Verificación de Systemd (Docker vs Host) ---
    if pidof systemd &>/dev/null; then
        echo -e "${CYAN_GLITCH}⚙️ Sistema con Systemd detectado. Iniciando servicios...${RESET}"
        sudo systemctl enable --now xrdp xrdp-sesman &>/dev/null
    else
        echo -e "${AMARILLO}⚠️ Systemd no detectado (Modo Docker/Server). Iniciando manualmente...${RESET}"
        sudo dbus-daemon --system &>/dev/null
        xrdp-sesman &>/dev/null
        xrdp --nodaemon &
    fi
}

# --- Función: Dibujar el Portal ---
draw_menu() {
    clear
    echo -e "${VIOLETA_OSCURO}╭──────────────────────────────────────────────────────╮"
    echo -e "│${RESET}${BOLD}${MAGENTA_NEON}          💜  $t_tit  💜          ${RESET}${VIOLETA_OSCURO}│"
    echo -e "╰──────────────────────────────────────────────────────╯${RESET}"
    echo -e "${DIM}  Navega con [↑/↓] y confirma con [ENTER]${RESET}\n"

    for i in "${!options[@]}"; do
        if [ $i -eq $cursor ]; then
            echo -e "  ${MAGENTA_NEON}➜ ${BG_SELECT}${WHITE}${BOLD} ${options[$i]} ${RESET}"
        else
            echo -e "     ${LAVANDA}${options[$i]}${RESET}"
        fi
    done
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
            else
                echo -e "     ${LAVANDA}${scope_opts[$i]}${RESET}"
            fi
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
    draw_menu
    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }

    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;;
        $'\x1b[B') [ $cursor -lt $((${#options[@]}-1)) ] && ((cursor++)) ;;
        "") 
            case $cursor in
                0) # RDP AUTO-CONFIG
                    setup_xrdp_auto
                    select_scope "RDP"
                    scope=$?
                    [[ $scope -eq 1 ]] && ngrok tcp 3389
                    [[ $scope -eq 2 ]] && cloudflared tunnel --url tcp://localhost:3389
                    ;;
                1) # VNC
                    sudo pacman -S --needed --noconfirm tigervnc &>/dev/null
                    vncserver :1 &>/dev/null
                    select_scope "VNC"
                    scope=$?
                    [[ $scope -eq 1 ]] && ngrok tcp 5901
                    [[ $scope -eq 2 ]] && cloudflared tunnel --url tcp://localhost:5901
                    ;;
                2) # SSH
                    sudo pacman -S --needed --noconfirm openssh &>/dev/null
                    if pidof systemd &>/dev/null; then sudo systemctl enable --now sshd &>/dev/null; else /usr/bin/sshd &>/dev/null; fi
                    echo -e "${GREEN}✔ SSH Activo.${RESET}"; sleep 2
                    ;;
                3) # Limpiar
                    sudo pkill ngrok; sudo pkill cloudflared; sudo pkill xrdp; vncserver -kill :1 &>/dev/null
                    echo -e "${RED}🧹 Sesiones limpias.${RESET}"; sleep 2
                    ;;
                4) exit 0 ;;
            esac
            ;;
    esac
done