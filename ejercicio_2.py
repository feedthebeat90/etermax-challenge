#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jun 19 17:34:24 2020

@author: laureanonisenbaum
"""

import codecs

# Defino archivo de entrada
inFile = codecs.open('./data/Datos.tsv', 'rb', encoding = 'utf-16-le')
# Defino archivo de salida
outFile = codecs.open('./data/DatosLimpios.csv', 'wb', encoding='utf8')

# Asumo que el numero de columnas es fijo y definido por el "header" (primera fila)
header = inFile.readline()
num_col = len(header.split("\t"))
# Write header to outFile
outFile.write('|'.join(header.split('\t')))

# Auxiliar variable for corrupted lines
dirty_line = []
result = []

# Iterate over inFile 
for line in inFile.readlines():
    # Write to outFile those lines with right amount of fields ('num_col')
    if len(line.split('\t')) == num_col:
        result.append(line.strip('\n').split('\t'))
        outFile.write('|'.join(line.split('\t'))) 
        
    # For lines with less fields than 'num_col' use 'dirty_line' auxiliar list until all fields are read
    if len(line.split('\t')) < num_col and dirty_line == []:
        dirty_line.extend(line.strip('\n').split('\t'))
        
    # If we have not yet read all fields we keep extending 'dirty_line'
    elif len(line.split('\t')) < num_col and dirty_line != []:
       # Asumo que el primer field en fila contigua pertenece al ultimo elemento de 'dirty_line'
       dirty_line[-1] = dirty_line[-1] + ' ' + line.strip('\n').split('\t')[0]
       dirty_line.extend(line.strip('\n').split('\t')[1:])
       
       # When 'dirty_line' variable has exactly 'num_col' fields 
       if len(dirty_line) == num_col:
           result.append(dirty_line)
           dirty_line[-1] = dirty_line[-1] + '\n'
           outFile.write('|'.join(dirty_line))
           dirty_line = []

# Close input/output files
inFile.close()
outFile.close() 
          
# Chequeo numero de fields for fila y primera columna integer
print("El numero de fields (columnas) en 'Datos.tsv' es % 1d" %(num_col))  
# Assert result
for elem in result:
    assert len(elem) == num_col
    assert type(int(elem[0])) == int




