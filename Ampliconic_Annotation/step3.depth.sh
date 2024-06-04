# run bwa
bwa index mTacAcu1.pri.v1.fasta
bwa mem -t 5 mTacAcu1.pri.v1.fasta read1.fq.gz read2.fq.gz | samtools view -@ 5 -b - | samtools sort -@ 5 - > bwa.sort.bam
samtools index bwa.sort.bam

# pick X alignment
cut -f1 X.fasta.fai | while read line
do
	samtools view -b bwa.sort.bam $line > ${line}_temp.bam
done
samtools merge Xchromo_merg.bam *.bam

# remove duplicates
java -jar picard.jar MarkDuplicates REMOVE_DUPLICATES=true I=Xchromo_merg.bam O=Xchromo_merg.bam M=merg.matir VALIDATION_STRINGENCY=LENIENT

# correct for GC bias
correctGCBias -b Xchromo_merg.bam --effectiveGenomeSize 286890605 -g quaryfileX.2bit --GCbiasFrequenciesFile freq.txt -o gc_corrected.bam --numberOfProcessors 10

# obtain depth
samtools depth gc_corrected.bam | awk '{print $1"\t"$2-1"\t"$2"\t"$3}' > Xchromo_gc_corrected_Rmdup.depth
sort -k1,1V -k2,2n Xchromo_gc_corrected_Rmdup.depth > Xchromo_gc_corrected_Rmdup_sort.depth

# results
awk -F " " '{print $1}' X.Nmasked.fasta.fai.5k_2k.bed |sort -u | while read line
do
	grep -w $line X.Nmasked.fasta.fai.5k_2k.bed >t1
	grep -w $line Xchromo_gc_corrected_Rmdup_sort.depth >t2
	bedtools map -a t1 -b t2 -c 4 -o median,mean,count
done > X.Nmasked.fasta.fai.5k_2k.bed.depth
cut -f1-3,5-7 X.Nmasked.fasta.fai.5k_2k.bed.depth > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut
python3 bin/Depthformat.py X.Nmasked.fasta.fai.5k_2k.bed.depth.cut 8.50 > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add # 8.50 is obtained as the average depth of autosomes
awk '$7>=2' X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt
bedtools coverage -a X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt -b X.repeat.sort.bed.merg > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov
awk '$11<0.8' X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov.filt
bedtools merge -i X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov.filt > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov.filt.merg
awk '$3-$2>=10000' X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov.filt.merg > X.Nmasked.fasta.fai.5k_2k.bed.depth.cut.add.filt.repeat_cov.filt.merg.filt10k

