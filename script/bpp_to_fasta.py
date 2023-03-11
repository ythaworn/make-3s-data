#! /usr/bin/python
'''
Converts multi-locus sequence files created by MCcoal to fasta format
usage: ./bpp_to_fasta.py file.phy
'''

import sys
import re

f = open(sys.argv[1],'r')
content = f.readlines()
f.close()

loci = []
species = []
data = []

for i in range(len(content)):
  m = re.match(r"(\d+)",content[i])
  m2 = re.match(r".*[\^]",content[i])
  if m is not None:
    loci.append(m.group(1))
  if m2 is not None:
    # split = content[i].split("      ")
    split = content[i].split("  ")
    # split = content[i].split(" ")  # 160721
    species.append(split[0])
    data.append(split[1])

for j in range(len(loci)):
  f2 = open("locus"+str(j+1)+".fas",'w')
  for k in range(int(loci[j])):
    f2.write(">"+species.pop(0)+"\n"+data.pop(0)+"\n")
  f2.close()

print "%d files written, %d lines total" % (len(loci), len(species)*2)
