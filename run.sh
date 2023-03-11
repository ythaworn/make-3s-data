#!/bin/bash
#
# phase multilocus data and subsample to 3 sequences per locus for 3s analysis
#
# Yuttapong Thawornwattana (2019)
#
# Inputs:
# - multilocus data of unphased diploid sequences
# - control file & Imap file specifying specie labels and species order
#
# Outputs:
# - phased sequences
# - multilocus data for 3s (3 phased sequences per locus)


# set directories
dbase=$(pwd)
dscript=$dbase/script
ctldir=$dbase
datadir=$dbase

# input file containint multilocus data
fin=loci-heradem-all-chr01.txt

# output dir for phased sequences and 3s datasets
dout1=$dbase/loci_phased
dout2=$dbase/loci_3s

# phased sequences
fout=$dout1/${fin%.*}.phased.txt

# approx max number of variable sites per locus for PHASE
num_seg_max=300

verbose=true
# verbose=false


### STEP 1: Running PHASE ###
mkdir -p $dout1
mkdir -p $dout2
cd $dout2

# count loci; xargs removes whitespace from wc
numloci=$(grep ^[0-9] $datadir/$fin | wc -l | xargs)

if $verbose; then
  echo "Step 1: phasing"
  echo "input: $datadir/$fin"
  echo "output: $fout"
  echo "$numloci loci"
fi

# generate fasta files, one for each locus
$dscript/bpp_to_fasta.py $datadir/$fin

# phasing using PHASE (and two perl programs seqphase1.pl & seqphase2.pl)
> $fout
for i in $(seq 1 $numloci); do
  if [ ! -f "locus$i.phased.fas.phy" ]; then
    $dscript/seqphase1.pl -1 locus$i.fas -p phase$i
    
    if [ -f "phase$i.inp" ]; then
      num_seg="$(sed '2q;d' phase$i.inp)"
      num_split=$(($num_seg / $num_seg_max + 1))

      if [ "$num_split" -gt 1 ]; then
        # if locus is too long, split sequence into smaller segments
        # PHASE had many issues when input sequences are 'too long'
        # echo "splitting into $num_split segments"
        $dscript/fasta_split.py locus$i.fas $num_split
        for j in $(seq 1 $num_split); do
          $dscript/seqphase1.pl -1 locus${i}_${j}.fas -p phase${i}_${j}
          if [ -f "phase${i}_${j}.inp" ]; then
            PHASE -q0 -p0 phase${i}_${j}.inp phase${i}_${j}.out
            $dscript/seqphase2.pl -c phase${i}_${j}.const -i phase${i}_${j}.out -o locus${i}_${j}.phased.fas 
          else
            $dscript/phase_const.py locus${i}_${j}.fas
          fi          
        done
        $dscript/fasta_merge.py locus${i}_*.phased.fas

      else
        PHASE -q0 -p0 phase$i.inp phase$i.out
        $dscript/seqphase2.pl -c phase$i.const -i phase$i.out -o locus$i.phased.fas
      fi
    else
      # all sites are constant; do phasing manually (all sequences are identical)
      $dscript/phase_const.py locus$i.fas
    fi

    $dscript/fasta_to_phylip.py locus$i.phased.fas
    rm phase* locus$i.fas
  fi
  cat locus$i.phased.fas.phy >> $fout
  echo "" >> $fout
done
rm locus*


### STEP 2: Run bpp.3sdata to sample 3 sequences per locus ###
# program bpp.3sdata (by Ziheng Yang) randomly samples three sequences
# at each locus so that the final dataset has data configurations
# 123, 113 and 223 with proportions 0.5, 0.25 and 0.25, respectively
# where 123 means one sequence from each of the three species, etc.

if $verbose; then echo "Step 2: Running bpp.3sdata"; fi

# specify species triplets for bpp.3sdata
# numbers refer to species&tree in the control file bpp.3sdata.ctl

# in the example data file loci-heradem-all-chr01.txt,
# there are 7 species: Dem Era Him Sar Sia Tel Mel
# the first six (1-6) are ingroup; the last one is an outgroup
# we generate 15 datasets, one for each pair of ingroup species
# the outgroup species (S3) is the same in all pairs
l1="1 1 1 1 1 2 2 2 2 3 3 3 4 4 5"
l2="2 3 4 5 6 3 4 5 6 4 5 6 5 6 6"

s1=($l1)
s2=($l2)
s3=7

# set the control file for bpp.3sdata
basectl=$ctldir/bpp.3sdata.ctl
ctl=$dout2/bpp.3sdata.ctl
imap=$ctldir/Imap.txt

sed -e 's|nloci = 1|nloci = '"$numloci"'|' \
    -e 's|seqfile = loci.txt|seqfile = '"$fout"'|' \
    -e 's|Imapfile = Imap.txt|Imapfile = '"$imap"'|' $basectl > $ctl

# run bpp.3sdata; loop over ingroup pairs
for ((i=0; i<${#s1[@]}; i++)); do
  if $verbose; then echo "$ctl ${s1[i]} ${s2[i]} $s3"; fi
  $dscript/bpp.3sdata/bpp.3sdata $ctl ${s1[i]} ${s2[i]} $s3 > log.txt
done

mv $dout1/${fin%.*}.phased.*.txt $dout2

# clean up
rm out.txt log.txt SeedUsed

# OPTIONAL: remove first two blank lines and add a blank line at the end
for f in $dout2/*.phased.*.txt; do
  sed -i.tmp '/./,$!d' $f
  rm $f.tmp

  echo '' >> $f
done
