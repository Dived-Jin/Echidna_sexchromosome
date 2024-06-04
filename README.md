
# Echidna_sexchromosome

This repository include three piplines used in echidna genome study, mainly about the sex chromosome analysis.  

## X/Y identity & strata divergence calculation

This pipline (in [XY_identity](https://github.com/Dived-Jin/Echidna_sexchromosome/tree/main/XY_identity)) include two steps:  
1. Calculate X/Y identity based on lastZ MAF and NET results.  
2. Calculate strata divergence by baseml with MAF.  

## Hi-C Strength comparison

This pipline (in [HiC_strength_compared](https://github.com/Dived-Jin/Echidna_sexchromosome/tree/main/HiC_strength_compared)) is used to confirm if an unplaced scaffold is autosomal or sex-linked, by comparing Hi-C strength between the scaffold with assigned chromosomes. 

## Ampliconic region annotation

This pipeline (in [Ampliconic_Annotation](https://github.com/Dived-Jin/Echidna_sexchromosome/tree/main/Ampliconic_Annotation)) includes five steps:  
1. Repeat annotation with TRF, RepeatMasker & RepeatModeler
2. Palindrome detection with lastz and palindrover  
3. Tandem ampliconic region identified with blastn
4. Collapsed ampliconic region identified with male sequencing depth
5. Combine the ampliconic regions above. 
