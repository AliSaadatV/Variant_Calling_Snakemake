rule GenotypeGVCFs:
    input:
        db = "../results/genomicsDB/{CHROMS}.db"
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        "../results/genotypes/{CHROMS}.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],  
        ped = get_pedigree_command
    log:
        "logs/gatk_GenotypeGVCFs/{CHROMS}.log"
    benchmark:
        "benchmarks/gatk_GenotypeGVCFs/{CHROMS}.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Performing joint genotyping on one or more samples pre-called with HaplotypeCaller for {input.db}"
    shell:
        """
        gatk --java-options {params.maxmemory} \
        GenotypeGVCFs \
        -R {input.refgenome} \
        -O {output} \
        --only-output-calls-starting-in-intervals \
        --use-new-qual-calculator \
        -G StandardAnnotation -G AS_StandardAnnotation \
        -V gendb://{input.db} \
        {params.ped} \
        -L {wildcards.CHROMS} \
        --tmp-dir {params.tdir} &> {log}
        """
