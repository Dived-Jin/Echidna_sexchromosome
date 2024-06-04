# Ampliconic Annotation
This pipeline is used to annotate ampliconic regions in echidna sex chromosome analysis, including the following scripts:

- step0.repeat.sh
- step1.lastz.sh
- step2.blastn.sh
- step3.depth.sh
- step4.combine.sh

and require following input:
- X.fasta: X sequences in BED format. can contain multiple sequences
- PAR.bed: PAR region in BED format
- read1.fq.gz, read2.fq.gz: WGS reads from a male individual
- echidna.gff.bed: gene annotation in BED format. contains six columns: scafID, start, end, geneID, ".", strand
