# Repeat annotation with TRF & RepeatMasker

# TRF
trf409.legacylinux64 X.fasta  2 7 7 80 10 50 2000 -d -h -ngs > X.dat
python bin/dat2gff.py X.dat X.dat.gff
awk '!/^#/' X.dat.gff | awk '{print $1"\t"$4-1"\t"$5}' > X.dat.gff.bed

# Repeatmasker
## GCF_015852505.1_mTacAcu1.pri_rm.out.gz is obtain https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/015/852/505/GCF_015852505.1_mTacAcu1.pri
perl bin/repeat_to_gff.pl GCF_015852505.1_mTacAcu1.pri_rm.out > echidna.homolog.out.gff
samtools faidx X.fasta
perl bin/pick.column_info.pl echidna.homolog.out.gff X.fasta.fai 1 1 -t same > echidna.homolog.out.gff.filt
awk '!/^#/' echidna.homolog.out.gff.filt | awk '{print $1"\t"$4-1"\t"$5}' > echidna.homolog.out.gff.filt.bed

# RepeatModeler & Repeatmasker
BuildDatabase -engine ncbi -name mydb mTacAcu1.pri.v1.fasta > BuildDatabase.log
RepeatModeler -engine ncbi -database mydb -pa 60 > run.out
RepeatMasker -pa 80 -gff -lib mydb-families.fa X.fasta > X.fasta.log 2> X.fasta.log2
ln -s X.fasta.out.gff echidna.denovo.out.gff.filt
awk '!/^#/' echidna.denovo.out.gff.filt | awk '{print $1"\t"$4-1"\t"$5}' > echidna.denovo.out.gff.filt.bed

# combine repeat annotation results
cat X.dat.gff.bed echidna.denovo.out.gff.filt.bed echidna.homolog.out.gff.filt.bed | sort -k1,1V -k2,2n > X.repeat.sort.bed
/share/app/bedtools/2.29.2/bin/bedtools merge -i X.repeat.sort.bed > X.repeat.sort.bed.merg

