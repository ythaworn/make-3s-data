# make-3s-data
Phase multilocus data and sample three sequences per locus for 3s analysis ([Zhu & Yang, 2012](https://doi.org/10.1093/molbev/mss118); [Dalquen et al, 2017](https://doi.org/10.1093/sysbio/syw063))

Script that performs the following steps:
(1) Phase multilocus data of unphased diploid sequences using `PHASE` [(Stephens et al., 2001)](https://doi.org/10.1086/319501).
(2) Sample three phased sequences per locus (50% 123, 25% 113, 25% 223) using `bpp.3sdata`.

`bpp.3sdata` is program adapted from an original version written by [Ziheng Yang](http://abacus.gene.ucl.ac.uk/) for [Shi & Yang (2018)](https://doi.org/10.1093/molbev/msx277).

This procedure was used in [Thawornwattana et al. (2022)](https://doi.org/10.1093/sysbio/syac009).
