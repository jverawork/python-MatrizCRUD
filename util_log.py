auditar = False
nombre_ProcesoAuditar = ""
logNivel = 0
logPrintCode = False

def log(nombreProceso, nivel, operacion, codigo=None, lista=None, funcion=None):
    if auditar and nombreProceso == nombre_ProcesoAuditar and nivel == logNivel:
        print("**********************************"+("" if funcion is None else funcion))
        if operacion is not None :      
            print(operacion["NOMBRE_PROCESO"])
            print("===OPERACIONES=====\n")
            print(operacion["OPERACIONES"])
            print("===PARAMETROS=====\n")
            print(operacion["PARAMETROS"])
            print("===Variables=====\n")
            print(operacion["VARIABLES"])
            print(operacion["VARIABLES-DBLINK"])            
        elif nombreProceso is not None : 
            print("===Proceso====="+nombreProceso+"\n")
        elif codigo is not None and logPrintCode: 
            print("===codigo=====\n")
            print(codigo)
        if lista is not None : 
            print("===lista=====")
            print(lista) 
        print("**********************************"+("" if funcion is None else funcion))

def logError(nombreProceso, operacion, codigo=None, lista=None, funcion=None, error=None):
    print("============================")
    print("======== E R R O R =========" + ("" if funcion is None else funcion))
    print("============================")
    if operacion is not None:      
        print(operacion["NOMBRE_PROCESO"])
        print("===OPERACIONES=====\n")
        print(operacion["OPERACIONES"])
        print("===PARAMETROS=====\n")
        print(operacion["PARAMETROS"])
        print(operacion["PARAMETROS-DBLINK"])
        print("===Variables=====\n")
        print(operacion["VARIABLES"])
        print(operacion["VARIABLES-DBLINK"])
    elif nombreProceso is not None:
        print(f"Proceso: {nombreProceso}")
    elif codigo is not None and logPrintCode: 
        print("===codigo=====\n")
        print(codigo)
    if lista is not None : 
        print("===lista=====\n")
        print(lista)  
    print(error)
    print("============================\n\n")