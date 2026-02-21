#!/bin/bash

# --- PROTOCOLO DE LOCALIZACIÓN ABSOLUTA ---
DIR_BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RUTA_THEMES_RAIZ="$DIR_BASE/Complement/theme"
ARCHIVO_ESTADO="$DIR_BASE/.tema_actual"
IDIOMA_SISTEMA="$1"

# Colores fijos para identificación de archivos (Independientes del tema)
ROSA='\033[38;5;211m'
VIOLETA='\033[38;5;141m'

# Crear carpeta raíz si no existe
mkdir -p "$RUTA_THEMES_RAIZ"

# Traducciones
case "$IDIOMA_SISTEMA" in
    "Inglés")          t_conf="SETTINGS"; t_th="Themes"; t_bk="Back" ;;
    "Chino (Hanzi)")   t_conf="设置"; t_th="主题"; t_bk="返回" ;;
    *)                 t_conf="CONFIGURACIÓN"; t_th="Temas"; t_bk="Volver" ;;
esac

# --- FUNCIÓN DE EXPLORACIÓN DE TEMAS ---
menu_explorar_temas() {
    local ruta_actual="$1"
    [ -z "$ruta_actual" ] && ruta_actual="$RUTA_THEMES_RAIZ"
    local sel_t=0

    while true; do
        # Detectar carpetas y archivos themes_*.sh / themes_*.py
        items=()
        # 1. Carpetas
        while IFS= read -r -d $'\0' d; do items+=("$(basename "$d")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -z)
        # 2. Archivos permitidos
        while IFS= read -r -d $'\0' f; do items+=("$(basename "$f")"); done < <(find "$ruta_actual" -mindepth 1 -maxdepth 1 -type f \( -name "themes_*.sh" -o -name "themes_*.py" \) -print0 2>/dev/null | sort -z)
        
        # Opción de retroceso
        if [ "$ruta_actual" == "$RUTA_THEMES_RAIZ" ]; then items+=("EXIT_INTERNAL"); else items+=(".._BACK"); fi

        local total=${#items[@]}
        clear
        echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "           $t_th "
        echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

        for i in "${!items[@]}"; do
            nombre="${items[$i]}"
            color_item="$NARANJA" # Color por defecto para carpetas
            icono=" "

            if [[ "$nombre" == "EXIT_INTERNAL" ]]; then
                nombre="$t_bk"; icono="󰌍 "
            elif [[ "$nombre" == ".._BACK" ]]; then
                nombre=".. $t_bk"; icono="󰌍 "
            elif [[ "$nombre" == *.sh ]]; then
                color_item="$ROSA"; icono="󱆃 "; nombre="${nombre#themes_}"; nombre="${nombre%.sh}"
            elif [[ "$nombre" == *.py ]]; then
                color_item="$VIOLETA"; icono=" "; nombre="${nombre#themes_}"; nombre="${nombre%.py}"
            fi

            if [ "$sel_t" -eq $i ]; then
                printf "  ${BG_SEL}${FG_SEL}${BOLD}  %s %-30s ${RESET}\n" "$icono" "$nombre"
            else
                printf "       ${color_item}%s %-30s${RESET}\n" "$icono" "$nombre"
            fi
        done

        read -rsn1 kt; [[ $kt == $'\e' ]] && { read -rsn2 rt; kt+="$rt"; }
        case "$kt" in
            $'\e[A') sel_t=$(( (sel_t + total - 1) % total )) ;;
            $'\e[B') sel_t=$(( (sel_t + 1) % total )) ;;
            "") 
                eleccion="${items[$sel_t]}"
                if [[ "$eleccion" == "EXIT_INTERNAL" ]]; then return 0; fi
                if [[ "$eleccion" == ".._BACK" ]]; then return 1; fi
                
                ruta_completa="$ruta_actual/$eleccion"

                if [ -d "$ruta_completa" ]; then
                    menu_explorar_temas "$ruta_completa"
                    [ $? -eq 0 ] && return 0 # Si sale con EXIT_INTERNAL, cerramos todo
                else
                    # Es un archivo: Guardar y Aplicar
                    echo "$ruta_completa" > "$ARCHIVO_ESTADO"
                    # Si es python, el sistema principal debería manejarlo, 
                    # pero aquí lo marcamos para que el script principal lo cargue.
                    return 0 # Salir de todo para refrescar el menú principal
                fi
                ;;
        esac
    done
}

# --- MENÚ PRINCIPAL DE CONFIGURACIÓN ---
sel_config=0
while true; do
    clear
    echo -e "${NARANJA}${BOLD}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "           $t_conf "
    echo -e "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

    opciones=("$t_th" "$t_bk")
    for i in "${!opciones[@]}"; do
        if [ "$sel_config" -eq $i ]; then
            printf "  ${BG_SEL}${FG_SEL}${BOLD}  %-35s ${RESET}\n" "${opciones[$i]}"
        else
            printf "       ${NARANJA}%-35s${RESET}\n" "${opciones[$i]}"
        fi
    done

    read -rsn1 k; [[ $k == $'\e' ]] && { read -rsn2 r; k+="$r"; }
    case "$k" in
        $'\e[A') sel_config=$(( (sel_config + 1) % 2 )) ;;
        $'\e[B') sel_config=$(( (sel_config + 1) % 2 )) ;;
        "") 
            if [ "$sel_config" -eq 1 ]; then exit 0; fi
            menu_explorar_temas
            [ $? -eq 0 ] && exit 0 # Salida total para refrescar el main
            ;;
    esac
done