import re
def limpiar_comentarios(textosql):
    textosql2 = re.sub(r"\/\*[^*]*\*+(?:[^*\/][^*]*\*+)*\/", "", textosql)
    textosql3 = re.sub(r"--(.*?)$", "", textosql2, flags=re.MULTILINE)
    return textosql3