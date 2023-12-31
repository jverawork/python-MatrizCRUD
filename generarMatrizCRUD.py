#pip install regex
#pip install pyparsing
#pip install openpyxl 
#pip install psycopg2
 
 #pip install os
#import sistem

import gestionarExcel  
import analizarCodigo
import manejoArchivos
import buscarOperaciones
from tip_estructuras import hm_paquete

import afinarCodigo
import util_log

archivoSQL   = 'util_fuentesSQL.pkb'
archivoExcel = "util_matrizCRUD2.xlsx"

util_log.nombre_ProcesoAuditar = "PQ_OWNER.CRE_DEBITOAUTOMATICOPQ_PKG"
util_log.auditar =  False 
util_log.logNivel = 4
util_log.logPrintCode = False

def main():     
    global hm_paquete 
    codplsql = manejoArchivos.abrir_archivo(archivoSQL)
    codplsql = afinarCodigo.limpiar_comentarios(codplsql)
    #codplsql = buscarOperaciones.sustituirArroba(codplsql)
    codplsql_remanente = analizarCodigo.segmentarCodigo(codplsql.upper())
    
    analizarCodigo.analizarOperacionesEnProcesos()

    hm_paquete["NOMBRE_PROCESO"] = analizarCodigo.obtenerNombrePaquete(codplsql_remanente)[1] 
    hm_paquete["TIPO"]= "PACKAGE BODY" 
    hm_paquete["CODIGO"]= codplsql_remanente   
    
    analizarCodigo.analizarOperacionesEnCuerpo()    

    #hm_paquete["VARIABLES"]  = analizarCodigo.buscarVariables(hm_paquete["NOMBRE_PROCESO"], 1, codplsql_remanente)    
    #prepararDatos()
    gestionarExcel.armarExcel(hm_paquete, archivoExcel,"Body")
    
def prepararDatos():
    max_longitudProcesos = 0
    for proceso in hm_paquete["LISTA_PROCESOS"]:
        longitud_actual = len(proceso ["VARIABLES"])
        if longitud_actual > max_longitudProcesos:
            max_longitudProcesos = longitud_actual
    
    max_length = max(len(hm_paquete["VARIABLES"]),len(hm_paquete["PARAMETROS"]))
    hm_paquete["VARIABLES"]  += [None] * (max_length - len(hm_paquete["VARIABLES"]))
    #hm_paquete["PARAMETROS"] += [None] * (max_length - len(hm_paquete["PARAMETROS"]))

    for proceso in hm_paquete["LISTA_PROCESOS"]:  
        proceso["VARIABLES"]  += [None] * (max_length - len(proceso["VARIABLES"]))
        proceso["PARAMETROS"] += [None] * (max_length - len(proceso["PARAMETROS"]))

if __name__ == "__main__":
    main()
    #sistem.abrirExcel(archivoExcel)
