rule GenomicsDBImport:
    input:
        gvcfs_list = expand("../results/called/{sample}.g.vcf", sample = SAMPLES), 
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        db = directory("../results/genomicsDB/{CHROMS}db"),
        tar = "analysis/genomicsDB/{CHROMS}db.tar"
    params:
        gvcfs=lambda wildcards, input: [f" -V {v}" for v in input["gvcfs_list"]],
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_genomicsDBImport/{CHROMS}.log"
    benchmark:
        "benchmarks/gatk_genomicsDBImport/{CHROMS}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_genomicsDBImport for {output.db}"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk GenomicsDBImport --java-options {params.maxmemory} \
        --genomicsdb-workspace-path {output.db} \
        -L chr{wildcards.CHROMS} \
        {params.gvcfs} \
        --reader-threads 1 \
        --batch-size 50 \
        --genomicsdb-shared-posixfs-optimizations true \
        --tmp-dir {params.tdir} &> {log}

        tar -cf {output.tar} {output.db}
        """