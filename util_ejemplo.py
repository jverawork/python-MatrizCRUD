import buscarOperaciones
import afinarCodigo

# Lectura del archivo de entrada
codigo_plsql = ''
with open('util_codigoejemplo.sql', 'r') as file:
    codigo_plsql = file.read()

buscarOperaciones.buscaroperacion(codigo_plsql)
#print(afinarCodigo.limpiar_comentarios(codigo_plsql))
