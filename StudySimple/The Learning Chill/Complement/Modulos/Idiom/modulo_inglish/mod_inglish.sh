#!/bin/bash
IDIOMA_SISTEMA=$1

case "$IDIOMA_SISTEMA" in
    "Inglés") TITULO="ENGLISH MODULE"; INSTR="Press Enter to start" ;;
    "Chino (Hanzi)") TITULO="英语模块"; INSTR="按回车键开始" ;;
    *) TITULO="MÓDULO DE INGLÉS"; INSTR="Presiona Enter para empezar" ;;
esac

# ... usar estas variables en los echo y printf ...
