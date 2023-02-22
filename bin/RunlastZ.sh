#/bin/bash
###
#this pipline is used for running lastZ
###
function Mkc(){
    dirm=$1
    if [ ! -d $dirm ];then
        mkdir -p $dirm
    fi 
}

##################################################
lastZbin="" #lastZ script 
Kentkit="" #Kent Utils
seqkitbin=""
###################################################
nowdir=`pwd`
Shelldir=$(dirname $0) # script path 
Binpath="${Shelldir}/../bin/" # local script path
###################################################

target=$1
querys=$2
outpath=$3

#####################################################

Mkc $outpath 
cd $outpath
quername=`basename $querys`
targetname=`bansename $target`
ln -s $target $outpath/$targetname
ln -s $querys $outpath/$quername
##step1 
$Kentkit/faToTwoBit $quername $quername.2bit
$Kentkit/faToTwoBit $targetname $targetname.2bit
$Kentkit/faSize  $quername -detailed >$quername.size 
$Kentkit/faSize  $targetname -detailed >$targetname.size 
##step2
Splitdir=$outpath/split
num=`grep -c ">" $targetname`
$seqkitbin/seqkit split2 -p $num -o split -1 $targetname 
for fasta in $Splitdir/*.fasta
do 
    $Kentkit/faToTwoBit $fasta $fasta.2bit
    $lastZbin/lastz $fasta.2bit $outpath/quername.2bit --hspthresh=4500 --gap=600,150 --ydrop=15000 --notransition --scores=$Binpath/chimpMatrix --format=axt >$fasta.axt
done 
##step3
Chinedir=$outpath/chain
Mkc $Chinedir
for files in $Splitdir/*.fasta 
do 
    baN=`basename $files`
    $Kentkit/axtChain -minScore=5000 -linearGap=$files.axt $files.2bit $outpath/quername.2bit $Chinedir/$BaN.chain 
done 
##step4
MergChian=$outpath/mergchain
Mkc $MergChian
$Kentkit/chainMergeSort $Chinedir/*.chain >all.chain
$Kentkit/chainPreNet $MergChian/all.chain $outpath/$targetname.zise $outpath/$quername.size  $MergChian/all_sort.chain
##step5
Netdir=$outpath/net
$Kentkit/chainNet $MergChian/all_sort.chain $outpath/$targetname.zise $outpath/$quername.size $Netdir/temp  $Netdir/query.net
$Kentkit/netSyntenic $Netdir/temp $Netdir/target.net
##step6
net_to_axtdir=$outpath/net_to_axt
mafdir=$outpath/maf
Mkc $net_to_axtdir
Mkc $mafdir
$Kentkit/netToAxt $Netdir/target.net $MergChian/all_sort.chain $outpath/$targetname.2bit $outpath/$quername.2bit $net_to_axtdir/all.axt
$Kentkit/axtSort  $net_to_axtdir/all.axt  $net_to_axtdir/all_sort.axt
axtToMaf -tPrefix=target -qPrefix=query $net_to_axtdir/all_sort.axt  $outpath/$targetname.size $outpath/$quername.size $mafdir/all.maf

##step 7
cd $Netdir 
grep -E '(^net|type top)' target.net | perl $Binpath/net2aln.pl - > target.net.filt.aln

cd $mafdir
perl $Binpath/maf2pos.v2.1.pl all.maf . target-query
paste target.maf.pos query.maf.pos | cut -f2-5,7-10 > all.maf.aln