#/bin/bash
###
#this pipline is used for MCL cluster
###
function Mkc(){
    dirm=$1
    if [ ! -d $dirm ];then
        mkdir -p $dirm
    fi
}

#####################################################
#followed tools need add manually
#####################################################
blastpath="" #ncbi-blast-2.2.31+
#####################################################

echo "sh $0 <pep fasta> <annotation file>"

allpepfast=$1 #pep fasta #>specialN_Genid 
Genannotation=$2 # Genid\tfunction

if [ ! -f $allpepfast ];then 
    echo "$allpepfast did exists"
    exit
fi

######################################################
Shelldir=$(dirname $0) # script path
Binpath="${Shelldir}/../bin/" # local script path
#######################################################
nowdir="pwd"
Outdir=$nowdir/MClcluster
Mkc $Outdir
cd $Outdir
$blastpath/makeblastdb -in $allpepfast -dbtype prot
$blastpath/blastp -query $allpepfast -db $allpepfast -outfmt 6 -evalue 1e-2 -num_threads 5 >all.pep.m8 
python3 $Binpath/02.homolog_group_typing.clmInfo.py all.pep.m8 $Genannotation > mcl.out 2> mcl.log
perl $Binpath/format_mlcOut.v1.pl mcl.out > mcl.out.tab
cat mcl.out.tab |while read line
do 
    key=`echo $line|awk -F " " '{print $NF}'`
    ann=`grep -w $key $Genannotation|awk '{print $2}'`
    echo -e "$line\t$ann"
done >mcl.out.tab.addann