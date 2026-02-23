#!/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║       TOMEX.sh — Portal Remoto Avanzado v2.0                ║
# ║       Módulo: Acceso Remoto (RDP · VNC · SSH)               ║
# ╚══════════════════════════════════════════════════════════════╝

idx_lang=${1:-0}

# ─── Paleta de Colores ────────────────────────────────────────
VIOLETA_OSCURO='\033[38;5;57m'
MORADO_INTENSO='\033[38;5;93m'
MORADO_SUAVE='\033[38;5;129m'
LAVANDA='\033[38;5;141m'
MAGENTA_NEON='\033[38;5;201m'
CYAN_GLITCH='\033[38;5;51m'
WHITE='\033[38;5;255m'
GREEN='\033[38;5;82m'
YELLOW='\033[38;5;226m'
RED='\033[38;5;196m'
BG_SELECT='\033[48;5;236m'
RESET='\033[0m'
BOLD='\033[1m'

# ─── Traducciones ─────────────────────────────────────────────
case $idx_lang in
    0)
        t_tit=" P O R T A L   R E M O T O "
        t_local="Red Local (LAN)"
        t_global="Internet (Ngrok SA)"
        t_cf="Internet (Cloudflare)"
        t_lx="Internet (LocalXpose)"
        t_kill="Limpiar Sesiones"
        t_back="Volver al Menú"
        t_scope_title="SELECCIONA EL ALCANCE"
        t_tunnel_title="SELECCIONA TÚNEL"
        t_de_title="SELECCIONA ENTORNO GRÁFICO"
        t_err_install="[ERROR] Falló la instalación de"
        t_ok_install="[OK] Instalado correctamente:"
        t_installing="Instalando"
        t_detecting="Detectando entornos instalados..."
        t_vnc_pass="Configura tu contraseña VNC (mínimo 6 caracteres):"
        t_ngrok_token="Introduce tu Ngrok AuthToken:"
        t_conn_info="INFORMACIÓN DE CONEXIÓN"
        t_ssh_ready="SSH listo. Conecta con:"
        t_rdp_ready="RDP listo en el puerto 3389"
        t_vnc_ready="VNC listo en el puerto 5901"
        t_sessions_cleaned="Sesiones limpiadas."
        t_no_de="No se detectó ningún entorno gráfico instalado."
        t_manual_de="Introduce el comando de inicio del DE manualmente:"
        t_scope_back="Volver"
        t_authtoken_ngrok="Pega tu AuthToken de https://dashboard.ngrok.com/get-started/your-authtoken"
        ;;
    1)
        t_tit=" R E M O T E   P O R T A L "
        t_local="Local Network (LAN)"
        t_global="Global (Ngrok SA)"
        t_cf="Global (Cloudflare)"
        t_lx="Global (LocalXpose)"
        t_kill="Clean Sessions"
        t_back="Back to Menu"
        t_scope_title="SELECT SCOPE"
        t_tunnel_title="SELECT TUNNEL"
        t_de_title="SELECT DESKTOP ENVIRONMENT"
        t_err_install="[ERROR] Failed to install"
        t_ok_install="[OK] Successfully installed:"
        t_installing="Installing"
        t_detecting="Detecting installed environments..."
        t_vnc_pass="Set your VNC password (min 6 characters):"
        t_ngrok_token="Enter your Ngrok AuthToken:"
        t_conn_info="CONNECTION INFO"
        t_ssh_ready="SSH ready. Connect with:"
        t_rdp_ready="RDP ready on port 3389"
        t_vnc_ready="VNC ready on port 5901"
        t_sessions_cleaned="Sessions cleaned."
        t_no_de="No desktop environment detected."
        t_manual_de="Enter DE start command manually:"
        t_scope_back="Back"
        t_authtoken_ngrok="Paste your AuthToken from https://dashboard.ngrok.com/get-started/your-authtoken"
        ;;
esac

options=(
    " 🖥️  RDP / Xrdp "
    " 🧊  VNC (TigerVNC) "
    " 🐚  SSH / SSHX "
    " 🧹  $t_kill "
    " ⬅️  $t_back "
)
cursor=0

