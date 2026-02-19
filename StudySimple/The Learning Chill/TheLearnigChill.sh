#!/bin/bash

# --- Función para Definir Colores según la Hora ---
definir_colores() {
    HORA=$(date +%H)
    
    if [ "$HORA" -ge 06 ] && [ "$HORA" -lt 12 ]; then
        # TEMA MAÑANA (Cremas y Amarillos)
        COLOR_TITULO='\033[38;5;223m' # Piel/Crema
        COLOR_OPCION='\033[38;5;229m' # Amarillo suave
        COLOR_SEL='\033[38;5;214m'    # Naranja vibrante
        TEMA="Morning Glow"
    elif [ "$HORA" -ge 12 ] && [ "$HORA" -lt 19 ]; then
        # TEMA TARDE (Cielo y Frescura)
        COLOR_TITULO='\033[38;5;117m' # Azul cielo
        COLOR_OPCION='\033[38;5;153m' # Azul pálido
        COLOR_SEL='\033[38;5;151m'    # Verde pastel
        TEMA="Bright Day"
    else
        # TEMA ATARDECER/NOCHE (Violetas y Rosas)
        COLOR_TITULO='\033[38;5;175m' # Rosa viejo
        COLOR_OPCION='\033[38;5;146m' # Lavanda
        COLOR_SEL='\033[38;5;99m'     # Violeta
        TEMA="Sunset Chill"
    fi
    RESET='\033[0m'
    BOLD='\033[1m'
}

# --- Configuración de Opciones ---
opciones=("Conocimiento" "Configuración" "Salir")
seleccion=0

# --- Función para dibujar el menú ---
dibujar_menu() {
    definir_colores
    clear
    echo -e "${COLOR_TITULO}${BOLD}"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "         T H E   L E A R N I N G   C H I L L "
    echo "           (Modo: $TEMA)"
    echo "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""

    for i in "${!opciones[@]}"; do
        if [ $i -eq $seleccion ]; then
            # Estética Ranger: Flecha y resaltado
            echo -e " ${COLOR_SEL}  ➜ ${RESET}${BOLD}${COLOR_TITULO}▶ ${opciones[$i]}${RESET}"
        else
            echo -e "       ${COLOR_OPCION}${opciones[$i]}${RESET}"
        fi
    done

    echo -e "\n\n${COLOR_OPCION} [↑/↓] Navegar  [Enter] Seleccionar${RESET}"
}

# --- Bucle de entrada ---
while true; do
    dibujar_menu
    read -rsn3 tecla
    
    case "$tecla" in
        $'\e[A') # Arriba
            ((seleccion--))
            [ $seleccion -lt 0 ] && seleccion=$((${#opciones[@]} - 1))
            ;;
        $'\e[B') # Abajo
            ((seleccion++))
            [ $seleccion -ge ${#opciones[@]} ] && seleccion=0
            ;;
        "") # Enter
            case $seleccion in
                0) bash ./conocimiento.sh ;;
                1) echo "Config..." ; sleep 1 ;;
                2) clear ; exit 0 ;;
            esac
            ;;
    esac
done
