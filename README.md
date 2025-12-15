# Cattle_molQTL
Code and analysis pipelines for multi-tissue cis-molecular QTL (eQTL, sQTL, aQTL, edQTL) mapping, heritability partitioning, and genomic prediction analyses in cattle.

This repository contains analysis code used in the study:

**“Integrative mapping of multi-tissue cis-molecular QTLs reveals regulatory architecture of complex traits in cattle.”**

## Overview
The code supports the identification and analysis of:
- cis-eQTL (expression QTL)
- cis-sQTL (splicing QTL)
- cis-aQTL (alternative polyadenylation QTL)
- cis-edQTL (RNA editing QTL)

as well as downstream analyses including heritability partitioning and genomic prediction.

## Repository structure
- `eQTL/`: scripts for cis-eQTL mapping and expression preprocessing  
- `sQTL/`: splicing QTL analysis pipelines  
- `aQTL/`: APA QTL analysis pipelines  
- `edQTL/`: RNA editing QTL analysis pipelines  
- `utils/`: shared helper scripts  

## Notes
- Raw sequencing data and individual-level genotypes are not publicly available due to data access restrictions.
- Scripts are provided for reproducibility of analytical workflows.

## License
MIT License
