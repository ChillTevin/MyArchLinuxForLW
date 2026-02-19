import sys
import random
import os

# Colores coincidentes con Bash
NARANJA = '\033[38;5;216m'
VERDE = '\033[38;5;151m'
ROJO = '\033[38;5;196m'
RESET = '\033[0m'
BOLD = '\033[1m'

def cargar_datos(nivel_raw):
    # Convierte "HSK 1 " en "hsk1" para buscar el archivo
    partes = nivel_raw.split()
    nombre_archivo = (partes[0] + partes[1]).lower()
    ruta = f"data/hsk/{nombre_archivo}.txt"
    
    vocabulario = []
    if not os.path.exists(ruta):
        print(f"\n{ROJO}Error: No se encontró {ruta}{RESET}")
        return None

    with open(ruta, 'r', encoding='utf-8') as f:
        for linea in f:
            if '|' in linea:
                vocabulario.append(linea.strip().split('|'))
    return vocabulario

def quiz():
    if len(sys.argv) < 3: return
    nivel_label = sys.argv[1]
    pinyin_on = sys.argv[2] == "1"
    
    vocab = cargar_datos(nivel_label)
    if not vocab: return

    random.shuffle(vocab)
    os.system('clear')
    print(f"{NARANJA}{BOLD}=== QUIZ: {nivel_label} ==={RESET}\n")

    for hanzi, pinyin, espanol in vocab:
        pregunta = f"{hanzi} ({pinyin})" if pinyin_on else hanzi
        print(f"¿Significado de {BOLD}{pregunta}{RESET}?")
        res = input(f"{NARANJA}➜ {RESET}").strip().lower()

        if res == espanol.lower():
            print(f"{VERDE}¡Correcto! ✨{RESET}\n")
        else:
            print(f"{ROJO}Incorrecto. Era: {espanol}{RESET}\n")

if __name__ == "__main__":
    quiz()
