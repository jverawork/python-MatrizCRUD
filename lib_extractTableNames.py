import itertools
import sqlparse

from sqlparse.sql import IdentifierList, Identifier
from sqlparse.tokens import Keyword, DML
from sqlparse import tokens as T 

ALL_JOIN_TYPE = ('LEFT JOIN', 'RIGHT JOIN', 'INNER JOIN', 'FULL JOIN', 'LEFT OUTER JOIN', 'FULL OUTER JOIN','WITH', 'ON', 'AND')

def is_subselect(parsed):
    if not parsed.is_group:
        return False
    for item in parsed.tokens:
        if item.ttype is DML and item.value.upper() == 'SELECT':
            return True
    return False

def extract_from_part(parsed, nivel = None):
    from_seen = False
    for item in parsed.tokens:        
        #print(nivel, [' ' for t in range(nivel)],"->",item, " * ", item.ttype)
        if item.is_group:
            #print(f"item.is_group {item}")
            for x in extract_from_part(item, nivel + 1):
                yield x
        if from_seen:
            #print(f"nivel {nivel} {item}")
            #if item.value.find("@")>0:
                #print(f"item.ttype = {item.ttype}")
            if is_subselect(item):
                #print("hay subselects")
                for x in extract_from_part(item, nivel + 1):
                    yield x
            elif item.ttype is Keyword and item.value in ['ORDER BY', 'GROUP', 'BY', 'HAVING', 'GROUP BY', 'UNION ALL', "INTERSECT", "EXCEPT"]:
                from_seen = False
                StopIteration
            else:
                yield item
        if item.ttype is Keyword and item.value == 'FROM':
            from_seen = True


      

def extract_table_identifiers(token_stream):
    for item in token_stream:
        #print(f"item : {item}")
        if isinstance(item, IdentifierList):            
            #print(item.get_identifiers())
            #print(">get_real_name>"+item.get_real_name()) 
            for identifier in item.get_identifiers():
                value = identifier.value.replace('"', '')#.lower()                
                #print( ">>value identifier>"+value)
                #print(f">>alias >{identifier.get_alias()}")
                #print(f">>parent>{identifier.get_parent_name()}")
                #print(f">>real  >{identifier.get_real_name()}")
                #print(identifier)                
                yield value
                
        elif isinstance(item, Identifier):
            value = item.value.replace('"', '')#.lower()           
            #value = value.split(' ')[0]
            #print('-value instance-'+value)
            ##print("-getname="+item.get_name())     
            #print(f"--alias -{item.get_alias()}")
            #print(f"--parent-{item.get_parent_name()}")
            #print(f"--real  -{item.get_real_name()}")        
            yield value
        elif item.ttype is Keyword:
            #print('+value else='+item.value)
            ##print("<getname="+item.get_name())  
            #print(f"++alias +{item.get_alias()}")
            #print(f"++parent+{item.get_parent_name()}")
            #print(f"++real  +{item.get_real_name()}")          
            yield item.value

def extract_join_part(parsed):
    flag = False
    for item in parsed.tokens:
        if flag:
            if item.ttype is Keyword:
                flag = False
                continue
            else:
                yield item
        if item.ttype is Keyword and item.value in ALL_JOIN_TYPE:
            yield item.value

def extract_tables(sql):
    #print("inicio")
    extracted_tables = []
    statements = list(sqlparse.parse(sql))
    #statements[0]._pprint_tree()
    #print("================================")
    for statement in statements:
        if statement.get_type() != 'UNKNOWN':
            stream = extract_from_part(statement, 1)
            #extracted_tables.append(set(list(extract_table_identifiers(stream))))
            extracted_tables.append(list(extract_table_identifiers(stream)))#es para que se repita las tablas en select con union all

    #print(extracted_tables)    
    #join_stream = extract_join_part(statements[0])    
    #print(list(join_stream))
    tablas = []
    tokens = sql.split()
    #for tabla in set([elemento.split()[0] for elemento in list(itertools.chain(join_stream,*extracted_tables))]):
    #print(extracted_tables)
    listaTablas = [elemento for elemento in list(extracted_tables[0]) if elemento not in ALL_JOIN_TYPE]
    #print(listaTablas)
    for tabla in set([elemento.split()[0] for elemento in listaTablas ]):
    #for tabla in set([elemento.split()[0] for elemento in list(itertools.chain(*extracted_tables))]):
        ocurrencias = [p for p in tokens if p == tabla]
        tablas.extend(ocurrencias)
    #print(tablas)                
    return tablas
    #return list(itertools.chain(join_stream,*extracted_tables))
    #return [elemento.split()[0] for elemento in list(itertools.chain(join_stream,*extracted_tables))]
    #return list(itertools.chain(*extracted_tables))+list(join_stream)

from sqlparse import keywords
from sqlparse.lexer import Lexer

lex = Lexer.get_default_instance()
lex.clear()

my_regex = (r'[+/#%^&|^-]+', sqlparse.tokens.Operator)
lex.set_SQL_REGEX(
keywords.SQL_REGEX[:47]
+ [my_regex]
)

my_regex = (r'\w*(@|##|#)[A-ZÀ-Ü]\w+', sqlparse.tokens.Name)
lex.set_SQL_REGEX(
keywords.SQL_REGEX[:18]
+ [my_regex]
+ keywords.SQL_REGEX[19:]
)

lex.add_keywords(keywords.KEYWORDS_COMMON)
lex.add_keywords(keywords.KEYWORDS_ORACLE)
lex.add_keywords(keywords.KEYWORDS)
