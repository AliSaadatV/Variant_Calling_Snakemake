rule gatk_MarkDuplicates:
    input:
        "../results/mapped/{sample}.bam"
    output:
        bam = "../results/mapped/{sample}_mkdups.bam",
        metrics = "../results/mapped/{sample}_mkdups_metrics.txt"
    params:
        maxmemory = get_mkdup_xmx,
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_MarkDuplicates/{sample}.log"
    benchmark:
        "benchmarks/gatk_MarkDuplicates/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_MarkDuplicates for {input}"
    resources: cpus=28, mem_mb=get_mkdup_memory, time_min=1440, partition="parallel"
    shell:
        """gatk MarkDuplicatesSpark --java-options {params.maxmemory} \
        -I {input} \
        -O {output.bam} \
        -M {output.metrics} \
        --spark-master local[*] \
        --tmp-dir {params.tdir} &> {log}"""