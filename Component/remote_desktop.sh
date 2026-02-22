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
BG_SELECT='\033[48;5;236m' # Fondo oscuro para la selección
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# --- Traducciones ---
case $idx_lang in
    0) t_tit=" P O R T A L   R E M O T O "; t_local="Red Local (LAN)"; t_global="Internet (Ngrok)"; t_cf="Internet (Cloudflare)"; t_kill="Limpiar Sesiones"; t_back="Volver al Menú" ;;
    1) t_tit=" R E M O T E   P O R T A L "; t_local="Local Network (LAN)"; t_global="Global (Ngrok)"; t_cf="Global (Cloudflare)"; t_kill="Clean Sessions"; t_back="Back to Menu" ;;
    2) t_tit=" 远 程 门 户 "; t_local="本地网络 (LAN)"; t_global="全球网络 (Ngrok)"; t_cf="全球网络 (Cloudflare)"; t_kill="清理所有会话"; t_back="返回" ;;
esac

options=(" 🖥️  RDP (Windows Style) " " 🧊  VNC (Universal) " " 🐚  SSH (Secure Shell) " " 🧹  $t_kill " " ⬅️  $t_back ")
cursor=0

# --- Función para Dibujar el Portal ---
draw_menu() {
    clear
    echo -e "${VIOLETA_OSCURO}╭──────────────────────────────────────────────────────╮"
    echo -e "│${RESET}${BOLD}${MAGENTA_NEON}          💜  $t_tit  💜          ${RESET}${VIOLETA_OSCURO}│"
    echo -e "╰──────────────────────────────────────────────────────╯${RESET}"
    echo -e "${DIM}  Navega con [↑/↓] y confirma con [ENTER]${RESET}\n"

    for i in "${!options[@]}"; do
        if [ $i -eq $cursor ]; then
            # Efecto de selección con flecha brillante y fondo
            echo -e "  ${MAGENTA_NEON}➜ ${BG_SELECT}${WHITE}${BOLD} ${options[$i]} ${RESET}"
        else
            # Opciones no seleccionadas con tono lavanda suave
            echo -e "     ${LAVANDA}${options[$i]}${RESET}"
        fi
    done
    echo -e "\n${VIOLETA_OSCURO}────────────────────────────────────────────────────────${RESET}"
}

# --- Efecto de Carga (Detalle visual) ---
loading_effect() {
    local message=$1
    echo -ne "${MORADO_SUAVE}⏳ $message"
    for i in {1..3}; do echo -ne "."; sleep 0.4; done
    echo -e "${GREEN} Hecho!${RESET}"
}

# --- Lógica de Ngrok v3 ---
install_ngrok() {
    if ! command -v ngrok &> /dev/null; then
        echo -e "${CYAN_GLITCH}✨ Descargando motor Ngrok v3...${RESET}"
        wget -q --show-progress https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz -O /tmp/ngrok.tgz
        sudo tar -xvzf /tmp/ngrok.tgz -C /usr/local/bin > /dev/null
        ngrok config add-authtoken 1uNKiNAV8XVggSemelPcZmjYXuI_5zQY3FmebAtuHBhx2YuW5 > /dev/null
        rm /tmp/ngrok.tgz
    fi
}

# --- Submenú de Alcance con Flechas ---
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
                0|1) # RDP o VNC
                    type_conn=$([ $cursor -eq 0 ] && echo "RDP" || echo "VNC")
                    port=$([ $cursor -eq 0 ] && echo "3389" || echo "5901")
                    
                    loading_effect "Iniciando servicios de $type_conn"
                    if [ $cursor -eq 0 ]; then
                        yay -S --needed --noconfirm xrdp xorgxrdp &> /dev/null
                        sudo systemctl enable --now xrdp &> /dev/null
                    else
                        sudo pacman -S --needed --noconfirm tigervnc &> /dev/null
                        vncserver :1 &> /dev/null
                    fi
                    
                    select_scope "$type_conn"
                    scope=$?
                    case $scope in
                        1) install_ngrok; echo -e "${MAGENTA_NEON}Abre este link en tu otro dispositivo:${RESET}"; ngrok tcp $port ;;
                        2) sudo pacman -S --needed --noconfirm cloudflared &> /dev/null; cloudflared tunnel --url tcp://localhost:$port ;;
                        0) echo -e "${GREEN}✔ Listo! Conexión local abierta en puerto $port.${RESET}"; sleep 2 ;;
                    esac
                    ;;
                2) # SSH
                    loading_effect "Activando túnel seguro SSH"
                    sudo pacman -S --needed --noconfirm openssh &> /dev/null
                    sudo systemctl enable --now sshd &> /dev/null
                    echo -e "${GREEN}✔ SSH funcionando correctamente.${RESET}"; sleep 2
                    ;;
                3) # Limpiar
                    loading_effect "Cerrando todos los servicios"
                    sudo pkill ngrok &> /dev/null
                    sudo pkill cloudflared &> /dev/null
                    sudo systemctl stop xrdp &> /dev/null
                    vncserver -kill :1 &> /dev/null
                    echo -e "${RED}🧹 Sesiones limpias.${RESET}"; sleep 2
                    ;;
                4) exit 0 ;;
            esac
            ;;
    esac
done