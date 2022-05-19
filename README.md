This repository contains the workflow to call variants from next-generation sequencing (NGS) data. 
**Snakemake** is used to manage the workflow. 

Note: reads must have names like ID_R1.fastq.gz and ID_R2.fastq.gz (not ID_1.fastq.gz and ID_2.fastq.gz) 

TO run on a cluster, check out https://www.sichong.site/workflow/2021/11/08/how-to-manage-workflow-with-resource-constraint.html. In summary, create the file *~/.config/snakemake/slurm/config.yaml* and write the following lines in it:

* jobs: 32
* cluster: "sbatch -t {resources.time_min} --mem={resources.mem_mb} -c {resources.cpus} -o logs_slurm/{rule}_{wildcards} -e logs_slurm/{rule}_{wildcards} --mail-type=FAIL --mail-user=your.email@email.com"
* default-resources: [cpus=2, mem_mb=4000, time_min=1440]
* resources: [cpus=50, mem_mb=500000]



First open a *screen* on the server side, then run  **snakemake --profile slurm --use-conda --conda-frontend mamba --latency-wait 120 --configfile ../config/config.yaml**

Do not forget to edit *config.yaml* file.

Required tools are:
* fastqc
* fastp
* BWA
* samtools
* GATK