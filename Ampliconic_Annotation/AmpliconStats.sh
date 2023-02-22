#/bin/bash
###
#this pipline is used for finding ampliconic region and genes
###
#########################

Allaglis=$1 #Gene list
PlatypusAssign=$2 # chr start end chromosomeid
EchidnaAssign=$3 # chr start end chromosomeid
Mclfile=$4  #mcl cluster file
platypus_vs_chickenaln=$5 #
echidna_vs_chickenaln=$6 #
PlatySexGen=$7 #
EchidnaSexGen=$8 #
Chickannbed=$9 #
############################################################
nowdir=`pwd`
Shelldir=$(dirname $0) # script path 
Binpath="${Shelldir}/../bin/" # local script path
############################################################
cut -f1 $EchidnaAssign |while read line
do
        grep -w "^$line" $echidna_vs_chickenaln |cut -f5,7,8
done >Monalingtochicken.alingn.bed

cut -f1 $PlatypusAssign |while read line
do
        grep -w "^$line" $platypus_vs_chickenaln |cut -f5,7,8
done >>Monalingtochicken.alingn.bed


###############################################################

cat Monalingtochicken.alingn.sort.align.sort.bed.geneid |while read line ;do grep $line 
sort -k1,1V -k2,2n Monalingtochicken.alingn.bed | $bedtoolsp/bin/bedtools merge -i - >Monalingtochicken.alingn.sort.align.sort.bed
$bedtoolsp/bin/bedtools -a $Chickannbed -b Monalingtochicken.alingn.sort.align.sort.bed -wa -wb |awk '{if($NF>0.3)}print $3' >Monalingtochicken.alingn.sort.align.sort.bed.geneid
cat Monalingtochicken.alingn.sort.align.sort.bed.geneid |while read line ;do grep $line $Mclfile ;done >mcl.out.fitchichen.txt

cat $PlatySexGen |while read line
do
        grep -w "$line"  $Mclfile
done >>mcl.out.fitchichen.txt

cat $EchidnaSexGen |while read line
do
        grep -w "$line"  $Mclfile
done >>mcl.out.fitchichen.txt

python $Binpath/Ampliconicstats.py $EchidnaAssign $PlatypusAssign $Allaglis mcl.out.fitchichen.txt chrY chrY_genefamily.txt
python $Binpath/Ampliconicstats.py $EchidnaAssign $PlatypusAssign $Allaglis mcl.out.fitchichen.txt chrX chrY_genefamily.txt