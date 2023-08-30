import buscarOperaciones

# Lectura del archivo de entrada
codigo_plsql = ''
with open('codigoejemplo.sql', 'r') as file:
    codigo_plsql = file.read()

buscarOperaciones.buscaroperacion(codigo_plsql)
