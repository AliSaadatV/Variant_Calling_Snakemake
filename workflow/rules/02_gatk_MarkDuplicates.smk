rule gatk_MarkDuplicates:
    input:
        "../results/mapped/{sample}.bam"
    output:
        bam = "../results/mapped/{sample}_mkdups.bam",
        metrics = "../results/mapped/{sample}_mkdups_metrics.txt"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['MARK_DUP']),
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_MarkDuplicates/{sample}.log"
    benchmark:
        "benchmarks/gatk_MarkDuplicates/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_MarkDuplicates for {input}"
    resources: cpus=28, mem_mb=40000, time_min=1440, partition="parallel"
    shell:
        """gatk MarkDuplicatesSpark --java-options {params.maxmemory} \
        -I {input} \
        -O {output.bam} \
        -M {output.metrics} \
        --spark-master local[*] \
        --tmp-dir {params.tdir} &> {log}"""