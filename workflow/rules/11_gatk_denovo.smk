rule denovo:
    input:
        refined_GQ_vcf = "../results/vcf/refined_GQ.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        protected("../results/vcf/refined_GQ_denovo.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        ped = get_pedigree_command
    log:
        "logs/gatk_GenotypeRefinement/denovo.log"
    benchmark:
        "benchmarks/gatk_GenotypeRefinement/denovo.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Possible denovo (logs and benchmark in gatk_GenotypeRefinement)"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk VariantAnnotator --java-options {params.maxmemory} \
        -R {input.refgenome} \
        -V {input.refined_GQ_vcf} \
        -A PossibleDeNovo \
        -O  {output} \
        {params.ped} \
        --tmp-dir {params.tdir} &> {log}
        """