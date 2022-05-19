rule gatk_ApplyBQSR:
    input:
        bam = "../results/mapped/{sample}_mkdups.bam",
        recal = "../results/bqsr/{sample}_recalibration_report.grp",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        bam = protected("../results/mapped/{sample}_recalibrated.bam")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        partition = "serial"
    log:
        "logs/gatk_ApplyBQSR/{sample}.log"
    benchmark:
        "benchmarks/gatk_ApplyBQSR/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Applying base quality score recalibration and producing a recalibrated BAM file for {input.bam}"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """gatk ApplyBQSR --java-options {params.maxmemory} \
        -I {input.bam} \
        -bqsr {input.recal} \
        -R {input.refgenome} \
        -O {output} \
        --tmp-dir {params.tdir} \
        {params.padding} {params.intervals} &> {log}"""