#/bin/bash
################################
function Mkc(){
    dirm=$1
    if [ ! -d $dirm ];then
        mkdir -p $dirm
    fi
}

########################

#interact matirx was generate by HiC-Pro with follow parameter
#LIGATION_SITE = GATCGATC
#MIN_FRAG_SIZE = 100
#MAX_FRAG_SIZE = 100000
#MIN_INSERT_SIZE = 100
#MAX_INSERT_SIZE = 600
#GET_ALL_INTERACTION_CLASSES = 1
#GET_PROCESS_SAM = 1
#RM_SINGLETON = 1
#RM_MULTI = 1
#RM_DUP = 1
#BIN_SIZE = 10000 20000 25000 30000 40000 50000 100000 500000
#MATRIX_FORMAT = upper
#MAX_ITER = 100
#FILTER_LOW_COUNT_PERC = 0.02
#FILTER_HIGH_COUNT_PERC = 0
#EPS = 0.1

#####################################################
HiC-ProPath=""
JuicerPath=""
####################################################
outdir=$1
Absbed=$2
matrixtab=$3
faidxfile=$4
atuosomebed=$5
Sexchromobed=$6
checkbed=$7

Mkc $outdir
#######################################
Shelldir=$(dirname $0) # script path
Binpath="${Shelldir}/../bin/" # local script path
############################################
#compared hic strength
############################################
cd $outdir
awk '{print $4"\t"$0}' $Absbed | cut -f1-4 > input_abs.bed.cut
perl $Binpath/AddColumn.v2.pl $matrixtab $Absbed 1| $Binpath/AddColumn.v2.pl - input_abs.bed.cut 2 | awk '{print $4"\t"$5"\t"$6"\t"$7"\t"$8"\t"$9"\t"$3}' > input_iced.matrix.add
python $Binpath/get_overlap.py $checkbed input_iced.matrix.add >input_iced.matrix.add.filt
python $Binpath/calculate.v1.1.py $checkbed input_iced.matrix.add.filt $Sexchromobed $atuosomebed >checkbed.tab
perl pick.column_info.pl checkbed.tab $checkbed 1 1 -t diff | awk '{print $1"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"}' >> checkbed.tab
perl $Binpath/AddColumn.v2.pl checkbed.tab $faidxfile 1 | cut -f1-13 | sort -k13,13nr >checkbed.tab.add
perl $Binpath/fdr.excludeNA.v1.pl checkbed.tab.add > checkbed.tab.add.fdr 
awk '$5>$10 && $14<0.05' checkbed.tab.add.fdr  >checkbed.tab.add.fdr.filt #Sex chromosome

#######################################################################
#hic map visualization
#######################################################################
##add hicexplorer env python 
hicConvertFormat -m $matrixtab --bedFileHicpro $Absbed --inputFormat hicpro --outputFormat h5 -o Prohic.h5
cat $atuosomebed $Sexchromobed > y.aix.txt
awk -F " " '{print $1}' checkbed.tab.add.fdr.filt |while read line 
do 
    Plotheatmapdir="$outdir/$line"
    awk '{print $1}' $outdir/y.aix.txt |while read line1 
    do 
        hicPlotMatrix -m Prohic.h5 -out $Plotheatmapdir/$line1.pdf --region $line --region2 $line1 --vMin 0 --vMax 50
    done
done 

#####################################################################
#box plot
#####################################################################
cut -f1 $atuosomebed >atuo.txt 
cut -f1 $Sexchromobed >Sex.txt
python $Binpath/AddtyforMatrix.py $outdir/y.aix.txt input_iced.matrix.add input_iced.matrix.add.addinform
awk -F " " '{print $1}' checkbed.tab.add.fdr.filt |while read line
do 
    grep -w $line input_iced.matrix.add input_iced.matrix.add.addinform >tmp.txt 
    Rscript examine_interaction.nolog.r tmp.txt $line.pdf atuo.txt Sex.txt
done 