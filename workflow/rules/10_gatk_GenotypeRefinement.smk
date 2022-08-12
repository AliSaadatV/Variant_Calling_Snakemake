rule refinement:
    input:
        filtered_vcf = "../results/vcf/pass.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        gnomad = expand("{gnomad}", gnomad = config['GNOMAD'])
    output:
        refined = "../results/vcf/refined.vcf.gz",
        refined_GQ = protected("../results/vcf/refined_GQ.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        ped = get_pedigree_command
    log:
        posterior = "logs/gatk_GenotypeRefinement/posterior.log",
        GQ = "logs/gatk_GenotypeRefinement/GQ.log"
    benchmark:
        "benchmarks/gatk_GenotypeRefinement/refinement.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_GenotypeRefinement"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk CalculateGenotypePosteriors --java-options {params.maxmemory} \
        -V {input.filtered_vcf} \
        -O  {output.refined} \
        --supporting-callsets {input.gnomad} \
        --num-reference-samples-if-no-call 20314 \
        {params.ped} \
        --tmp-dir {params.tdir} &> {log.posterior}

        gatk VariantFiltration --java-options {params.maxmemory} \
        -R {input.refgenome} \
        -V {output.refined} \
        --genotype-filter-expression "GQ < 20" --genotype-filter-name "lowGQ" \
        --genotype-filter-expression "DP < 10" --genotype-filter-name "lowDP" \
        -O {output.refined_GQ} \
        --tmp-dir {params.tdir} &> {log.GQ}
        """