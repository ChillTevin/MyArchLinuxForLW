#!/bin/bash
# Simulación de Flashcards en Bash
clear
echo -e "\033[38;5;216m"
echo "  [ Módulo de Idiomas ]"
echo "  Traducción: Chino -> Español"
echo "  ----------------------------"

# Base de datos simple: "Palabra|Significado"
preguntas=("你好|Hola" "谢谢|Gracias" "老师|Profesor")
item=${preguntas[$RANDOM % ${#preguntas[@]}]}

pregunta=$(echo $item | cut -d'|' -f1)
respuesta=$(echo $item | cut -d'|' -f2)

echo -e "\n  ¿Cómo se traduce: $pregunta?"
read -p "  Tu respuesta: " user_res

if [ "$user_res" == "$respuesta" ]; then
    echo -e "\n  ✅ ¡Correcto!"
else
    echo -e "\n  ❌ Incorrecto. Era: $respuesta"
fi
sleep 2
