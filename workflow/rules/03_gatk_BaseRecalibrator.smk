rule gatk_BaseRecalibrator:
    input:
        bams = "../results/mapped/{sample}_mkdups.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        report("../results/bqsr/{sample}_recalibration_report.grp", caption = "../report/recalibration.rst", category = "Base recalibration")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        recalibration_resources = get_recal_resources_command,
        partition = "serial"
    log:
        "logs/gatk_BaseRecalibrator/{sample}.log"
    benchmark:
        "benchmarks/gatk_BaseRecalibrator/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Generating a recalibration table for {input.bams}"
    resources: cpus=1, mem_mb=2000, time_min=1440
    shell:
        """gatk BaseRecalibrator --java-options {params.maxmemory} \
        -I {input.bams} \
        -R {input.refgenome} \
        -O {output} \
        --tmp-dir {params.tdir} \
        {params.padding} {params.intervals} {params.recalibration_resources} &> {log}"""