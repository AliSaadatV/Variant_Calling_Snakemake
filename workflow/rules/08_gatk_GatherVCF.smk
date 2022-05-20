rule GatherVCF:
    input:
        expand("../results/genotypes/{chrom}.vcf.gz",chrom = CHROMS)
    output:
        file = "../results/vcf/all_raw.vcf.gz",
        index = "../results/vcf/all_raw.vcf.gz.tbi"
    params:
        vcfs = " -I ".join("../results/genotypes/" + s + ".vcf.gz" for s in CHROMS),
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        partition = "serial"
    log:
        "logs/gatk_GatherVCF/GatherVCF.log"
    benchmark:
        "benchmarks/gatk_GatherVCF/gatk_GatherVCF.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Gathering VCF for each chromosome"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk GatherVcfs --java-options {params.maxmemory} \
        -I {params.vcfs} \
        -O {output.file} \
        --TMP_DIR {params.tdir} &> {log}
        """