PALABRA ANTES DE COMA
(?:(?:\s*(\w+))(?:\s*,\s*))

PALABRA DESPUES DE COMA
(?:\s*,\s*)(\w+)

PRIMERA PALBRA DESPUES DEL FROM
FROM\b\s*(\w+)

ENCUENTRA LA CADENA DENTRO DE UN PARENTESIS
\((?:[^()]+|\([^()]*\))*\)

ENCUENTRA LAS SENTENCIAS SELECT ***FROM EN LA CADENA
((?:SELECT)(?:.|\s)+?(?:FROM)|JOIN)

recupera toda la sentencia select
((?:SELECT)(?:.|\s)+?(?:FROM|JOIN)(?:.|\s)+?(?:(?=;)|(?=(?:\s*\)\s*LOOP\s+))))

(?:.|\s)+?

CONDICIONAL
(?:(?=A)X|Y)  X TRUE  Y FALSE

LOOKHEAD
\w(?=\d)  letra seguida de un digito
\d+(?= kg)  cantidades seguidas de " kg"
\w+(?=ing)  palabras que terminan en ing
[a-z](?=\d) letra seguida de un numero
**(?=\d)\w+   mala practica  Busca un texto seguido de un digito pero no verifica el digito

NEGATIVE LOOKHEAD
(?!<lookahead_regex>)
\w+(?!ing)  palabras que no terminen en ing
abc(?!def)  toma la cadena abc que no termine en def 

Multiple Negative Lookaheads
X(?!Y)(?!Z)   No funciona como un and  sino como un or
\b\w+(?!\d)(?![A-Z]) palabras que no esten seguidsa de un digito o una letra

LOOKBEHIND
(?<=<pattern>)
 (?<=re)\w+  palabras que empiezan con re
 (?<=\$)\d+  valoress $100 $200
 (?<=\d)[a-z]  letra posterior a un digito  123x  x
 (?<=\.)\s espacio seguidos de un punto
 
 
 
 
 