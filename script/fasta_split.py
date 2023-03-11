#! /usr/bin/python

'''
01/02/20
Split input fasta file into n files

usage: fasta_split.py <filename>.fas n

output: <filename>_1.fas, .., <filename>_n.fas
'''

import sys

fin_name = sys.argv[1]
fin = open(fin_name, 'r')
n = int(sys.argv[2])

content = fin.readlines()
fin.close()

total_len = max([len(content[i+1]) for i in range(len(content)) if '>' in content[i]])
sq_len = total_len // n

for k in range(n):
  fout_name = fin_name.replace('.fas', '_' + str(k+1) + '.fas')
  fout = open(fout_name, 'w')

  for i in range(len(content)):
    if '>' in content[i]:
      sq_name = content[i].strip()
      sq = content[i+1]

      # split sq into two halves
      if k == (n - 1):
        # last segment
        sq_k = sq[(k*sq_len):].strip() + '\n'
      else:
        sq_k = sq[(k*sq_len):(k+1)*sq_len].strip() + '\n'

      fout.write(sq_name + '\n')
      fout.write(sq_k + '\n')

  fout.close()

