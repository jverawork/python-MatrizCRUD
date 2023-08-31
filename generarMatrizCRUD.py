#pip install regex
#pip install pyparsing
#pip install openpyxl 
#pip install psycopg2
 
 #pip install os
#import sistem

#import manejoExcel  
import analizarCodigo
import manejoArchivos
from tip_estructuras import hm_operaciones, hm_procesos, hm_paquete

import afinarCodigo

archivoSQL   = 'util_fuentesSQL.pkb'
archivoExcel = "util_matrizCRUD.xlsx"

def main():     
    global hm_paquete
    codplsql = manejoArchivos.abrir_archivo(archivoSQL)
    codplsql = afinarCodigo.limpiar_comentarios(codplsql)
    codplsql_remanente = analizarCodigo.segmentarCodigo(codplsql.upper())
    
    analizarCodigo.analizarOperacionesEnProcesos()

    hm_paquete["NOMBRE_PAQUETE"] = analizarCodigo.obtenerNombrePaquete(codplsql_remanente)[1] 
    hm_paquete["TIPO"]= "PACKAGE BODY" 
    hm_paquete["CODIGO"]= codplsql_remanente    
    analizarCodigo.encontrarOperaciones(codplsql_remanente, hm_paquete)    

    hm_paquete["VARIABLES"]  = analizarCodigo.buscarVariables(codplsql_remanente)    
    #manejoExcel.armarExcel(hm_paquete, archivoExcel)
    
    
if __name__ == "__main__":
    main()
    #sistem.abrirExcel(archivoExcel)
