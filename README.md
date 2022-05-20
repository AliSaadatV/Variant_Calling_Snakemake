This repository contains the workflow to call variants from next-generation sequencing (NGS) data. 
**Snakemake** is used to manage the workflow. 



1. To run on a cluster, check out [this blog](https://www.sichong.site/workflow/2021/11/08/how-to-manage-workflow-with-resource-constraint.html). In summary, create the file *~/.config/snakemake/slurm/config.yaml* and write the following lines in it:

```
jobs: 32
cluster: "sbatch -t {resources.time_min} --mem={resources.mem_mb} -c {resources.cpus} -o logs_slurm/{rule}_{wildcards} -e logs_slurm/{rule}_{wildcards} --mail-type=FAIL --mail-user=your.email@email.com"
default-resources: [cpus=2, mem_mb=4000, time_min=1440]
resources: [cpus=50, mem_mb=500000]
```

2. Edit *config.yaml* inside the config folder (this one is different from cluster profile config which was made in previous step).

3. Put the fastq files inside *data/fastq/* and edit pedigree file in *data/pedigree/* if you have trio in the dataset. Reads must have names like ID_R1.fastq.gz and ID_R2.fastq.gz (not ID_1.fastq.gz and ID_2.fastq.gz) 

4. Open a [screen](https://linux.die.net/man/1/screen) or [tmux](https://man7.org/linux/man-pages/man1/tmux.1.html) on the cluster side (in case of a problem with connection, the program will run in the background), then run  `snakemake --profile slurm --use-conda --conda-frontend mamba --latency-wait 120 --configfile ../config/config.yaml`

Used tools are:
* fastqc
* fastp
* BWA
* samtools
* GATK