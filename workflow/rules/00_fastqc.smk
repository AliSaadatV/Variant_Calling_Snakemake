rule fastqc:
    input:
        ["../data/fastq/{sample}_R1.fastq.gz", "../data/fastq/{sample}_R2.fastq.gz"]
    output:
        html = ["../results/qc/fastqc/{sample}_1_fastqc.html", "../results/qc/fastqc/{sample}_2_fastqc.html"],
        zip = ["../results/qc/fastqc/{sample}_1_fastqc.zip", "../results/qc/fastqc/{sample}_2_fastqc.zip"]
    log:
        "logs/fastqc/{sample}.log"
    benchmark:
        "benchmarks/fastqc/{sample}.tsv"
    #threads: config['THREADS']
    conda:
        "../envs/fastqc.yaml"
    message:
        "Undertaking quality control checks on raw sequence data for {input}"
    threads: 1
    resources: cpus=1, mem_mb=2000, time_min=1440
    shell:
        "fastqc {input} -o ../results/qc/fastqc/ &> {log}"