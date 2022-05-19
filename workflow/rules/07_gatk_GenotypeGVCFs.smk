rule GenotypeGVCFs:
    input:
        db = "../results/genomicsDB/{CHROMS}.db",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        "../results/genotypes/{CHROMS}.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],  
        ped = get_pedigree_command,
        partition = "serial"
    log:
        "logs/gatk_GenotypeGVCFs/{CHROMS}.log"
    benchmark:
        "benchmarks/gatk_GenotypeGVCFs/{CHROMS}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Performing joint genotyping on one or more samples pre-called with HaplotypeCaller for {input.db}"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk GenotypeGVCFs --java-options {params.maxmemory} \
        -R {input.refgenome} \
        -O {output} \
        --only-output-calls-starting-in-intervals \
        --use-new-qual-calculator \
        -G StandardAnnotation -G AS_StandardAnnotation \
        -V gendb://{input.db} \
        {params.ped} \
        -L chr{wildcards.CHROMS} \
        --tmp-dir {params.tdir} &> {log}
        """
