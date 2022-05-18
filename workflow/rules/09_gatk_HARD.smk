rule hard_snp:
    input:
        raw_vcf = "../results/vcf/all_raw.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        snp_raw = temp("../results/hard/snp_raw.vcf.gz"),
        snp_filtered = temp("../results/hard/snp_filtered.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        select = "logs/hard/hard_snp_select.log",
        filter = "logs/hard/hard_snp_filter.log"
    benchmark:
        "benchmarks/hard/hard_snp.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Running hard filter snp"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk SelectVariants \
        -R {input.refgenome} \
        -V {input.raw_vcf} \
        -select-type SNP \
        -O {output.snp_raw} \
        --temp-dir {params.tdir} &> {log.select}

        gatk VariantFiltration \
        -R {input.refgenome} \
        -V {output.snp_raw} \
        --filter-expression "QD < 2.0" --filter-name "QD_lt_2" \
        --filter-expression "FS > 60.0" --filter-name "FS_gt_60" \
        --filter-expression "MQ < 40.0" --filter-name "MQ_lt_40" \
        --filter-expression "MQRankSum < -12.5" --filter-name "MQRS_lt_n12.5" \
        --filter-expression "ReadPosRankSum < -8.0" --filter-name "RPRS_lt_n8" \
        --filter-expression "SOR > 3.0" --filter-name "SOR_gt_3" \
        --filter-expression "QUAL < 30.0" --filter-name "QUAL30" \
        -O {output.snp_filtered} \
        --temp-dir {params.tdir} &> {log.filter}
        """

rule hard_indel:
    input:
        raw_vcf = "../results/vcf/all_raw.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        snp_raw = temp("../results/hard/indel_raw.vcf.gz"),
        snp_filtered = temp("../results/hard/indel_filtered.vcf.gz")
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        select = "logs/hard/hard_indel_select.log",
        filter = "logs/hard/hard_indel_filter.log"
    benchmark:
        "benchmarks/hard/hard_indel.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Running hard filter indel"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk SelectVariants \
        -R {input.refgenome} \
        -V {input.raw_vcf} \
        -select-type INDEL \
        -select-type MIXED \
        -O {output.indel_raw} \
        --temp-dir {params.tdir} &> {log.select}

        gatk VariantFiltration \
        -R {input.refgenome} \
        -V {output.indel_raw} \
        --filter-expression "QD < 2.0" --filter-name "QD_lt_2" \
        --filter-expression "FS > 200.0" --filter-name "FS_gt_200" \
        --filter-expression "ReadPosRankSum < -20.0" --filter-name "RPRS_lt_n20" \
        --filter-expression "SOR > 10.0" --filter-name "SOR_gt_10" \
        --filter-expression "QUAL < 30.0" --filter-name "QUAL30" \
        -O {output.indel_filtered} \
        --temp-dir {params.tdir} &> {log.filter}
        """

rule merge_filtered:
    input:
        snp_filtered = "../results/hard/snp_filtered.vcf.gz",
        indel_filtered = "../results/hard/indel_filtered.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        merged_total = "../results/hard/merged.vcf.gz",
        merged_pass = "../results/vcf/pass.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']),
        tdir = config['TEMPDIR']
    log:
        merge = "logs/hard/merge.log",
        select = "logs/hard/select.log" 
    benchmark:
        "benchmarks/hard/merge.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Running hard filter indel"
    resources: cpus=1, mem_mb=4000, time_min=1440
    shell:
        """
        gatk MergeVcfs \
        -I {input.snp_filtered} \
        -I {input.indel_filtered} \
        -O {output.merged_total} \
        --temp-dir {params.tdir} &> {log.merge}

        gatk SelectVariants \
        -R {input.refgenome} \
        -V {output.merged_total} \
        -O {output.merged_pass} \
        --exclude-filtered \
        --temp-dir {params.tdir} &> {log.select}
        """