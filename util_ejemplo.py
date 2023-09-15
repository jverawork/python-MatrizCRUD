import buscarOperaciones
import afinarCodigo
import re

# Lectura del archivo de entrada
codigo_plsql = ''' 
SELECT D.DP_VALNUMDETCATALOGO, D.DP_VALCARDETCATALOGO, D.DP_VALFECDETCATALOGO
            INTO AO_VALNUMDETCATALOGO, AO_VALCARDETCATALOGO, AO_VALFECDETCATALOGO
            FROM PQ_OWNER.CRE_CATALOGOPQ_TBL C
            INNER JOIN PQ_OWNER.CRE_DETCATALOGOPQ_TBL D
            ON (C.CP_ID_CATALOGO = D.CP_ID_CATALOGO)
            WHERE     
            C.CP_CODCATALOGO = AI_CODCATALOGO
            AND D.DP_CODDETCATALOGO = AI_CODDETCATALOGO
            AND C.CP_ESTADOCATALOGO = K_VALCA
            AND D.DP_ESTADODETCATALOGO = K_VALDA
            AND D.DP_TIPVALDETCATALOGO = K_VALDV;  '''
#with open('util_codigoejemplo.sql', 'r') as file:
#    codigo_plsql = file.read()

a,_,b = "textito".partition(".")
print(a,b)
codigo_plsql = afinarCodigo.limpiar_comentarios(codigo_plsql)
codigo_plsql = codigo_plsql.replace("@","<arroba>")
codigo_plsql = re.sub(r'( {2,}|\t{2,}|\n{2,})',' ',codigo_plsql)
codigo_plsql = re.sub(r'(\s{2,})',' ',codigo_plsql)
print(codigo_plsql)
buscarOperaciones.buscaroperacion(codigo_plsql)
#print(afinarCodigo.limpiar_comentarios(codigo_plsql))

