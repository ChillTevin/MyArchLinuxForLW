import sys, os, random, time, re

# --- Colores ---
NARANJA, VERDE, ROJO, GRIS, RESET, BOLD = '\033[38;5;216m', '\033[38;5;151m', '\033[38;5;196m', '\033[38;5;244m', '\033[0m', '\033[1m'

# --- Localización de Interfaz ---
TRADUCCIONES = {
    0: {"score": "Score", "preg": "Question", "correct": "Correct!", "wrong": "Wrong", "back": "Press Enter to return"}, # Inglés
    1: {"score": "分数", "preg": "问题", "correct": "正确!", "wrong": "错误", "back": "按回车键返回"}, # Hanzi
    2: {"score": "Fēnshù", "preg": "Wèntí", "correct": "Zhèngquè!", "wrong": "Cuòwù", "back": "Àn huíchē jiàn fǎnhuí"}, # Pinyin
    3: {"score": "Puntaje", "preg": "Pregunta", "correct": "¡Correcto!", "wrong": "Incorrecto", "back": "Presiona Enter para volver"} # Español
}

DIR_ACTUAL = os.path.dirname(os.path.abspath(__file__))
RUTA_CONTENT = os.path.join(DIR_ACTUAL, "content_HSK1")

def limpiar(): os.system('clear')

def parsear_simulacro(ruta_archivo):
    """Algoritmo que extrae preguntas y respuestas del formato ✅"""
    with open(ruta_archivo, 'r', encoding='utf-8') as f:
        contenido = f.read()
    
    # Separar por bloques numéricos (1. , 2. , etc)
    bloques = re.split(r'\n\d+\.\s+', "\n" + contenido)
    examen = []
    
    for b in bloques:
        if not b.strip(): continue
        lineas = b.strip().split('\n')
        if len(lineas) < 2: continue
        
        pregunta = lineas[0]
        opciones = []
        respuesta_correcta = ""
        
        for i, opt in enumerate(lineas[1:]):
            letra = chr(65 + i) # A, B, C...
            limpia = opt.replace("✅", "").strip()
            opciones.append(limpia)
            if "✅" in opt:
                respuesta_correcta = letra
        
        if respuesta_correcta:
            examen.append({"q": pregunta, "opts": opciones, "ans": respuesta_correcta})
    
    return examen

def ejecutar_simulacro(archivo, pinyin_on, lang_idx):
    lang = TRADUCCIONES.get(int(lang_idx), TRADUCCIONES[3])
    preguntas = parsear_simulacro(os.path.join(RUTA_CONTENT, archivo))
    
    if not preguntas:
        print(f"{ROJO}Formato de archivo inválido.{RESET}")
        return

    puntos = 0
    for i, p in enumerate(preguntas):
        limpiar()
        # Lógica de Pinyin: Si está apagado, removemos lo que esté entre paréntesis
        texto_pregunta = p['q']
        if pinyin_on == "0":
            texto_pregunta = re.sub(r'\(.*?\)', '', texto_pregunta)

        print(f"{NARANJA}{BOLD} {lang['preg']} {i+1}/{len(preguntas)} {RESET}")
        print(f"\n {BOLD}{texto_pregunta}{RESET}\n")
        
        for j, opt in enumerate(p['opts']):
            print(f"  {chr(65+j)}) {opt}")
        
        user = input(f"\n {NARANJA}➜ {RESET}").strip().upper()
        
        if user == p['ans']:
            print(f"\n {VERDE} {lang['correct']} {RESET}")
            puntos += 1
        else:
            print(f"\n {ROJO} {lang['wrong']}. {RESET} {BOLD}{p['ans']}{RESET}")
        
        time.sleep(1)

    limpiar()
    print(f"{NARANJA}{BOLD}=== {lang['score']} ==={RESET}")
    print(f"\n {puntos} / {len(preguntas)}")
    input(f"\n{GRIS}{lang['back']}{RESET}")

def main():
    if len(sys.argv) < 5: return
    
    pinyin_on = sys.argv[2]
    modo_bash = sys.argv[3]
    lang_idx = int(sys.argv[4])
    
    archivos = [f for f in os.listdir(RUTA_CONTENT) if f.endswith('.txt')]
    
    if modo_bash == "1": # Modo Simulacro / Lectura
        limpiar()
        print(f"{NARANJA}{BOLD} SELECCIONAR SIMULACRO {RESET}\n")
        for i, arc in enumerate(archivos):
            print(f"  {i+1}. {arc}")
        
        sel = input(f"\n {NARANJA}➜ {RESET}")
        if sel.isdigit() and 0 < int(sel) <= len(archivos):
            ejecutar_simulacro(archivos[int(sel)-1], pinyin_on, lang_idx)

if __name__ == "__main__":
    main()