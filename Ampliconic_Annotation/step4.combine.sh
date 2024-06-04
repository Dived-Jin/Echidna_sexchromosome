ln -s X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt.filt.merg.filt10k blastn.bed
ln -s X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov.filt.merg.filt10k depth.bed
ln -s X.fasta.self-alignments.lz.bed.cut.repeat_cov.filt palindrome.bed

cat palindrome.bed blastn.bed depth.bed | cut -f1-3 | sort -k1,1V -k2,2n | bedtools merge -i - > final.bed
bedtools subtract -a final.bed -b PAR.bed -A > final.bed.removePAR
# echidna.gff.bed is the gene bed files
bedtools coverage -a echidna.gff.bed -b final.bed.removePAR | sort -k1,1V -k2,2n > echidna.gff.bed.cov
perl bin/AddColumn.v2.pl echidna.gff.bed.cov echidna.pep.ann 4 > echidna.gff.bed.cov.add
awk '$10>=0.8' echidna.gff.bed.cov.add | sort -k1,1V -k2,2n | cut -f1-6 > echidna.gff.bed.cov.add.filt

