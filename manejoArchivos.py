def abrir_archivo(path):
    try:
        with open(path, 'r') as file:
            codigo_plsql = file.read().upper() 
        return  codigo_plsql
    except FileNotFoundError:
        print("Error: No se encontró el archivo especificado.")
        