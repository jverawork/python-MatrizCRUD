#pip install regex
#pip install pyparsing
#pip install openpyxl 
#pip install psycopg2
 
 #pip install os
#import sistem

#import manejoExcel  
import analizarCodigo
import manejoArchivos
#from estructuras import hm_operaciones, hm_procesos, hm_paquete

import afinarCodigo

archivoSQL   = 'util_fuentesSQL.pkb'
archivoExcel = "util_matrizCRUD.xlsx"

def main():     
    global hm_paquete
    codigo_plsql = manejoArchivos.abrir_archivo(archivoSQL)
    codigo_plsql = afinarCodigo.limpiar_comentarios(codigo_plsql)
    codigo_plsql = analizarCodigo.segmentarCodigo(codigo_plsql) #codigo remanente
    
    analizarCodigo.analizarOperacionesEnProcesos()

    #hm_paquete["NOMBRE_PAQUETE"]= analizarCodigo.obtenerNombrePaquete(codigo_plsql)[1] 
    #hm_paquete["TIPO"]= "PACKAGE BODY" 
    #hm_paquete["CODIGO"]= codigo_plsql    
    #analizarCodigo.encontrarOperaciones(codigo_plsql, hm_paquete)    
    
    #manejoExcel.armarExcel(hm_paquete, archivoExcel)
    
    
if __name__ == "__main__":
    main()
    #sistem.abrirExcel(archivoExcel)
