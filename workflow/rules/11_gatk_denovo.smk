rule denovo:
    input:
        refined_GQ_vcf = "../results/vcf/refined_GQ.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        "../results/vcf/refined_GQ_denovo.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        ped = get_pedigree_command
    log:
        "logs/refinement/denovo.log"
    benchmark:
        "benchmarks/refinement/denovo.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Possible denovo"
    shell:
        """
        gatk --java-options {params.maxmemory} \
        VariantAnnotator \
        -R {input.refgenome} \
        -V {input.refined_GQ_vcf} \
        -O  {output} \
        {params.ped} \
        --temp-dir {params.tdir} &> {log}
        """