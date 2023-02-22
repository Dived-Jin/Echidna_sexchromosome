#/bin/bash
###
#this pipline is used for finding ampliconic region and genes
###
function Mkc(){
    dirm=$1
    if [ ! -d $dirm ];then
        mkdir -p $dirm
    fi
}

###############################
samtoolsp=""
#############################
nowdir=`pwd`
Shelldir=$(dirname $0) # script path 
Binpath="${Shelldir}/../bin/" # local script path

#################################

EchidnaXfasta=$1
platypusfasta=$2
EchidnaAGsXfile=$3
PlatypusAGsXfile=$4
MClXclassfile=$5
EsexXassign=$6
PsexXassign=$7
outdir=$nowdir/paint

#############################################################

Mkc $outdir
Mkc  $outdir/lastZ 

#############################################################
sh $Binpath/RunlastZ.sh $EchidnaXfasta $platypusfasta $outdir/lastZ 
cd $outdir
ln -s $EchidnaXfasta
ln -s $platypusfasta
Ename=`basename $EchidnaXfasta`
Pname=`bansename $platypusfasta`
python SplitAmpliconicClass.py $EchidnaAGsXfile $PlatypusAGsXfile $MClXclassfile
$samtoolsp faidx $Ename
$samtools faidx $Pname
awk -F " " '{if($4="Xun")}' $EsexXassign |while read line
do 
    chr=`echo $line|awk '{print $1}'`
    sexid=`echo $line|awk '{print $4}'`
    lengthE=`grep -w $chr $Ename.fai|awk -F " " '{print $2}'`
    color=`echo $line|awk '{print $NF}'` 
    echo -e "chr\t-\t$chr\t$sexid\t1\t$lengthE\t$color" 
done >>karyotype.E.txt

awk -F " " '{if($4="Xun")}' $PsexXassign |while read line
do 
    chr=`echo $line|awk '{print $1}'`
    sexid=`echo $line|awk '{print $4}'`
    lengthE=`grep -w $chr $Pname.fai|awk -F " " '{print $2}'`
    color=`echo $line|awk '{print $NF}'` 
    echo -e "chr\t-\t$chr\t$sexid\t1\t$lengthE\t$color"
done >>karyotype.P.txt

awk -F " " '{if($4-$3 >1000) print $1"\t"$3"\t"$4"\t"$5"\t"$7"\t"$8}'  $outdir/lastZ/net/target.net.filt.aln |while read line 
do 
    key=`echo $line|awk '{print $1}'`
    colors=`grep $key $EsexXassign|awk '{print $NF}'`
    echo -e "$line\tcolor=($colors)"
done >alignfile.txt 

########################################################################
# generate circos.conf file by manual 
#########################################################################

circos -noparanoid -conf ./circos.conf -debug_group summary,timer