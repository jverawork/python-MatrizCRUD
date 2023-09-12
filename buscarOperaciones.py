import re
import lib_extractTableNames

listaTokens = ["ROUND","NVL","TO_DATE", "TRUNC","ABS","ADD_MONTHS","SUBSTR","COALESCE","LIKE","ON",".FIRST",".NEXT"]

def buscaroperacion(codigo_plsql):
    buscartablas_select(codigo_plsql)

def identificarTablas(sentencia):
    return [elemento.replace("<ARROBA>", "@") for elemento in lib_extractTableNames.extract_tables(sentencia)]

def buscartablas_select(codigo_plsql):    
    patron = r'((?:SELECT)(?:.|\s)+?(?:FROM|JOIN)(?:.|\s)+?(?:(?=;)|(?=(?:\s*\)\s*LOOP\s+))))'
    sentencias = re.findall(patron, codigo_plsql, re.IGNORECASE | re.DOTALL)      
    
    tablas = []
    for sentencia in sentencias:
        #print(sentencia)
        tablas = tablas + identificarTablas(sentencia)
    
    #return list(set(tablas))#retorna unico elemento    
    return tablas

def buscartablas_delete(codigo):           
    patron = r'\bDELETE\b[^;]*?\bFROM\b\s+([^\s;]+)' 
    sentencias1 = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    patron = r'\bDELETE\b\s+((?!FROM\b)[^\s;]+)'
    sentencias2 = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    return sentencias1+sentencias2

def buscartablas_insert(codigo):           
    patron = r'\bINSERT\b[^;]*?\bINTO\b\s+([^\s;]+)' 
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias

def buscartablas_update(codigo):          
    patron = r'\bUPDATE\b\s+([^\s;]+)'
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias

def buscartablas_merge(codigo):          
    patron = r'\bMERGE\b[^;]*?\bINTO\b\s+([^\s;]+)' 
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias

def buscartablas_nextval(codigo):          
    patron = r'(?:\w|\.)+NEXTVAL@?(?:\w|\.)*' 
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias

def buscar_execute(codigo, sentencia, procesosInternos):          
    patron = r'(\b[A-Z_]\w*\.\w*\.?\w*)\s*\((?:.|\s)+?;' 
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    sentencias = [palabra for palabra in sentencias if not palabra.startswith('SYS.')]
    sentencias = [x for x in sentencias if x not in listaTokens]    

    sentencias = [palabra for palabra in sentencias if not any(palabra.endswith(termino) for termino in listaTokens)]

    sentencias = [x for x in sentencias if x not in sentencia["SELECT"]]
    sentencias = [x for x in sentencias if x not in sentencia["INSERT"]]
    sentencias = [x for x in sentencias if x not in sentencia["DELETE"]]
    sentencias = [x for x in sentencias if x not in sentencia["UPDATE"]]
    sentencias = [x for x in sentencias if x not in sentencia["MERGE"]]

    patron = r'([A-Z_]\w+)\s*\([^;]+?(?:;|=)' 
    sentencias2 = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    try:
        sentencias2 = [palabra for palabra in sentencias2 if any(palabra.endswith(termino) for termino in procesosInternos)]
    except Exception as error:
        print("-----------Error-----------")
        print(sentencias2)
    sentencias.extend(sentencias2)
    #[print(x) for x in sentencias]

    return sentencias