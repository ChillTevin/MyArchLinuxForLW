import os
import sys
import subprocess

# --- Auto-instalación de dependencias ---
try:
    import requests
except ImportError:
    subprocess.check_call([sys.executable, "-m", "pip", "install", "requests", "--break-system-packages"])
    import requests

# --- Configuración Visual ---
VERDE = '\033[0;32m'
NARANJA = '\033[38;5;216m'
RESET = '\033[0m'
BOLD = '\033[1m'

def buscar_nosis():
    os.system('clear')
    print(f"{NARANJA}{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print(f"       B U S C A D O R   N O S I S  (Py)")
    print(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{RESET}\n")

    query = input(f"{BOLD}Ingrese DNI, CUIL o Apellido: {RESET}").strip()
    
    if not query:
        return

    # URL actualizada para el buscador de Nosis
    # Probamos con el buscador de informes directos
    url = f"https://informes.nosis.com/Home/Buscar?q={query}"
    
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8",
        "Accept-Language": "es-AR,es;q=0.8,en-US;q=0.5,en;q=0.3",
    }

    print(f"\n{NARANJA}Conectando con la base de datos de Nosis...{RESET}")

    try:
        # Usamos una sesión para mantener cookies (más parecido a un humano)
        session = requests.Session()
        response = session.get(url, headers=headers, timeout=15)
        
        if response.status_code == 200:
            print(f"\n{VERDE}{BOLD}[ RESULTADOS DE LA BÚSQUEDA ]{RESET}")
            print(f"{VERDE}")
            
            # Buscamos si el nombre aparece en el HTML
            if query.lower() in response.text.lower():
                print(f"✅ Se encontró información para: {query}")
                print(f"🔗 Link directo al informe: {url}")
                print(f"\n{RESET}Nota: Nosis requiere interacción manual para ver el PDF.")
            else:
                print(f"⚠️ No se encontraron resultados directos para '{query}'.")
                print(f"Prueba con un CUIL exacto.")
            
        elif response.status_code == 404:
            print(f"\n{NARANJA}Error 404: La página de búsqueda no fue encontrada.{RESET}")
            print("Nosis ha cambiado su estructura de URLs nuevamente.")
        else:
            print(f"\n{NARANJA}Estado del servidor: {response.status_code}{RESET}")

    except Exception as e:
        print(f"\n{NARANJA}Error: {e}{RESET}")

    print(f"\n{NARANJA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    input(f"Presiona Enter para volver...{RESET}")

if __name__ == "__main__":
    buscar_nosis()