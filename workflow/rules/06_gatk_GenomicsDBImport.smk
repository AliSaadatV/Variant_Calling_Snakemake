rule GenomicsDBImport:
    input:
        gvcfs_list = expand("../results/called/{sample}_raw_snps_indels_tmp.g.vcf", sample = SAMPLES), 
        gvcfs_index = expand("../results/called/{sample}_raw_snps_indels_tmp.g.vcf.idx", sample = SAMPLES),
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        db = directory("../results/genomicsDB/{CHROMS}.db")
    params:
        gvcfs=lambda wildcards, input: [f" -V {v}" for v in input["gvcfs_list"]],
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        partition = "serial"
    log:
        "logs/gatk_genomicsDBImport/{CHROMS}.log"
    benchmark:
        "benchmarks/gatk_genomicsDBImport/{CHROMS}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Import into genomics db for {output.db}"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk GenomicsDBImport --java-options {params.maxmemory} \
        --genomicsdb-workspace-path {output.db} \
        --L {wildcards.CHROMS} \
        {params.gvcfs} \
        --reader-threads 1 \
        --batch-size 50 \
        --genomicsdb-shared-posixfs-optimizations true \
        --tmp-dir {params.tdir} &> {log}
        """