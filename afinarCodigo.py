import re
def limpiar_comentarios(textosql):
    textosql2 = re.sub(r"\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\/", "", textosql)
    textosql3 = re.sub(r"--(.*?)$", "", textosql2, flags=re.MULTILINE)
    textosql4 = re.sub(r'\n\s*\n', '\n', textosql3)
    return textosql4

def sustituirArroba(codigo_plsql):
    codigo_plsql = codigo_plsql.replace("@","<ARROBA>")
    return codigo_plsql