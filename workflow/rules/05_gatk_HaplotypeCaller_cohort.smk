rule gatk_HaplotypeCaller:
    input:
        bams = "../results/mapped/{sample}_recalibrated.bam",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        dbsnp = expand("{dbsnp}", dbsnp = config['dbSNP'])
    output:
        vcf = "../results/called/{sample}_raw_snps_indels_tmp.g.vcf",
        index = "../results/called/{sample}_raw_snps_indels_tmp.g.vcf.idx"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['HC']),
        tdir = config['TEMPDIR'],
        padding = get_wes_padding_command,
        intervals = get_wes_intervals_command,
        ped = get_pedigree_command,
        other = "-ERC GVCF",
        partition = "serial"
    log:
        "logs/gatk_HaplotypeCaller/{sample}.log"
    benchmark:
        "benchmarks/gatk_HaplotypeCaller/{sample}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Calling germline SNPs and indels via local re-assembly of haplotypes for {input.bams}"
    resources: cpus=1, mem_mb=20000, time_min=1440
    shell:
        """gatk HaplotypeCaller --java-options {params.maxmemory} \
        -I {input.bams} \
        -R {input.refgenome} \
        -D {input.dbsnp} \
        -O {output.vcf} \
        --tmp-dir {params.tdir} \
        -G StandardAnnotation -G AS_StandardAnnotation -G StandardHCAnnotation \
        {params.padding} {params.intervals} \
        {params.ped} \
        {params.other} &> {log} """