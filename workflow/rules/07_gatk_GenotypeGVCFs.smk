rule GenotypeGVCFs:
    input:
        db = "../results/genomicsDB/{CHROMS}db",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        "../results/genotypes/{CHROMS}.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']), 
        tdir = config['TEMPDIR'],  
        ped = get_pedigree_command
    log:
        "logs/gatk_GenotypeGVCFs/{CHROMS}.log"
    benchmark:
        "benchmarks/gatk_GenotypeGVCFs/{CHROMS}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_GenotypeGVCFs for {input.db}"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk GenotypeGVCFs --java-options {params.maxmemory} \
        -R {input.refgenome} \
        -O {output} \
        --only-output-calls-starting-in-intervals \
        --use-new-qual-calculator \
        -V gendb://{input.db} \
        {params.ped} \
        -L chr{wildcards.CHROMS} \
        --tmp-dir {params.tdir} &> {log}
        """
