import re
import buscarOperaciones
from tip_estructuras import hm_operaciones, hm_procesos, hm_paquete
    
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
    sentencia["SELECT"] = buscaroperacion_select(codigo)
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
        operacion["PARAMETROS"] = buscarParametros(operacion["CODIGO"])
        operacion["VARIABLES"] = buscarVariables(operacion["CODIGO"])
        hm_paquete["LISTA_PROCESOS"][i] = operacion
        #if operacion["NOMBRE_PROCESO"]=="CRE_EXCLUSIONESDEB_P":
        #    print(operacion["NOMBRE_PROCESO"])
        #    print(operacion["OPERACIONES"])
        #    print(operacion["PARAMETROS"])
        #    print(operacion["VARIABLES"])
        #print(f"---{hm_paquete['LISTA_PROCESOS'][i]['NOMBRE_PROCESO']}---")
        #print(f"{hm_paquete['LISTA_PROCESOS'][i]['OPERACIONES']}")
 
def buscarParametros(codigo):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:    
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    

            patron = r'(\w+\.?\w+\.?\w+)(?=%TYPE,)'
            parametros = re.findall(patron, definiciones[0], re.IGNORECASE | re.DOTALL)    
            #return list(set(parametros))    
            return parametros

def buscarVariables(codigo):
    tipProceso = ["PROCEDURE", "FUNCTION"]
    for proceso in tipProceso:
        if proceso in codigo:
            patron = r'{}\s+\w+([^)]+)'.format(re.escape(proceso))
            definiciones = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
            codigo.replace(definiciones[0],"")
    
    patron = r'(\w+\.\w+\.?\w+)(?=(?:%ROWTYPE;|%TYPE;))'
    variables = re.findall(patron, codigo, re.IGNORECASE | re.DOTALL)    
    #return list(set(variables))
    return variables