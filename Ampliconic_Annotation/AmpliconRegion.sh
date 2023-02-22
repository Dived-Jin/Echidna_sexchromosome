#/bin/bash
###
#this pipline is used for finding ampliconic region and genes
###
#########################
function Checkfile(){
    checkf=$1
    if [[-Z $checkf]] && [ !-f $checkf ];then 
        echo "False"
    else
        echo "True"
    fi
}

function Mkc(){
    dirm=$1
    if [ ! -d $dirm ];then
        mkdir -p $dirm
    fi 
}

#####################################################
#followed tools need add manually
#####################################################
Blatnp="" #blastn
seqtkp="" #seqtk
bwap="" #bwa
samtoolsp="" #samtools
bedtoolsp="" #bedtools 
hcluster_sgp="" # Solar

#####################################################
#option
#####################################################
while getopts :f:g:o:p:r:fq1:fq2:: option
do
case "${option}"
in
f) inputfasta=${OPTARG};;
b) befile=${OPTARG};;
g) gffile=${OPTARG};;
o) outdir=${OPTARG};;
p) prefixname=${OPTARG};;
fq1) Fq1file=${OPTARG};;
fq2) Fq2file=${OPTARG};;
d) SeqDepth=${OPTARG};;
esac
done

######################################################
USED_methods='''
    sh IdentifyAmpliconicRegion.sh -f <inputfasta> -b <bed file> -g <gff file> -o <outdir> -p <prefix name> -r <rm diretion> -fq1 <fqfile> -fq2 <fq2file> -d <depth>\n
        \t-f  X|Y nonPAN region sequnce file with fasta format\n
        \t-b sex chromosome region file\n
        \t-o output direction\n
        \t-p outfile prefix name\n
        \t-fq1 sequnce data with fastq formate\n
        \t-fq2 sequnce data with fastq formate\n
        \t-d seq depth
'''
if [ -z $inputfasta ];then 
    echo -e $USED_methods
    exit 0
fi

###################################################### 
#checks file

filesLis=($inputfasta $gffile $Fq1file $Fq2file)
continueRuns=0
for files in ${filesLis[@]}
do 
    stat=`Checkfile $f`
    if [ $stat == "False" ];then 
        echo "$file not exists!"
            continueRuns=1
    fi
done
if [ ${continueRuns} !=0 ];then 
    exit 0
fi

#########################################################
######################################################
#global var
Shelldir=$(dirname $0) # script path 
Binpath="${Shelldir}/../bin/" # local script path
if [ -z ${outdir} ];then 
    runpath=`pwd`
else
    runpath=$outdir
fi
tmpdir="${runpath}/tmp" #temdir 
Runblastdir="${runpath}/blastn" #run blastn method direction 
Rundepth="${runpath}/depth" #run depth method direction
lnsfasta="${tmpdir}/${prefixname}.fasta" # X/Y sequences
lnsgff="${tmpdir}/${prefixname}.gff"    # annatation file
splitwinds="${tmpdir}/${prefixname}.bed" # splite bed 
splitfasta="${tmpdir}/${prefixname}.split.fasta"    #split sequence
Sexbedfile=$tmpdir/SexRegion.bed
SexGenbed=$tmpdir/SexGene.bed
removsh="{runpath}/RMtemp.sh"

########################################################
date
echo -e "--> start pipline\nstep 1 split windowns start"
Mkc ${tmpdir}
echo "ln -s ${inputfasta} ${lnsfasta}"
ln -s ${inputfasta} ${lnsfasta}
echo "ln -s ${gffile} ${lnsgff}"
ln -s ${gffile} ${lnsgff}
ln -s ${befile} ${Sexbedfile}
echo "${samtoolsp}/samtools faidx ${lnsfasta} "
${samtoolsp}/samtools faidx ${lnsfasta} 
echo "${bedtoolsp}/bedtools makewindows -g ${lnsfasta}.fai -w 2000 -s 1000 >${splitwinds}"
${bedtoolsp}/bedtools makewindows -g ${lnsfasta}.fai -w 2000  >${splitwinds}
echo "${bedtoolsp}/bedtools getfasta -fi ${lnsfasta} -bed ${splitwinds} >${splitfasta}"
${bedtoolsp}/bedtools getfasta -fi ${lnsfasta} -bed ${splitwinds} >${splitfasta}
echo "${bedtoolsp}/bedtools coverage -a $tmpdir/Gen.bed -b $Sexbedfile |awk '\$NF >0.5' >$SexGenbed "
cat ${lnsgff} |grep mRNA |awk -F "[\t=;]" '{print $1"\t"$4"\t"$5"\t"$10}' >$tmpdir/Gen.bed
${bedtoolsp}/bedtools coverage -a $tmpdir/Gen.bed -b $Sexbedfile |awk '$NF >0.5' >$SexGenbed
echo -e "step 1 split windowns finished"


