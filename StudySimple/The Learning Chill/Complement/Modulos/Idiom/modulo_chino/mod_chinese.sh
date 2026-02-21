#!/bin/bash

# --- Configuración de Rutas ---
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUTA_HSK="$DIR_BASE/data/hsk"

# Recibimos el idioma desde el script principal (por defecto 3 = Español)
IDIOMA_SISTEMA=${1:-3}

# --- Configuración de Datos ---
niveles=("HSK 1 " "HSK 2 " "HSK 3 " "HSK 4 " "HSK 5 " "HSK 6 " "Custom ")
modos=("Quiz " "Lectura 󰉿" "Flashcard 󰴓" "Game 󰊴" "Internet 󰖟")

seleccion_hsk=0
seleccion_modo=0
pinyin_active=0 

# --- Estética y Colores ---
NARANJA='\033[38;5;216m'
BG_SEL='\033[48;5;216m'
FG_SEL='\033[38;5;235m'
GRIS='\033[38;5;244m'
ROJO='\033[38;5;196m'
RESET='\033[0m'
BOLD='\033[1m'

dibujar_menu() {
    clear
    tput cup 0 0
    echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "         M Ó D U L O   D E   C H I N O "
    echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    for i in "${!niveles[@]}"; do
        if [ "$seleccion_hsk" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${niveles[$i]}"
        else
            printf "       ${NARANJA}%-35s${RESET}\n" "${niveles[$i]}"
        fi
    done

    echo -e "\n  ${GRIS}────────────────────────────────────────${RESET}"
    p_status=$( [ $pinyin_active -eq 1 ] && echo "ON" || echo "OFF" )
    
    # Mostrar Modo y Pinyin actual
    printf "  ${NARANJA}Modo: ${RESET}${BOLD}< ${modos[$seleccion_modo]} >${RESET}  "
    printf "${NARANJA}Pinyin: ${RESET}${BOLD}[ $p_status ]${RESET}\n"
    
    echo -e "\n  ${GRIS}[↑/↓] Nivel  [←/→] Modo  [P] Pinyin  [Enter] Iniciar  [Q] Salir${RESET}"
}

# Ocultar cursor
tput civis

while true; do
    dibujar_menu
    read -rsn1 tecla
    
    # Manejo de flechas (secuencias de escape)
    if [[ $tecla == $'\e' ]]; then
        read -rsn2 -t 0.1 resto
        tecla+="$resto"
    fi

    case "$tecla" in
        $'\e[A') seleccion_hsk=$(( (seleccion_hsk + 6) % 7 )) ;; # Arriba
        $'\e[B') seleccion_hsk=$(( (seleccion_hsk + 1) % 7 )) ;; # Abajo
        $'\e[C') seleccion_modo=$(( (seleccion_modo + 1) % 5 )) ;; # Derecha
        $'\e[D') seleccion_modo=$(( (seleccion_modo + 4) % 5 )) ;; # Izquierda
        "p"|"P") pinyin_active=$(( (pinyin_active + 1) % 2 )) ;;
        "q"|"Q") 
            tput cnorm
            clear
            exit 0 
            ;;
        "") 
            # Lógica de Ejecución por Nivel
            case $seleccion_hsk in
                0) # HSK 1
                    tput cnorm
                    clear
                    ruta_python="$RUTA_HSK/hsk1/hsk1_engine.py"
                    
                    # 1. VERIFICACIÓN DE ERRORES: Avisa qué falta si no puede iniciar
                    if [ ! -f "$ruta_python" ]; then
                        echo -e "${ROJO}${BOLD}⚠️ ERROR CRÍTICO: No se puede iniciar.${RESET}"
                        echo -e "${GRIS}Falta el archivo del motor de Python.${RESET}"
                        echo -e "Ruta esperada: ${NARANJA}$ruta_python${RESET}\n"
                        read -rsn1 -p "Presiona cualquier tecla para volver al menú..."
                        tput civis
                        continue
                    fi

                    # 2. EJECUCIÓN PASANDO: Nivel, Pinyin_On, Modo_Seleccionado e IDIOMA_SISTEMA
                    python3 "$ruta_python" "${niveles[$seleccion_hsk]}" "$pinyin_active" "$seleccion_modo" "$IDIOMA_SISTEMA"
                    
                    echo -e "\n${GRIS}Presiona Enter para volver al menú de niveles...${RESET}"
                    read -r
                    tput civis
                    ;;
                *) # Otros niveles
                    echo -e "\n${ROJO}  ⚠️ El motor para ${niveles[$seleccion_hsk]} no está instalado.${RESET}"
                    echo -e "  ${GRIS}Crea la carpeta data/hsk/hsk$((seleccion_hsk + 1))/ para habilitarlo.${RESET}"
                    sleep 2
                    ;;
            esac
            ;;
    esac
done