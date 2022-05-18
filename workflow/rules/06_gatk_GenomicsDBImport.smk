rule GenomicsDBImport:
    input:
        gvcfs_list = expand("../results/called/{sample}_raw_snps_indels_tmp.g.vcf", sample = SAMPLES), 
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        db = directory("../results/genomicsDB/{CHROMS}.db")
    params:
        gvcfs=lambda wildcards, input: [f" -V {v}" for v in input["gvcfs_list"]]
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_genomicsDBImport/{CHROMS}.log"
    benchmark:
        "benchmarks/gatk_genomicsDBImport/{CHROMS}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Import into genomics db for {output.db}"
    shell:
        """
        gatk --java-options {params.maxmemory}" \
        GenomicsDBImport \
        --genomicsdb-workspace-path {output.db} \
        --L {wildcards.CHROMS} \
        {params.gvcfs} \
        --reader-threads 1 \
        --batch-size 50 \
        --genomicsdb-shared-posixfs-optimizations true \
        --tmp-dir {params.tdir} &> {log}
        """