# ═══════════════════════════════════════════════════════════════
# UTILIDADES BASE
# ═══════════════════════════════════════════════════════════════

# ─── Instala un paquete con pacman y verifica el resultado ─────
install_pkg() {
    local pkg="$1"
    local use_yay="${2:-false}"
    echo -e "${MORADO_SUAVE}📦 $t_installing: ${CYAN_GLITCH}${pkg}${RESET}"
    if [ "$use_yay" = "true" ] && command -v yay &>/dev/null; then
        yay -S --needed --noconfirm "$pkg" &>/dev/null
    else
        sudo pacman -S --needed --noconfirm "$pkg" &>/dev/null
    fi
    if command -v "$pkg" &>/dev/null || pacman -Qi "$pkg" &>/dev/null; then
        echo -e "${GREEN}✔ $t_ok_install ${pkg}${RESET}"
        return 0
    else
        echo -e "${RED}✖ $t_err_install ${pkg}${RESET}"
        return 1
    fi
}

# ─── Verifica e instala dependencias base ─────────────────────
check_deps() {
    for pkg in wget tar curl git; do
        if ! command -v "$pkg" &>/dev/null; then
            install_pkg "$pkg" || true
        fi
    done
}

# ─── Detecta entornos gráficos instalados ─────────────────────
detect_installed_des() {
    local found=()
    command -v startxfce4     &>/dev/null && found+=("XFCE|exec startxfce4")
    command -v gnome-session  &>/dev/null && found+=("GNOME|exec gnome-session")
    command -v startplasma-x11 &>/dev/null && found+=("KDE Plasma|exec startplasma-x11")
    command -v mate-session   &>/dev/null && found+=("MATE|exec mate-session")
    command -v cinnamon-session &>/dev/null && found+=("Cinnamon|exec cinnamon-session")
    command -v i3             &>/dev/null && found+=("i3|exec i3")
    command -v openbox        &>/dev/null && found+=("Openbox|exec openbox-session")
    printf '%s\n' "${found[@]}"
}

# ─── Obtiene dirección IP local ───────────────────────────────
get_local_ip() {
    ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' \
        || hostname -I 2>/dev/null | awk '{print $1}' \
        || echo "127.0.0.1"
}

# ─── Pausa con mensaje ────────────────────────────────────────
pause_msg() {
    echo -e "\n${LAVANDA}  Presiona cualquier tecla para continuar...${RESET}"
    read -rsn1
}

# ─── Encabezado estético ──────────────────────────────────────
draw_header() {
    local title="${1:- TOMEX REMOTO }"
    clear
    echo -e "${VIOLETA_OSCURO}${BOLD}"
    echo -e "╭──────────────────────────────────────────────────────╮"
    echo -e "│${MAGENTA_NEON}          💜  ${title}  💜          ${VIOLETA_OSCURO}│"
    echo -e "╰──────────────────────────────────────────────────────╯${RESET}"
    echo ""
}

# ═══════════════════════════════════════════════════════════════
# SUBMENÚS
# ═══════════════════════════════════════════════════════════════

