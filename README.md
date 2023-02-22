
# Echidna_sexchromosome

This repository include three piplines used in echidna genome study, mainly about the sex chromosome analysis.  

## X/Y identity & strata divergence calculation

This pipline (in [XY_identity](https://github.com/Dived-Jin/Echidna_sexchromosome/tree/main/XY_identity)) include two steps:  
1. Calculate X/Y identity based on lastZ MAF and NET results.  
2. Calculate strata divergence by baseml with MAF.  

## Hi-C Strength comparison

This pipline (in [Ampliconic_Annotation](https://github.com/Dived-Jin/Echidna_sexchromosome/tree/main/Ampliconic_Annotation)) is used to confirm if an unplaced scaffold is autosomal or sex-linked, by comparing Hi-C strength between the scaffold with assigned chromosomes. 

## Ampliconic region annotation

This pipeline (in [HiC_strength_compared](https://github.com/Dived-Jin/Echidna_sexchromosome/tree/main/HiC_strength_compared)) includes four steps:  
1. Ampliconics region annontation by blastn and depth methods.  
2. Orthologs clustering by MCL methods. 
3. Ampliconic family classification based on ortholog. 
4. Ampliconic genes visualizeation in circos plot.  
