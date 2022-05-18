rule refinement:
    input:
        filtered_vcf = "../results/vcf/pass.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        gnomad = expand("{gnomad}", gnomad = config['GNOMAD'])
    output:
        refined = temp("../results/vcf/refined.vcf.gz")
        refined_GQ = "../results/vcf/refined_GQ.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR'],
        ped = get_pedigree_command
    log:
        posterior = "logs/refinement/posterior.log",
        GQ = "logs/refinement/GQ.log"
    benchmark:
        "benchmarks/refinement/refinement.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Genotype Refinement"
    shell:
        """
        gatk --java-options {params.maxmemory} \
        CalculateGenotypePosteriors \
        -V {input.filtered_vcf} \
        -O  {output.refined} \
        --supporting-callsets {input.gnomad} \
        --num-reference-samples-if-no-call 20314 \
        {params.ped} \
        --temp-dir {params.tdir} &> {log.posterior}

        gatk --java-options {params.maxmemory} VariantFiltration \
        -R {input.refgenome} \
        -V {output.refined} \
        --genotype-filter-expression "GQ < 20" --genotype-filter-name "lowGQ" \
        -O {output.refined_GQ} \
        --temp-dir {params.tdir} &> {log.GQ}
        """