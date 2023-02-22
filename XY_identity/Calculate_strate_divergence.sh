#/bin/bash
function Mkc(){
    dirm=$1
    if [ ! -d $dirm ];then
        mkdir -p $dirm
    fi
}

#####################################
basmlpath=" " #

Shelldir=$(dirname $0) # script path
Binpath="${Shelldir}/../bin/" # local script path
nowdir=`pwd`

######################################

inputmaf=$1
Stratabed=$2
noncoding=$3
XYLastaln=$4
NonRPARYbed=$5

#########################################
Rmcodingmaf="nocodingregion.maf"
#########################################
perl $Binpath/get_maf_by_bed_from_multi.v1.pl -slice -spe query $inputmaf $noncoding >$Rmcodingmaf.1
perl $Binpath/get_maf_by_bed_from_multi.v1.pl -slice -spe target $Rmcodingmaf.1 $noncoding >$Rmcodingmaf
cat $Stratabed |while read line 
do 
    arra=(${line// / })
    chr=${arra[0]}
    star=${arra[1]}
    end=${arra[2]}
    ty=${arra[3]}
    mapkep=${arra[4]}
    outdir="$nowdir/Strata/$ty"
    Mkc $outdir 
    cd $outdir 
    echo "$chr\t$star\t$end" >StrataRegion.bed
    perl $Binpath/get_maf_by_bed_from_multi.v1.pl -slice -spe query $nowdir/$Rmcodingmaf  StrataRegion.bed >$ty.noncoding.maf 
    perl $Binpath/maf2pos.v2.1.pl  $ty.noncoding.maf . target-query 
    paste target.maf.pos query.maf.pos  >all.aln.kep
    python $Binpath/RMredundancy.py $XYLastaln all.aln.kep all.aln.keep 
    if [ $mapkep != "Yun" ];then
        awk -F " " '{if($NF=="'$mapkep'")print $1}' $NonRPARYbed |while read line1;do grep $line1 all.aln.keep; done|sort -k2,2V  -k4,4n >all.aln.keep.map
    else
        ln -s all.aln.keep all.aln.keep.map
    fi 
    python $Binpath/MergeMafseq.py all.aln.keep.map $ty.noncoding.maf noncoding.phy 
    cp $Shelldir/baseml.ctl ./
    cp $Shelldir/nowd.tree ./
    $basmlpath
    cp $Shelldir/baseml_boost.ctl baseml.ctl 
    $basmlpath 
    grep tree mlb|awk -F " " '{print $NF}' >Rootlength.txt
    python $Binpath/Confidence95.py Rootlength.txt >Root_confidence.txt
done 