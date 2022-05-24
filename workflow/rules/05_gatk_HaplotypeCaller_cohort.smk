rule gatk_HaplotypeCaller:
    input:
        bams = "../results/mapped/{sample}_recalibrated.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
    output:
        vcf = "../results/called/{sample}.g.vcf.gz"
    params:
        maxmemory = get_HC_xmx,
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        ped = get_pedigree_command,
        other = "-ERC GVCF"
    log:
        "logs/gatk_HaplotypeCaller/{sample}.log"
    benchmark:
        "benchmarks/gatk_HaplotypeCaller/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_HaplotypeCaller for {input.bams}"
    resources: cpus=1, mem_mb=get_HC_memory, time_min=4310, partition="serial"
    shell:
        """gatk HaplotypeCaller --java-options {params.maxmemory} \
        -I {input.bams} \
        -R {input.refgenome} \
        -D {input.dbsnp} \
        -O {output.vcf} \
        --tmp-dir {params.tdir} \
        {params.padding} {params.intervals} \
        {params.ped} \
        {params.other} &> {log} """