# ─── Submenú: Selección de Entorno Gráfico ────────────────────
select_de_menu() {
    echo -e "${MORADO_SUAVE}🔍 $t_detecting${RESET}"
    local de_list
    mapfile -t de_list < <(detect_installed_des)

    if [ ${#de_list[@]} -eq 0 ]; then
        echo -e "${YELLOW}⚠️  $t_no_de${RESET}"
        echo -e "${LAVANDA}$t_manual_de${RESET}"
        read -r manual_cmd
        echo "$manual_cmd"
        return
    fi

    local de_names=()
    local de_cmds=()
    for entry in "${de_list[@]}"; do
        de_names+=("${entry%%|*}")
        de_cmds+=("${entry##*|}")
    done
    de_names+=("✏️  Manual")

    local dc=0
    while true; do
        draw_header "$t_de_title"
        for i in "${!de_names[@]}"; do
            if [ $i -eq $dc ]; then
                echo -e "  ${CYAN_GLITCH}🚀 ${BG_SELECT}${WHITE}${BOLD} ${de_names[$i]} ${RESET}"
            else
                echo -e "     ${LAVANDA}${de_names[$i]}${RESET}"
            fi
        done
        read -rsn1 k
        [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }
        case $k in
            $'\x1b[A') [ $dc -gt 0 ] && ((dc--)) ;;
            $'\x1b[B') [ $dc -lt $((${#de_names[@]}-1)) ] && ((dc++)) ;;
            "")
                if [ $dc -eq ${#de_cmds[@]} ]; then
                    draw_header "$t_de_title"
                    echo -e "${LAVANDA}$t_manual_de${RESET}"
                    read -r manual_cmd
                    echo "$manual_cmd"
                else
                    echo "${de_cmds[$dc]}"
                fi
                return ;;
        esac
    done
}

# ─── Submenú: Selección de Alcance/Túnel ─────────────────────
select_scope_menu() {
    local scope_opts=(
        " 🏠 $t_local "
        " 🌌 $t_global "
        " ☁️  $t_cf "
        " 🔓 $t_lx "
        " 🔙 $t_scope_back "
    )
    local sc=0
    while true; do
        draw_header "$t_scope_title"
        for i in "${!scope_opts[@]}"; do
            if [ $i -eq $sc ]; then
                echo -e "  ${CYAN_GLITCH}🚀 ${BG_SELECT}${WHITE}${BOLD} ${scope_opts[$i]} ${RESET}"
            else
                echo -e "     ${LAVANDA}${scope_opts[$i]}${RESET}"
            fi
        done
        read -rsn1 k
        [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }
        case $k in
            $'\x1b[A') [ $sc -gt 0 ] && ((sc--)) ;;
            $'\x1b[B') [ $sc -lt $((${#scope_opts[@]}-1)) ] && ((sc++)) ;;
            "") return $sc ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# INSTALADORES DE TÚNELES
# ═══════════════════════════════════════════════════════════════

# ─── Instalar / Configurar Ngrok ─────────────────────────────
setup_ngrok() {
    local port="$1"
    check_deps
    if ! command -v ngrok &>/dev/null; then
        echo -e "${MAGENTA_NEON}🚀 Descargando Ngrok v3...${RESET}"
        local arch
        arch=$(uname -m)
        local ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz"
        [[ "$arch" == "aarch64" ]] && ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz"
        wget -q --show-progress "$ngrok_url" -O /tmp/ngrok.tgz
        if ! sudo tar -xzf /tmp/ngrok.tgz -C /usr/local/bin &>/dev/null; then
            echo -e "${RED}✖ $t_err_install ngrok (extracción fallida)${RESET}"
            rm -f /tmp/ngrok.tgz; return 1
        fi
        rm -f /tmp/ngrok.tgz
        echo -e "${GREEN}✔ $t_ok_install ngrok${RESET}"
    fi

    # Solicitar AuthToken si no está configurado
    if ! ngrok config check &>/dev/null 2>&1 | grep -q "authtoken"; then
        draw_header "NGROK AUTH"
        echo -e "${CYAN_GLITCH}🔑 $t_ngrok_token${RESET}"
        echo -e "${LAVANDA}($t_authtoken_ngrok)${RESET}\n"
        read -r ngrok_token
        if [ -z "$ngrok_token" ]; then
            echo -e "${RED}✖ AuthToken vacío. Operación cancelada.${RESET}"
            pause_msg; return 1
        fi
        ngrok config add-authtoken "$ngrok_token" &>/dev/null
        echo -e "${GREEN}✔ AuthToken configurado.${RESET}"
    fi

    echo -e "${MAGENTA_NEON}📡 Iniciando Túnel Ngrok en São Paulo (SA) → Puerto ${port}...${RESET}"
    echo -e "${YELLOW}💡 La URL de conexión aparecerá a continuación. Ctrl+C para salir.${RESET}\n"
    ngrok tcp --region sa "$port"
}

# ─── Instalar / Configurar Cloudflared ───────────────────────
setup_cloudflare() {
    local port="$1"
    if ! command -v cloudflared &>/dev/null; then
        if ! install_pkg "cloudflared" "true"; then
            # Fallback: descarga binario directamente
            echo -e "${MORADO_SUAVE}📦 Intentando descarga directa de cloudflared...${RESET}"
            wget -q --show-progress \
                "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" \
                -O /tmp/cloudflared
            sudo install -m 755 /tmp/cloudflared /usr/local/bin/cloudflared
            rm -f /tmp/cloudflared
        fi
    fi
    if ! command -v cloudflared &>/dev/null; then
        echo -e "${RED}✖ $t_err_install cloudflared${RESET}"; pause_msg; return 1
    fi
    echo -e "${MAGENTA_NEON}☁️  Iniciando Túnel Cloudflare → Puerto ${port}...${RESET}"
    echo -e "${YELLOW}💡 La URL pública aparecerá en los logs. Ctrl+C para salir.${RESET}\n"
    cloudflared tunnel --url "tcp://localhost:${port}"
}

# ─── Instalar / Configurar LocalXpose ────────────────────────
setup_localxpose() {
    local port="$1"
    check_deps
    if ! command -v loclx &>/dev/null; then
        echo -e "${MAGENTA_NEON}🔓 Descargando LocalXpose...${RESET}"
        local arch
        arch=$(uname -m)
        local lx_url="https://localxpose.io/download/linux/amd64"
        [[ "$arch" == "aarch64" ]] && lx_url="https://localxpose.io/download/linux/arm64"
        wget -q --show-progress "$lx_url" -O /tmp/loclx.zip
        sudo unzip -o /tmp/loclx.zip -d /usr/local/bin/ loclx &>/dev/null
        sudo chmod +x /usr/local/bin/loclx
        rm -f /tmp/loclx.zip
    fi
    if ! command -v loclx &>/dev/null; then
        echo -e "${RED}✖ $t_err_install localxpose${RESET}"; pause_msg; return 1
    fi
    echo -e "${MAGENTA_NEON}🔓 Iniciando Túnel LocalXpose → Puerto ${port}...${RESET}"
    echo -e "${YELLOW}💡 Necesitarás cuenta en localxpose.io para túneles TCP. Ctrl+C para salir.${RESET}\n"
    loclx tunnel tcp --to "localhost:${port}"
}

# ─── Dispatcher de Túnel ─────────────────────────────────────
launch_tunnel() {
    local port="$1"
    select_scope_menu
    local scope=$?
    case $scope in
        0) echo -e "${GREEN}🏠 Modo LAN activo. IP local: $(get_local_ip) Puerto: ${port}${RESET}"; pause_msg ;;
        1) setup_ngrok "$port" ;;
        2) setup_cloudflare "$port" ;;
        3) setup_localxpose "$port" ;;
        4) return ;;
    esac
}

# ═══════════════════════════════════════════════════════════════
# MÓDULO: XRDP (RDP)
# ═══════════════════════════════════════════════════════════════
setup_xrdp() {
    draw_header "XRDP SETUP"
    local CURRENT_USER
    CURRENT_USER=$(whoami)
    local USER_HOME
    USER_HOME=$(eval echo "~$CURRENT_USER")

    echo -e "${MORADO_SUAVE}🛠️  Preparando entorno RDP...${RESET}\n"

    # Dependencias base X
    for pkg in xorg xorg-server dbus; do
        install_pkg "$pkg" || true
    done

    # Instalar xrdp (AUR preferido para xorgxrdp)
    if command -v yay &>/dev/null; then
        install_pkg "xrdp" "true"
        install_pkg "xorgxrdp" "true"
    else
        install_pkg "xrdp" "false"
    fi

    if ! command -v xrdp &>/dev/null && ! pacman -Qi xrdp &>/dev/null 2>&1; then
        echo -e "${RED}✖ $t_err_install xrdp. Abortando.${RESET}"; pause_msg; return 1
    fi

    # Selección de DE
    echo ""
    local de_cmd
    de_cmd=$(select_de_menu)

    if [ -z "$de_cmd" ]; then
        echo -e "${RED}✖ No se seleccionó ningún entorno. Abortando.${RESET}"; pause_msg; return 1
    fi

    echo -e "\n${CYAN_GLITCH}🖊️  Configurando .xinitrc → ${de_cmd}${RESET}"
    echo "$de_cmd" > "$USER_HOME/.xinitrc"
    chown "$CURRENT_USER:$CURRENT_USER" "$USER_HOME/.xinitrc"

    # También configurar startwm.sh si existe
    if [ -f /etc/xrdp/startwm.sh ]; then
        sudo sed -i 's|^exec.*||g' /etc/xrdp/startwm.sh
        echo "$de_cmd" | sudo tee -a /etc/xrdp/startwm.sh > /dev/null
        echo -e "${CYAN_GLITCH}🖊️  /etc/xrdp/startwm.sh actualizado.${RESET}"
    fi

    # Habilitar servicios
    draw_header "XRDP SETUP"
    echo -e "${MORADO_SUAVE}⚙️  Habilitando servicios XRDP...${RESET}"
    if pidof systemd &>/dev/null; then
        sudo systemctl enable --now xrdp xrdp-sesman &>/dev/null
        if systemctl is-active --quiet xrdp; then
            echo -e "${GREEN}✔ xrdp activo (systemd)${RESET}"
        else
            echo -e "${RED}✖ xrdp no inició correctamente.${RESET}"
        fi
    else
        echo -e "${YELLOW}⚠️  Sin systemd. Iniciando manualmente...${RESET}"
        sudo dbus-daemon --system &>/dev/null 2>&1 || true
        xrdp-sesman &>/dev/null 2>&1 &
        xrdp --nodaemon &
        echo -e "${GREEN}✔ xrdp iniciado en modo manual.${RESET}"
    fi

    # Info de conexión
    local local_ip
    local_ip=$(get_local_ip)
    echo -e "\n${VIOLETA_OSCURO}${BOLD}╭─────────────────────────────────────────────╮"
    echo -e "│  💜  $t_conn_info (RDP)                   │"
    echo -e "│  🖥️  Host: ${WHITE}${local_ip}:3389${VIOLETA_OSCURO}                    │"
    echo -e "│  👤 Usuario: ${WHITE}${CURRENT_USER}${VIOLETA_OSCURO}                       │"
    echo -e "│  🎨 DE: ${WHITE}${de_cmd}${VIOLETA_OSCURO}                │"
    echo -e "╰─────────────────────────────────────────────╯${RESET}\n"
    echo -e "${GREEN}✔ $t_rdp_ready${RESET}"
    pause_msg

    # Configurar túnel
    launch_tunnel 3389
}

# ═══════════════════════════════════════════════════════════════
# MÓDULO: VNC (TigerVNC)
# ═══════════════════════════════════════════════════════════════
setup_vnc() {
    draw_header "VNC SETUP"
    local CURRENT_USER
    CURRENT_USER=$(whoami)
    local USER_HOME
    USER_HOME=$(eval echo "~$CURRENT_USER")

    echo -e "${MORADO_SUAVE}🛠️  Preparando entorno VNC...${RESET}\n"

    # Instalar TigerVNC
    install_pkg "tigervnc" || {
        echo -e "${RED}✖ $t_err_install tigervnc. Abortando.${RESET}"; pause_msg; return 1
    }

    # Dependencias X
    for pkg in xorg-server xorg-xauth dbus-x11; do
        install_pkg "$pkg" || true
    done

    # Configurar contraseña VNC
    echo -e "\n${CYAN_GLITCH}🔐 $t_vnc_pass${RESET}"
    vncpasswd
    local vpass_status=$?
    if [ $vpass_status -ne 0 ]; then
        echo -e "${RED}✖ Error configurando contraseña VNC.${RESET}"; pause_msg; return 1
    fi

    # Seleccionar DE
    echo ""
    local de_cmd
    de_cmd=$(select_de_menu)
    if [ -z "$de_cmd" ]; then
        echo -e "${RED}✖ No se seleccionó ningún entorno. Abortando.${RESET}"; pause_msg; return 1
    fi

    # Configurar xstartup para TigerVNC
    local vnc_cfg_dir="$USER_HOME/.vnc"
    mkdir -p "$vnc_cfg_dir"
    cat > "$vnc_cfg_dir/xstartup" <<EOF
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_SESSION_TYPE=x11
${de_cmd}
EOF
    chmod +x "$vnc_cfg_dir/xstartup"
    chown -R "$CURRENT_USER:$CURRENT_USER" "$vnc_cfg_dir"
    echo -e "${GREEN}✔ $vnc_cfg_dir/xstartup configurado → ${de_cmd}${RESET}"

    # Iniciar servidor VNC
    echo -e "\n${MORADO_SUAVE}🚀 Iniciando VNC server en :1 (puerto 5901)...${RESET}"
    vncserver -kill :1 &>/dev/null 2>&1 || true
    vncserver :1 -geometry 1280x720 -depth 24 -localhost no
    local vnc_status=$?

    if [ $vnc_status -ne 0 ]; then
        echo -e "${RED}✖ Error iniciando vncserver.${RESET}"; pause_msg; return 1
    fi

    # Info de conexión
    local local_ip
    local_ip=$(get_local_ip)
    echo -e "\n${VIOLETA_OSCURO}${BOLD}╭─────────────────────────────────────────────╮"
    echo -e "│  💜  $t_conn_info (VNC)                   │"
    echo -e "│  🧊 Host: ${WHITE}${local_ip}:5901${VIOLETA_OSCURO}                    │"
    echo -e "│  👤 Usuario: ${WHITE}${CURRENT_USER}${VIOLETA_OSCURO}                       │"
    echo -e "│  🎨 DE: ${WHITE}${de_cmd}${VIOLETA_OSCURO}                │"
    echo -e "│  🔑 VNC Viewer: ${WHITE}${local_ip}::5901${VIOLETA_OSCURO}             │"
    echo -e "╰─────────────────────────────────────────────╯${RESET}\n"
    echo -e "${GREEN}✔ $t_vnc_ready${RESET}"
    pause_msg

    # Configurar túnel
    launch_tunnel 5901
}

# ═══════════════════════════════════════════════════════════════
# MÓDULO: SSH / SSHX
# ═══════════════════════════════════════════════════════════════
setup_ssh() {
    draw_header "SSH / SSHX SETUP"
    local CURRENT_USER
    CURRENT_USER=$(whoami)

    echo -e "${MORADO_SUAVE}🛠️  Preparando entorno SSH...${RESET}\n"

    # Instalar openssh
    install_pkg "openssh" || {
        echo -e "${RED}✖ $t_err_install openssh. Abortando.${RESET}"; pause_msg; return 1
    }

    # Habilitar sshd
    echo -e "\n${MORADO_SUAVE}⚙️  Habilitando servicio SSH...${RESET}"
    if pidof systemd &>/dev/null; then
        sudo systemctl enable --now sshd &>/dev/null
        if systemctl is-active --quiet sshd; then
            echo -e "${GREEN}✔ sshd activo (systemd)${RESET}"
        else
            echo -e "${RED}✖ sshd no inició correctamente.${RESET}"
        fi
    else
        sudo /usr/bin/sshd &>/dev/null 2>&1 &
        echo -e "${GREEN}✔ sshd iniciado manualmente.${RESET}"
    fi

    # Info de conexión LAN
    local local_ip
    local_ip=$(get_local_ip)
    echo -e "\n${VIOLETA_OSCURO}${BOLD}╭─────────────────────────────────────────────╮"
    echo -e "│  💜  $t_conn_info (SSH)                   │"
    echo -e "│  🐚 $t_ssh_ready                          │"
    echo -e "│  ➤  ${CYAN_GLITCH}ssh ${CURRENT_USER}@${local_ip}${VIOLETA_OSCURO}                │"
    echo -e "╰─────────────────────────────────────────────╯${RESET}\n"
    echo -e "${GREEN}✔ $t_ssh_ready ${CURRENT_USER}@${local_ip}${RESET}"
    pause_msg

    # Submenú SSH: LAN / Ngrok / Cloudflare / SSHX
    local ssh_opts=(
        " 🏠 $t_local (LAN only) "
        " 🌌 Ngrok TCP Tunnel "
        " ☁️  Cloudflare Tunnel "
        " ⚡ SSHX (Web Terminal) "
        " 🔙 $t_scope_back "
    )
    local ssh_cur=0
    while true; do
        draw_header "SSH ACCESS OPTIONS"
        for i in "${!ssh_opts[@]}"; do
            if [ $i -eq $ssh_cur ]; then
                echo -e "  ${CYAN_GLITCH}🚀 ${BG_SELECT}${WHITE}${BOLD} ${ssh_opts[$i]} ${RESET}"
            else
                echo -e "     ${LAVANDA}${ssh_opts[$i]}${RESET}"
            fi
        done
        read -rsn1 k
        [[ $k == $'\x1b' ]] && { read -rsn2 r; k+="$r"; }
        case $k in
            $'\x1b[A') [ $ssh_cur -gt 0 ] && ((ssh_cur--)) ;;
            $'\x1b[B') [ $ssh_cur -lt $((${#ssh_opts[@]}-1)) ] && ((ssh_cur++)) ;;
            "")
                case $ssh_cur in
                    0) # LAN — ya hecho
                        echo -e "${GREEN}🏠 SSH LAN listo: ssh ${CURRENT_USER}@${local_ip}${RESET}"
                        pause_msg; return ;;
                    1) setup_ngrok 22; return ;;
                    2) setup_cloudflare 22; return ;;
                    3) # SSHX
                        check_deps
                        draw_header "SSHX"
                        echo -e "${MAGENTA_NEON}⚡ Iniciando SSHX Web Terminal...${RESET}"
                        echo -e "${YELLOW}💡 La URL de sesión aparecerá a continuación. Ctrl+C para salir.${RESET}\n"
                        curl -sSf https://sshx.io/get | sh -s run
                        local sshx_status=$?
                        if [ $sshx_status -ne 0 ]; then
                            echo -e "${RED}✖ Error iniciando SSHX.${RESET}"
                        fi
                        pause_msg; return ;;
                    4) return ;;
                esac ;;
        esac
    done
}

