#! /usr/bin/python
'''
Create a phased sequences when all sites are constant
usage: ./phase_const.py file.fas
'''

import sys

fin = open(sys.argv[1], 'r')
fout_name = sys.argv[1].replace('.fas', '.phased.fas')
fout = open(fout_name, 'w')

content = fin.readlines()
fin.close()

for i in range(len(content)):
  if '>' in content[i]:
    sq_name = content[i].strip()
    sq = content[i+1]
    fout.write(sq_name + 'a\n')
    fout.write(sq)
    fout.write(sq_name + 'b\n')
    fout.write(sq)

fout.close()

