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
    lista = buscarOperaciones.buscartablas_insert(codigo)
    print(lista)
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
   
def encontrarOperaciones(codigo, proceso, listaProcesos): 
    sentencia = hm_operaciones.copy()
    sentencia["SELECT"] = buscaroperacion_select(codigo)
    sentencia["INSERT"] = buscaroperacion_insert(codigo)
    sentencia["DELETE"] = buscaroperacion_delete(codigo)
    sentencia["UPDATE"] = buscaroperacion_update(codigo)   
    sentencia["MERGE"]  = buscaroperacion_merge(codigo) 
    sentencia["NEXTVAL"]  = buscaroperacion_nextval(codigo) 
    
    listaProcesos = [diccionario["NOMBRE_PROCESO"] for diccionario in listaProcesos if "NOMBRE_PROCESO" in diccionario]
    listaProcesos.remove(proceso["NOMBRE_PROCESO"])
    sentencia["EXECUTE"]  = buscaroperacion_execute(codigo, sentencia, listaProcesos) 

    proceso["OPERACIONES"] = sentencia

    return proceso

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
        #print(f"---{hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO']}---")
        #print(f"{hm_paquete['LISTA_PROCESOS'][i]['OPERACIONES']}")
 
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
            parametros = re.findall(patron, definiciones[0], re.IGNORECASE | re.DOTALL)    
            util_log.log(nombreProceso, 4, None, codigo, parametros, "analizarCodigo.buscarParametrosDBLink")
            
            variables = [elemento.split('@') for elemento in parametros]
            util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarParametrosDBLink")             
            #return list(set(parametros))    
            return parametros

def buscarVariables(codigo, nombreProceso):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
            codigo = codigo.replace(definiciones[0],"")
            #util_log.log(nombreProceso, 2, None, codigo, None)
            #print(nombreProceso)
            #print(definiciones)
    
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
    variables = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)   
    util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarVariables")
    
    variables = [elemento.split('@') for elemento in variables]
    util_log.log(nombreProceso, 4, None, codigo, variables, "analizarCodigo.buscarVariables")
    return variables


