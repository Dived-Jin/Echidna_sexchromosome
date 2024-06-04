#mask genome and split into 5kb windows (with 2kb overlap)
bedtools maskfasta -fi X.fasta -bed X.repeat.sort.bed.merg -fo X.Nmasked.fasta
samtools faidx X.Nmasked.fasta
bedtools makewindows -g X.Nmasked.fasta.fai -w 5000 -s 2000 -i srcwinnum > X.Nmasked.fasta.fai.5k_2k.bed
bedtools getfasta -fi X.Nmasked.fasta -bed X.Nmasked.fasta.fai.5k_2k.bed > X.Nmasked.fasta.fai.5k_2k.bed.fasta

#blastn
makeblastdb -in X.Nmasked.fasta -dbtype nucl
blastn -query X.Nmasked.fasta.fai.5k_2k.bed.fasta -db X.Nmasked.fasta -outfmt 6 -perc_identity 50 -num_threads 5 > X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8
perl bin/blast_filter.pl -i X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8 -f X.Nmasked.fasta -f X.Nmasked.fasta.fai.5k_2k.bed.fasta > X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format
awk '$5>0.5' X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format > X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt
perl bin/remove_self_alignment.pl X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt > X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt.filt

#keep
cut -f1 X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt.filt | sed 's/:/\t/' | sed 's/-/\t/' | sort -k1,1V -k2,2n | bedtools merge -i - > X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt.filt.merg
awk '$3-$2>=10000' X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt.filt.merg > X.Nmasked.fasta.fai.5k_2k.bed.fasta.m8.format.filt.filt.merg.filt10k

