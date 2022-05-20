rule denovo:
    input:
        refined_GQ_vcf = "../results/vcf/refined_GQ.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        "../results/vcf/refined_GQ_denovo.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
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
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk VariantAnnotator --java-options {params.maxmemory} \
        -R {input.refgenome} \
        -V {input.refined_GQ_vcf} \
        -O  {output} \
        {params.ped} \
        --tmp-dir {params.tdir} &> {log}
        """