import buscarOperaciones
import afinarCodigo

# Lectura del archivo de entrada
codigo_plsql = ''
with open('util_codigoejemplo.sql', 'r') as file:
    codigo_plsql = file.read()

codigo_plsql = afinarCodigo.limpiar_comentarios(codigo_plsql)
codigo_plsql = codigo_plsql.replace("@","<arroba>")
print(buscarOperaciones.buscaroperacion(codigo_plsql))
#print(afinarCodigo.limpiar_comentarios(codigo_plsql))

hojaBody = "hoja"
ref_columnaini = "A"
ref_filaini = 1
ref_columnafin = "B"
fila = 30
print(f"{hojaBody}!${ref_columnaini}${ref_filaini}:${ref_columnafin}${fila-1}")