rule bwa_mem:
    input:
        R1 = "../data/fastq/{sample}_R1.fastq.gz",
        R2 = "../data/fastq/{sample}_R2.fastq.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output: 
        "../results/mapped/{sample}.bam"
    params:
        readgroup = "'@RG\\tID:{sample}_rg1\\tLB:lib1\\tPL:bar\\tSM:{sample}\\tPU:{sample}_rg1'",
        partition = "parallel"
    log:
        fastp_json = "logs/fastp/{sample}.json",
        fastp_html = "logs/fastp/{sample}.html",
        fastp_log = "logs/fastp/{sample}.log",
        bwa = "logs/bwa/{sample}.log",
        samtools = "logs/samtools/{sample}.log"
    benchmark:
        "benchmarks/bwa_mem/{sample}.tsv"
    conda:
        "../envs/bwa.yaml"
    message:
        "Mapping sequences against a reference human genome with BWA-MEM for {wildcards.sample}"
    resources: cpus=28, mem_mb=40000, time_min=1440
    shell:
        "fastp -i {input.R1} -I {input.R2} --stdout --thread 2 -j {log.fastp_json} -h {log.fastp_html} 2> {log.fastp_log} | "
        "bwa mem -v 2 -M -t 22 -p -R {params.readgroup} {input.refgenome} - 2> {log.bwa} | "
        "samtools view -@ 4 -O BAM -o {output} 2> {log.samtools}"
    