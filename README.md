This repository contains the workflow to call variants from next-generation sequencing (NGS) data. 
**Snakemake** is used to manage the workflow. 

Note: reads must have names like ID_R1.fastq.gz and ID_R2.fastq.gz (not ID_1.fastq.gz and ID_2.fastq.gz) 

TO run on a cluster, check out [https://www.sichong.site/workflow/2021/11/08/how-to-manage-workflow-with-resource-constraint.html]

Required tools are:
* fastqc
* fastp
* BWA
* samtools
* GATK