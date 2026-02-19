import sys
import random

# Colores para mantener la estética
NARANJA = '\033[38;5;216m'
RESET = '\033[0m'

def quiz():
    # Obtener argumentos de Bash
    nivel_label = sys.argv[1] if len(sys.argv) > 1 else "HSK 1"
    pinyin_on = sys.argv[2] == "1"
    
    # Datos de ejemplo (Esto se puede mover a un .txt)
    vocab = [
        ["你好", "Nǐ hǎo", "Hola"],
        ["谢谢", "Xièxiè", "Gracias"],
        ["老师", "Lǎoshī", "Profesor"],
        ["学生", "Xuésheng", "Estudiante"]
    ]
    
    print(f"\n{NARANJA}--- QUIZ ACTIVO: {nivel_label} ---{RESET}")
    random.shuffle(vocab)
    
    for char, pin, esp in vocab:
        pregunta = f"{char} ({pin})" if pinyin_on else char
        res = input(f"¿Significado de {pregunta}?: ").strip().lower()
        
        if res == esp.lower():
            print("✨ ¡Correcto!")
        else:
            print(f"❌ Error. La respuesta era: {esp}")

if __name__ == "__main__":
    quiz()
