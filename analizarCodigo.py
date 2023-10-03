import re
import buscarOperaciones
from tip_estructuras import hm_operaciones, hm_procesos, hm_paquete

import util_log
    
def limpiarDuplicados(listaTablas):
    return list(set(listaTablas))
    
def buscaroperacion_select(codigo):         
    return buscarOperaciones.buscartablas_select(codigo)   

def buscaroperacion_delete(codigo):           
    return buscarOperaciones.buscartablas_delete(codigo)
    
def buscaroperacion_insert(codigo):           
    return buscarOperaciones.buscartablas_insert(codigo)
        
def buscaroperacion_update(codigo):          
    return buscarOperaciones.buscartablas_update(codigo)

def buscaroperacion_merge(codigo):          
    return buscarOperaciones.buscartablas_merge(codigo)

def buscaroperacion_nextval(codigo):
    return buscarOperaciones.buscartablas_nextval(codigo)

def buscaroperacion_execute(codigo, sentencia, listaProcesos):          
    return buscarOperaciones.buscar_execute(codigo, sentencia, listaProcesos)

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
            util_log.logError(proceso, None, None, procesos, "analizarCodigo.segmentarCodigo\n", e)
    procesos = re.findall(r'PROCEDURE\s+(\w+)', codigo)      
    for proceso in procesos:        
        codigoInterno = obtenerCodigoProcesos(codigo, proceso, "PROCEDURE")
        if codigoInterno is not None:
            codigo = codigo.replace(codigoInterno[0],"")
            operacion = hm_procesos.copy()
            operacion.update({"TIPO":"PROCEDURE", "NOMBRE_PROCESO":proceso, "CODIGO": codigoInterno[0]})
            hm_paquete["LISTA_PROCESOS"].append (operacion)
        else:
            util_log.logError(proceso, None, None, procesos, "analizarCodigo.segmentarCodigo\n", e)
    return codigo
    
def encontrarOperaciones(codigo, procedimiento, lista_hm_procesos): 
    operaciones = hm_operaciones.copy()
    operaciones["SELECT"] = buscaroperacion_select(codigo)
    operaciones["INSERT"] = buscaroperacion_insert(codigo)
    operaciones["DELETE"] = buscaroperacion_delete(codigo)
    operaciones["UPDATE"] = buscaroperacion_update(codigo)   
    operaciones["MERGE"]  = buscaroperacion_merge(codigo) 
    operaciones["NEXTVAL"]  = buscaroperacion_nextval(codigo) 
    
    #Obtiene la lista de procesos del paquete de la lista de hm_procesos que es de tipo diccionario
    listaProcesosDelPaquete = [diccionario["NOMBRE_PROCESO"] for diccionario in lista_hm_procesos if "NOMBRE_PROCESO" in diccionario]
    
    #Remueve de la lista de procedimientos/funciones invocados el nombre del proceso analizado
    if procedimiento["TIPO"] in ('PROCEDURE', 'FUNCTION'):
        listaProcesosDelPaquete.remove(procedimiento["NOMBRE_PROCESO"])

    operaciones["EXECUTE"]  = buscaroperacion_execute(codigo, operaciones, listaProcesosDelPaquete) 
    
    procedimiento["OPERACIONES"] = operaciones
    
    return procedimiento

def analizarOperacionesEnProcesos():
    global hm_paquete
    for i in range(len(hm_paquete["LISTA_PROCESOS"])):
        operacion = hm_paquete["LISTA_PROCESOS"][i]
        operacion = encontrarOperaciones(operacion["CODIGO"],operacion, hm_paquete["LISTA_PROCESOS"]) 
        operacion["PARAMETROS"] = buscarParametros(operacion["CODIGO"], hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO'])
        operacion["PARAMETROS-DBLINK"] = buscarParametrosDBLink(operacion["CODIGO"], hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO'])
        operacion["VARIABLES"] = buscarVariables(operacion["CODIGO"], hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO'])
        operacion["VARIABLES-DBLINK"] = buscarVariablesDBLink(operacion["CODIGO"], hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO'])
        hm_paquete["LISTA_PROCESOS"][i] = operacion        
        util_log.log( hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO'], 1, operacion, None, None, "analizarCodigo.analizarOperacionesEnProcesos")    

def analizarOperacionesEnCuerpo():
    global hm_paquete
    
    procedimiento = encontrarOperaciones(hm_paquete["CODIGO"],hm_paquete, hm_paquete["LISTA_PROCESOS"]) 
    hm_paquete["OPERACIONES"] = procedimiento["OPERACIONES"]
    hm_paquete["VARIABLES"] = buscarVariables(hm_paquete["CODIGO"], hm_paquete['NOMBRE_PROCESO'])
    hm_paquete["VARIABLES-DBLINK"] = buscarVariablesDBLink(hm_procesos["CODIGO"], hm_paquete['NOMBRE_PROCESO'])    
           
    util_log.log(hm_paquete['NOMBRE_PROCESO'], 1, hm_paquete, None, None, "analizarCodigo.analizarOperacionesEnCuerpo")    

def buscarParametros(codigo, nombreProceso):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:    
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    

            patron = r'(\w+\.?\w+\.?\w+)(?=(?:%ROWTYPE\s*,|%TYPE\s*,|%TYPE))'
            parametros = re.findall(patron, definiciones[0], re.IGNORECASE | re.DOTALL)    
            #return list(set(parametros))    
            return parametros

def buscarParametrosDBLink(codigo, nombreProceso):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:    
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    

            patron = r'((?:\w|\.)*@(?:\w|\.)*)(?=(?:%ROWTYPE;|%TYPE;|%TYPE))'
            #patron = r'((?:\w|\.)*<ARROBA>(?:\w|\.)*)(?=(?:%ROWTYPE;|%TYPE;|%TYPE))'
            parametros = re.findall(patron, definiciones[0], re.IGNORECASE | re.DOTALL)    
            util_log.log(nombreProceso, 4, None, codigo, parametros, "analizarCodigo.buscarParametrosDBLink")
            
            variables = [elemento.split('@') for elemento in parametros]
            #variables = [elemento.split('<ARROBA>') for elemento in parametros]
            util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarParametrosDBLink")             
            #return list(set(parametros))    
            return parametros

def buscarVariables(codigo, nombreProceso):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:
            #SE excluye el codigo que esta entre parentesis
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
            codigo = codigo.replace(definiciones[0],"")
            util_log.log(nombreProceso, 5, None, codigo, None, "analizarCodigo.buscarVariables\n"+codigo)
    
    patron = r'(\w+\.\w+\.?\w+)(?=(?:%ROWTYPE;|%TYPE;|%TYPE))'
    variables = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)   
    util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarVariables")

    return variables

def buscarVariablesDBLink(codigo, nombreProceso):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
            codigo = codigo.replace(definiciones[0],"")  

    #Buscar variables con DBLINK - que contienen una arroba
    patron = r'((?:\w|\.)*@(?:\w|\.)*)(?=(?:%ROWTYPE;|%TYPE;|%TYPE))'
    #patron = r'((?:\w|\.)*\<ARROBA\>(?:\w|\.)*)(?=(?:%ROWTYPE;|%TYPE;|%TYPE))'
    variables = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)   
    util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarVariablesDBLink")
    
    variables = [elemento.split('@') for elemento in variables]
    #variables = [elemento.split('<ARROBA>') for elemento in variables]
    util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarVariablesDBLink")
    return variables