#############################################################
#step 2 run blastn methods
date
echo -e "step2 run blastn methods start"
blastout="${Runblastdir}/${prefixname}.blastn.m8"
echo "blastn -query ${splitfasta} -subject ${splitfasta} -evalue 1e-2 -outfmt 6 >${blastout}"
blastn -query ${splitfasta} -subject ${splitfasta} -evalue 1e-2 -outfmt 6 >${blastout}
echo -e "filter blastout \n"
blastoutF="${blastout}.filt_ic99"
echo -e "filter blastout \n perl ${Binpath}/blast_filter.pl -i ${blastout} -f ${splitfasta} -ic 99 >${blastoutF}"
perl ${blastscrip}/blast_filter.pl -i ${blastout} -f ${splitfasta} -ic 99 >${blastoutF}
echo -e "filter aligment ratio"
blastoutFR="${blastoutF}.ratio0.5"
awk '{if($5>0.5 && $13>99)print}' ${blastoutF} >${blastoutFR}
extracttab="${blastoutFR}.extracted"
awk -F " " '{print $1"\t"$7"\t10"}' ${blastoutFR} >${extracttab}
hgclustertab=${extracttab}.hgcluster
echo "$hgclusterp -w 0 -c ${extracttab} >${hgclustertab}"
$hcluster_sgp -w 0 -c ${extracttab} >${hgclustertab}
blastAGregion=${Runblastdir}/${prefixname}.blastnAG.bed
perl ${Binpath}/format_hcluster.pl ${hgclustertab} >${blastAGregion}
BlastAGs=${Runblastdir}/${prefixname}.blastnAGs.txt
${bedtoolsp}/bedtools intersect -b ${blastAGregion} -a ${SexGenbed} wa -wb -f 0.5 >$BlastAGs
date 
echo "step 2 run blastn methods start"

################################################################### 
#step 3 run depth methods
#this step need X/Y fastq if not please used whole genome to analysis
################################################################### 
date 
echo -e "step3 run depth methods start"
echo -e "build index"
echo "${bwap}/bwa index ${lnsfasta}"
${bwap}/bwa index ${lnsfasta}
echo "run bwa"
bamfile=${Rundepth}/${prefixname}.sort.bam
if [ -f ${Fq2file} ];then 
    echo "pair read alignment"
    echo -e " ${bwap}/bwa mem ${lnsfasta} ${Fq1file} ${Fq2file} -t 5 |${samtoolsp}/samtools view -@ 5 -b -|${samtoolsp}/samtools sort -@ 5 - >${bamfile}"
    ${bwap}/bwa mem ${lnsfasta} ${Fq1file} ${Fq2file} -t 5 |${samtoolsp}/samtools view -@ 5 -b -|${samtoolsp}/samtools sort -@ 5 - >${bamfile}
else
    echo "single read alignment"
    echo "${bwap}/bwa mem ${lnsfasta} ${Fq1file} -t 5 |${samtoolsp}/samtools view -@ 5 -b - |${samtoolsp}/samtools sort -@ 5 - >${bamfile}"
    ${bwap}/bwa mem ${lnsfasta} ${Fq1file} -t 5 |${samtoolsp}/samtools view -@ 5 -b - |${samtoolsp}/samtools sort -@ 5 - >${bamfile}
fi
echo "${samtoolsp}/samtools index ${bamfile}"
${samtoolsp}/samtools index ${bamfile}
echo "remove dupliction alignment"
Rmdupbam=${bamfile}.rmdup.bam
java -jar ${picardp}/picard.jar MarkDuplicates REMOVE_DUPLICATES=true I=${bamfile} O=$Rmdupbam M=${Rundepth}/merg.matir VALIDATION_STRINGENCY=LENIENT
echo "output depth"
depthfile="${Rundepth}/${prefix}.depth"
echo "${samtoolsp}/samtools depth | awk '{print $1"\t"$2-1"\t"$2"\t"$3}' >${depthfile}"
${samtoolsp}/samtools depth | awk '{print $1"\t"$2-1"\t"$2"\t"$3}' >${depthfile}
echo "windowns depth calculate"
countdepth=${Rundepth}/${prefix}.depth.windows
echo "${bedtoolsp}/bedtools map -a ${splitwinds} -b ${depthfile} -c 4 -o median,mean,count > ${countdepth}"
${bedtoolsp}/bedtools map -a ${splitwinds} -b ${depthfile} -c 4 -o median,mean,count >${countdepth}
countdepthform=${countdepth}.form
python ${Binpath}/Depthformat.py ${countdepth} ${SeqDepth} >${countdepthform}
depthAGregion=${Rundepth}/${prefixname}.DepthAG.bed
awk '$7>=2' $countdepthform | ${bedtoolsp}/bedtools merge -i - >${depthAGregion}
depthAGs=${Rundepth}/${prefixname}.DepthAGs.txt
${bedtoolsp}/bedtools intersect -b ${depthAGregion} -a ${SexGenbed} wa -wb -f 0.5 >${depthAGs}
date
echo -e "step3 run depth methods finished"

#####################################################

#####################################################
#MergeResult 
#

Agregionfile=${runpath}/${prefixname}.AG.region.bed 

if [ -f ${blastAGregion} ];then 
    cat ${blastAGregion} >$Agregionfile
fi 

if [ -f ${countdepthform} ];then 
    cat ${countdepthform} >>$Agregionfile
fi 

sortAGregion=${runpath}/${prefixname}.AG.region.merge.bed
AGregiongene=${runpath}/${prefixname}.AG.gene.merge.bed
sort -k1,1V -k2,2n ${Agregionfile} |${bedtoolsp}/bedtools merge -i - >${sortAGregion}
bedtools coverage -a ${lnsgff} -b ${sortAGregion} |awk -F " " '$NF>0.5' >${AGregiongene}

#############################################################

echo "rm -rf ${tmpdir}" >${removsh}
echo "rm -rf ${Runblastdir}" >>${removsh}
echo "rm -rf ${Rundepth}" >>${removsh}