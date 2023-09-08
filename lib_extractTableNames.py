import itertools
import sqlparse

from sqlparse.sql import IdentifierList, Identifier
from sqlparse.tokens import Keyword, DML


def is_subselect(parsed):
    if not parsed.is_group:
        return False
    for item in parsed.tokens:
        if item.ttype is DML and item.value.upper() == 'SELECT':
            return True
    return False


def extract_from_part(parsed):
    from_seen = False
    for item in parsed.tokens:
        if item.is_group:
            for x in extract_from_part(item):
                yield x
        if from_seen:
            if is_subselect(item):
                for x in extract_from_part(item):
                    yield x
            elif item.ttype is Keyword and item.value.upper() in ['ORDER BY', 'GROUP', 'BY', 'HAVING', 'GROUP BY', 'UNION ALL']:
                from_seen = False
                StopIteration
            else:
                yield item
        if item.ttype is Keyword and item.value.upper() == 'FROM':
            from_seen = True
        

def extract_table_identifiers(token_stream):
    for item in token_stream:
        if isinstance(item, IdentifierList):            
            print(item.get_identifiers())
            for identifier in item.get_identifiers():
                value = identifier.value.replace('"', '')#.lower()                
                print("value identifier="+value)
                #print(identifier)
                print(">get_real_name="+item.get_real_name()) 
                yield value
                
        elif isinstance(item, Identifier):
            value = item.value.replace('"', '')#.lower()           
            #value = value.split(' ')[0]
            print('value instance='+value)
            #print("-getname="+item.get_name())     
            print("-get_real_name="+item.get_real_name())           
            yield value
        elif item.ttype is Keyword:
            print('value else='+item.value)
            #print("<getname="+item.get_name())
            print("-get_real_name="+item.get_real_name())   
            yield item.value

def extract_tables(sql):
    # let's handle multiple statements in one sql string
    extracted_tables = []
    statements = list(sqlparse.parse(sql))
    #print([str(t) for t in statements[0].tokens if t.ttype is None][2])
    for statement in statements:
        if statement.get_type() != 'UNKNOWN':
            stream = extract_from_part(statement)
            #extracted_tables.append(set(list(extract_table_identifiers(stream))))
            extracted_tables.append(list(extract_table_identifiers(stream)))#es para que se repita las tablas en select con union all
            #print(statement.get_type())
            #print(stream)
    return list(itertools.chain(*extracted_tables))