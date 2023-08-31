import re
import lib_extractTableNames

def buscaroperacion(codigo_plsql):
    buscartablas_select(codigo_plsql)

def identificarTablas(sentencia):
    return [elemento.split()[0] for elemento in lib_extractTableNames.extract_tables(sentencia)]

def buscartablas_select(codigo_plsql):    
    patron = r'((?:SELECT)(?:.|\s)+?(?:FROM|JOIN)(?:.|\s)+?(?:(?=;)|(?=(?:\s*\)\s*LOOP\s+))))'
    sentencias = re.findall(patron, codigo_plsql, re.IGNORECASE | re.DOTALL)      
    
    tablas = []
    for sentencia in sentencias:
        tablas = tablas + identificarTablas(sentencia)
    
    return list(set(tablas))

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