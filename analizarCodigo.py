import re
import pyparsing as pp
from tip_estructuras import hm_operaciones, hm_procesos, hm_paquete

def limpiar_comentarios(textosql):
    sql_single_line_comment = '--' + pp.rest_of_line
    sql_multi_line_comment = pp.c_style_comment
    comment_remover = (
        # parse quoted strings separately so that they don't get suppressed
        pp.quoted_string
        | (sql_single_line_comment | sql_multi_line_comment).suppress()
    )
    return comment_remover.transform_string(textosql)
    
def limpiarDuplicados(listaTablas):
    return list(set(listaTablas))
    
def buscaroperacion_select(codigo_plsql, operacion):         
    #patron = r'\b(?:SELECT|UPDATE)\b(?:\s|\n)+.*?\bFROM\b(?:\s|\n)+(\w+)\b'
    #patron = r'\b(?:SELECT|UPDATE)\b.*?\bFROM\b(?:\s|[\w.\n])*?(\w+)\b'
    #patron = r'\b(?:SELECT|UPDATE)\b[^;]*?\bFROM\b\s+([^\s;]+)'
    #patron = r'\b(SELECT|UPDATE)\b[^;]*?\bFROM\b\s+([^\s;]+)' 
    #patron = r'\b(SELECT|UPDATE)\b.*?\bFROM\b\s+(\w+)(?=\s*;)' -not
    #patron = r'\b(SELECT|UPDATE)\b.*?\bFROM\b\s+(\w+)(?=[^;]*;)' 
    #patron = r'\b(SELECT|UPDATE)\b\s+([\w.*]+)\s+FROM\s+(\w+)(?=[^;]*;)'
    
    codigo = limpiar_comentarios(codigo_plsql)
    #patron = rf'\b{operacion}\b[^;]*?\bFROM\b\s+([^\s;]+)' 
    #patron = r'\bSELECT\b[^;]*?\bFROM\b\s+([^\s;]+)' 
    patron = r'\bSELECT\b(?!.*\))(.*?)(?<=\bFROM\b\s+)([^\s;,()]+)'
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)      
    return sentencias

def buscaroperacion_delete(codigo):           
    patron = r'\bDELETE\b[^;]*?\bFROM\b\s+([^\s;]+)' 
    sentencias1 = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    patron = r'\bDELETE\b\s+((?!FROM\b)[^\s;]+)'
    sentencias2 = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    return sentencias1+sentencias2
    
def buscaroperacion_insert(codigo):           
    patron = r'\bINSERT\b[^;]*?\bINTO\b\s+([^\s;]+)' 
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias
        
def buscaroperacion_update(codigo):          
    patron = r'\bUPDATE\b\s+([^\s;]+)'
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias

def buscaroperacion_merge(codigo):          
    patron = r'\bMERGE\b[^;]*?\bINTO\b\s+([^\s;]+)' 
    sentencias = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)        
    return sentencias

def get_operations(tablas):
    operations = {table: [] for table in tablas}
    for match in operaciones["SELECT"]:
        if match in operations:
            operations[match].append("SELECT")    
    for match in operaciones["UPDATE"]:
        if match in operations:
            operations[match].append("UPDATE")

    for match in operaciones["INSERT"]:
        if match in operations:
            operations[match].append("INSERT")

    for match in operaciones["DELETE"]:
        if match in operations:
            operations[match].append("DELETE")

    for match in operaciones["MERGE"]:
        if match in operations:
            operations[match].append("MERGE")
    return operations



def obtenerNombrePaquete(codigo):
    expresion_regular = r'\bPACKAGE BODY\b\s+([^\s;]+)'
    resultado = re.search(expresion_regular, codigo)
    return resultado

def obtenerCodigoProcesos(codigo, nombreProceso, clausula):
    if clausula == "FUNCTION":
        expresion_regular = rf"FUNCTION\s+{nombreProceso}\s*\(.*\)\s*RETURN.*?END\s+{nombreProceso};"
    else:
        expresion_regular = rf"PROCEDURE\s+{nombreProceso}\s*\((.*?)\)\s*IS(.*?)END\s+{nombreProceso};"

    resultado = re.search(expresion_regular, codigo, re.DOTALL)
    return resultado

def segmentarCodigo(codigo):   
    global hm_procesos
    global hm_paquete
    procesos = re.findall(r'FUNCTION\s+(\w+)', codigo)    
    operacion = hm_procesos.copy()
    for proceso in procesos:        
        codigoInterno = obtenerCodigoProcesos(codigo, proceso, "FUNCTION")
        if codigoInterno is not None:
            codigo = codigo.replace(codigoInterno[0],"")            
            operacion = hm_procesos.copy()
            operacion.update({"TIPO":"FUNCTION", "NOMBRE_PROCESO":proceso, "CODIGO": codigoInterno[0]})
            hm_paquete["LISTA_PROCESOS"].append (operacion)
        else:
            print(f"Esta funcion tiene algun problema: {proceso}")
    procesos = re.findall(r'PROCEDURE\s+(\w+)', codigo)      
    for proceso in procesos:        
        codigoInterno = obtenerCodigoProcesos(codigo, proceso, "PROCEDURE")
        if codigoInterno is not None:
            codigo = codigo.replace(codigoInterno[0],"")
            operacion = hm_procesos.copy()
            operacion.update({"TIPO":"PROCEDURE", "NOMBRE_PROCESO":proceso, "CODIGO": codigoInterno[0]})
            hm_paquete["LISTA_PROCESOS"].append (operacion)
        else:
            print(f"Este procedimiento tiene algun problema: {proceso}")
    return codigo
    
def encontrarOperacionesUnicas(codigo): #aun no se usa
    operaciones["SELECT"] = limpiarDuplicados(buscaroperacion_select(codigo,'SELECT'))
    operaciones["INSERT"] = limpiarDuplicados(buscaroperacion_insert(codigo))
    operaciones["DELETE"] = limpiarDuplicados(buscaroperacion_delete(codigo))
    operaciones["UPDATE"] = limpiarDuplicados(buscaroperacion_update(codigo))
   
def encontrarOperaciones(codigo, operacion): 
    sentencia = hm_operaciones.copy()
    sentencia["SELECT"] = buscaroperacion_select(codigo,'SELECT')
    sentencia["INSERT"] = buscaroperacion_insert(codigo)
    sentencia["DELETE"] = buscaroperacion_delete(codigo)
    sentencia["UPDATE"] = buscaroperacion_update(codigo)   
    sentencia["MERGE"]  = buscaroperacion_merge(codigo) 
    operacion["OPERACIONES"] = sentencia
    return operacion

def analizarOperacionesEnProcesos():
    global hm_paquete
    for i in range(len(hm_paquete["LISTA_PROCESOS"])):
        operacion = hm_paquete["LISTA_PROCESOS"][i]
        operacion = encontrarOperaciones(operacion["CODIGO"],operacion) 
        hm_paquete["LISTA_PROCESOS"][i] = operacion
        if operacion["NOMBRE_PROCESO"]=="CRE_CONSULTACATALOGO_P":
            print(operacion["OPERACIONES"])
            return
        #print(f"---{hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO']}---")
        #print(f"{hm_paquete['LISTA_PROCESOS'][i]['OPERACIONES']}")
 