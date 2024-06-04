# in this example X.fasta is used as the example. may contain multiple sequence

# mask PAR
bedtools maskfasta -fi X.fasta -bed PAR.bed -fo X.PARmasked.fasta

# split fasta into multiple file for lastz alignment
perl Split_fasta.pl -seq X.PARmasked.fasta -ns 1 -od split
ls split/*.fasta | while read i
do
	echo "lastz $i --self --format=general:name1,zstart1,end1,name2,strand2,zstart2+,end2+,id%,cigarx > $i.self-alignments.lz"
done > lastz.shell
sh lastz.shell

# run palindrover to identify palindrome
## palindrover.py is obtained from https://github.com/makovalab-psu/T2T_primate_XY/tree/main/palindrover_maf_align
ls split/*.lz | while read i; do python3 palindrover.py --minlength=8000 < $i > $i.bed; done

# combine results
cat split/*.bed | awk '!/^#/' > X.fasta.self-alignments.lz.bed
awk '!/^#/' X.fasta.self-alignments.lz.bed | cut -f1-3 > X.fasta.self-alignments.lz.bed.cut
awk '!/^#/' X.fasta.self-alignments.lz.bed | cut -f4,6,7 >> X.fasta.self-alignments.lz.bed.cut

#filter palindrome to keep arm with < 80% repeat
bedtools coverage -a X.fasta.self-alignments.lz.bed.cut -b X.repeat.sort.bed.merg > X.fasta.self-alignments.lz.bed.cut.repeat_cov
awk '$7<0.8' X.fasta.self-alignments.lz.bed.cut.repeat_cov > X.fasta.self-alignments.lz.bed.cut.repeat_cov.filt

