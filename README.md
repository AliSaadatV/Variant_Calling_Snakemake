This repository contains the workflow to call variants from next-generation sequencing (NGS) data. 
**Snakemake** is used to manage the workflow. 



1. To run on a cluster, check out [this blog](https://www.sichong.site/workflow/2021/11/08/how-to-manage-workflow-with-resource-constraint.html). In summary, create the file *~/.config/snakemake/slurm/config.yaml* and write the following lines in it:

```
jobs: 32
cluster: "sbatch -p {resources.partition} -t {resources.time_min} --mem={resources.mem_mb} -c {resources.cpus} -o logs/{rule}_{wildcards} -e logs/{rule}_{wildcards} --mail-type=FAIL --mail-user=your.email@email.com"
default-resources: [cpus=1, mem_mb=4000, time_min=1440, partition="serial"]
resources: [cpus=145, mem_mb=500000]
```

2. Edit *config.yaml* inside the config folder (this one is different from cluster profile config which was made in previous step).

3. Put the fastq files inside *data/fastq/* and edit pedigree file in *data/pedigree/* if you have trio in the dataset. Reads must have names like ID_R1.fastq.gz and ID_R2.fastq.gz (not ID_1.fastq.gz and ID_2.fastq.gz) 

4. Open a [screen](https://linux.die.net/man/1/screen) or [tmux](https://man7.org/linux/man-pages/man1/tmux.1.html) on the cluster side (in case of a problem with connection, the program will run in the background), then run  `bash dryrun_hpc.sh` to see the steps of workflow. To actually run the workflow, use `bash run_hpc.sh` or `snakemake --profile slurm --use-conda --conda-frontend mamba --latency-wait 120 --configfile ../config/config.yaml`

Notes:
* It's a good idead to copy the data and snakemake workflow into a large temporary folder (like /scratch) and run the analysis. After finishing the workflow, we can copy important results (like recalibrated BAM or refined VCF) into a directory which gets backed up.

* Pay attention to the partition. For Scitas (Fidis) at EPFL, partition "serial" is used for most of the workflow because we use only one cpu. Some tools support multithreading, for them we use "parallel" partition.

* If you get an error but do not find the solution, try increasing the memory!

* After finishint the workflow, you can use [multiqc](https://multiqc.info) to check quality of raw fastq file (go inside *results/qc/fastqc* and run `multiqc .`) or to check the performence of trimming (go inside *logs/fastp* and run `multiqc .`).

Used tools are:
* fastqc
* fastp
* BWA
* samtools
* GATK