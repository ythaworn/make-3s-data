#! /usr/bin/python

'''
01/02/20
Concatenate two input fasta files into one file

usage: fasta_merge.py <filename>_1.phased.fas .. <filename>_n.phased.fas

output: <filename>.phased.fas
'''

import sys

fin_names = sys.argv[1:]
n = len(fin_names)

# read content of all input files
contents = [0] * n
for k in range(n):
  fin = open(fin_names[k], 'r')
  contents[k] = fin.readlines()
  fin.close()

fout_name = sys.argv[1].replace('_1', '')
fout = open(fout_name, 'w')

for i in range(len(contents[0])):
  if '>' in contents[0][i]:
    sq_name = contents[0][i].strip()
    sq = ''.join([contents[k][i+1].strip() for k in range(n)])
    fout.write(sq_name + '\n')
    fout.write(sq + '\n')

fout.close()

