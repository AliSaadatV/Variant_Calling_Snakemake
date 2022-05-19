rule fastqc:
    input:
        ["../data/fastq/{sample}_R1.fastq.gz", "../data/fastq/{sample}_R2.fastq.gz"]
    output:
        html = ["../results/qc/fastqc/{sample}_R1_fastqc.html", "../results/qc/fastqc/{sample}_R2_fastqc.html"],
        zip = ["../results/qc/fastqc/{sample}_R1_fastqc.zip", "../results/qc/fastqc/{sample}_R2_fastqc.zip"]
    params:
        partition = "serial"
    log:
        "logs/fastqc/{sample}.log"
    benchmark:
        "benchmarks/fastqc/{sample}.tsv"
    conda:
        "../envs/fastqc.yaml"
    message:
        "Undertaking quality control checks on raw sequence data for {input}"
    resources: cpus=1, mem_mb=1000, time_min=1440
    shell:
        "fastqc {input} -o ../results/qc/fastqc/ &> {log}"