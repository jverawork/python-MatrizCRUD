import sqlparse

sql = '''SELECT column1 FROM table1, table2 t2, table3@dblink.com, tabla4, tabla5 t5 WHERE NOT EXISTS (SELECT  X1 FROM AUD_EPLICA X2 WHERE X.ID_TRAMITE = T.ID_TRAMITE);'''

parsed_statements = sqlparse.parse(sql)

# Recorre todas las sentencias y obtiene los tokens de cada una
for token in parsed_statements[0].tokens:
    if token.ttype == sqlparse.sql.Token.AT_SIGN:
        print(token.value)    
    #print(f"{token.ttype} <<<< {token.value}")


