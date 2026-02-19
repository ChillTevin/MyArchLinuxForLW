import sys
import random
import os

# --- Estética ---
NARANJA = '\033[38;5;216m'
VERDE = '\033[38;5;151m'
ROJO = '\033[38;5;196m'
RESET = '\033[0m'
BOLD = '\033[1m'

def cargar_datos(nivel_raw):
    # Limpiamos el nombre del nivel (ej: de "HSK 1 " a "hsk1")
    nivel = nivel_raw.split()[0].lower() + nivel_raw.split()[1]
    ruta = f"data/hsk/{nivel}.txt"
    
    vocabulario = []
    if not os.path.exists(ruta):
        print(f"\n{ROJO}Error: No se encontró el archivo {ruta}{RESET}")
        return None

    with open(ruta, 'r', encoding='utf-8') as f:
        for linea in f:
            partes = linea.strip().split('|')
            if len(partes) == 3:
                vocabulario.append(partes)
    return vocabulario

def ejecutar_quiz():
    # Recibir argumentos de mod_chinese
    # sys.argv[1] = Nivel (HSK 1) | sys.argv[2] = Pinyin (0/1)
    if len(sys.argv) < 3: return

    nivel_label = sys.argv[1]
    pinyin_on = sys.argv[2] == "1"
    
    vocab = cargar_datos(nivel_label)
    if not vocab: return

    random.shuffle(vocab)
    puntos = 0
    total = len(vocab)

    os.system('clear')
    print(f"{NARANJA}{BOLD}=== MODO QUIZ: {nivel_label} ==={RESET}\n")

    for hanzi, pinyin, espanol in vocab:
        pregunta = f"{hanzi} ({pinyin})" if pinyin_on else hanzi
        
        print(f"¿Qué significa: {BOLD}{pregunta}{RESET}?")
        respuesta_usuario = input(f"{NARANJA}➜ {RESET}").strip().lower()

        # Validación simple (puedes mejorarla para aceptar sinónimos)
        if respuesta_usuario == espanol.lower():
            print(f"{VERDE}¡Correcto! ✨{RESET}\n")
            puntos += 1
        else:
            print(f"{ROJO}Incorrecto. Era: {espanol}{RESET}\n")

    print(f"{NARANJA}Finalizado. Puntuación: {puntos}/{total}{RESET}")

if __name__ == "__main__":
    try:
        ejecutar_quiz()
    except KeyboardInterrupt:
        print("\n\nSaliendo del quiz...")
