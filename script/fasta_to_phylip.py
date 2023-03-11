#! /usr/bin/env python
'''
to run:
./fasta_to phylip fasta_file
'''
import sys
f = open(sys.argv[1], 'r') 
f2 = open(str(sys.argv[1])+'.phy', 'w')
content = f.readlines()
new = []
phylip =[]
for i in range(len(content)):
	new.append(content[i].strip())
count = 0
temp_seq=''
seq_names = []
for i in range(len(new)):
	if '>' in new[i][0]:
		seq_names.append(new[i][1:])
		if count>0:
			phylip.append(temp_seq)
			temp_seq=''
	else:
		temp_seq=temp_seq + new[i]
		count = count +1
phylip.append(temp_seq)
name_size = []
for i in range(len(seq_names)):
	name_size.append(len(seq_names[i]))
f2.write(str(len(seq_names)) + ' ' + str(len(phylip[0])) + '\n')
for i in range(len(seq_names)):
	f2.write(str(seq_names[i]) + (max(name_size) - len(seq_names[i]) +1)*'  ' + str(phylip[i])+ '\n')
f2.close()
f.close()

