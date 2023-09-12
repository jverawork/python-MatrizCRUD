import ply.lex as lex

# Definir las reglas de los tokens
tokens = (
    'IDENTIFIER',
    'AT',
    'COMMA',
    'SEMICOLON',
)

# Expresiones regulares para los tokens
t_IDENTIFIER = r'[a-zA-Z_][a-zA-Z0-9_@]*'
t_AT = r'@'
t_COMMA = r','
t_SEMICOLON = r';'

# Ignorar espacios en blanco y tabulaciones
t_ignore = ' \t'

# Manejar errores de tokens no válidos
def t_error(t):
    print(f"Token no válido: {t.value[0]}")
    t.lexer.skip(1)

# Crear un analizador léxico
lexer = lex.lex()

# Ejemplo de cadena SQL
sql_text = "SELECT column1, table1@dblink.com FROM table2;"

# Analizar la cadena SQL
lexer.input(sql_text)
while True:
    token = lexer.token()
    if not token:
        break
    print(f"Token: {token.type}, Valor: {token.value}")
