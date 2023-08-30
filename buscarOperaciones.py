import re
import lib_extractTableNames

def buscaroperacion(codigo_plsql):
    buscartablas_select(codigo_plsql)

def buscartablas_select(codigo_plsql):    
    patron = r'((?:SELECT)(?:.|\s)+?(?:FROM|JOIN)(?:.|\s)+?(?:(?=;)|(?=(?:\s*\)\s*LOOP\s+))))'

    sentencias = re.findall(patron, codigo_plsql, re.IGNORECASE | re.DOTALL)      
    
    tablas = []
    for sentencia in sentencias:
        tablas = tablas + identificarTablas(sentencia)
    
    return list(set(tablas))


def identificarTablas(sentencia):
    return [elemento.split()[0] for elemento in lib_extractTableNames.extract_tables(sentencia)]

