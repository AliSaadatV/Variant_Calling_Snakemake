rule GatherVCF:
    input:
        expand("../results/genotypes/{chrom}.vcf.gz",chrom = CHROMS)
    output:
        file = "../results/vcf/all_raw.vcf.gz",
        index = "../results/vcf/all_raw.vcf.gz.tbi"
    params:
        vcfs = " -I ".join("../results/vcf/" + s + ".vcf.gz" for s in CHROMS),
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        "logs/gatk_GatherVCF/GatherVCF.log"
    benchmark:
        "benchmarks/gatk_GatherVCF/gatk_GatherVCF.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Gathering VCF for each chromosome"
    shell:
        """
        gatk --java-options {params.maxmemory} " \
        GatherVcfs \
        -I {params.vcfs} \
        -O {output.file} \
        --tmp-dir {params.tdir} &> {log}
        """