# ═══════════════════════════════════════════════════════════════
# MÓDULO: LIMPIAR SESIONES
# ═══════════════════════════════════════════════════════════════
kill_sessions() {
    draw_header "LIMPIAR SESIONES"
    echo -e "${RED}🧹 Deteniendo todos los servicios remotos...${RESET}\n"

    local killed=()
    sudo pkill ngrok       &>/dev/null 2>&1 && killed+=("ngrok")
    sudo pkill cloudflared &>/dev/null 2>&1 && killed+=("cloudflared")
    sudo pkill loclx       &>/dev/null 2>&1 && killed+=("localxpose")
    sudo pkill xrdp        &>/dev/null 2>&1 && killed+=("xrdp")
    sudo pkill xrdp-sesman &>/dev/null 2>&1 && killed+=("xrdp-sesman")
    vncserver -kill :1     &>/dev/null 2>&1 && killed+=("vncserver :1")
    vncserver -kill :2     &>/dev/null 2>&1 || true
    sudo pkill sshd        &>/dev/null 2>&1 && killed+=("sshd manual")

    if [ ${#killed[@]} -eq 0 ]; then
        echo -e "${YELLOW}ℹ️  No había procesos activos que detener.${RESET}"
    else
        for svc in "${killed[@]}"; do
            echo -e "${GREEN}✔ Detenido: ${svc}${RESET}"
        done
    fi
    echo -e "\n${MAGENTA_NEON}✅ $t_sessions_cleaned${RESET}"
    pause_msg
}

# ═══════════════════════════════════════════════════════════════
# BUCLE PRINCIPAL
# ═══════════════════════════════════════════════════════════════
while true; do
    draw_header "$t_tit"
    for i in "${!options[@]}"; do
        if [ $i -eq $cursor ]; then
            echo -e "  ${MAGENTA_NEON}➜ ${BG_SELECT}${WHITE}${BOLD} ${options[$i]} ${RESET}"
        else
            echo -e "     ${LAVANDA}${options[$i]}${RESET}"
        fi
    done

    read -rsn1 key
    [[ $key == $'\x1b' ]] && { read -rsn2 k; key+="$k"; }
    case $key in
        $'\x1b[A') [ $cursor -gt 0 ] && ((cursor--)) ;;
        $'\x1b[B') [ $cursor -lt $((${#options[@]}-1)) ] && ((cursor++)) ;;
        "")
            case $cursor in
                0) setup_xrdp ;;
                1) setup_vnc ;;
                2) setup_ssh ;;
                3) kill_sessions ;;
                4) exit 0 ;;
            esac ;;
    esac
done