rule VQSR_snp:
    input:
        raw_vcf = "../results/vcf/all_raw.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        recal_snp = "../results/vqsr/snp.recal",
        tranches_snp = "../results/vqsr/snp.tranches"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        hapmap = config['HAPMAP'],
        omni = config['OMNI'],
        kg = config['KG'],
        dbsnp = config['dbSNP'],
        DP = get_vqsr_DP_option,
        InbreedingCoeff = get_vqsr_InbreedingCoefficient_option
    log:
        "logs/gatk_VQSR/VQSR_snp.log"
    benchmark:
        "benchmarks/gatk_VQSR/VQSR_snp.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_VQSR for SNPs"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk VariantRecalibrator --java-options {params.maxmemory} \
        -tranche 100.0 -tranche 99.95 -tranche 99.9 \
	    -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
	    -tranche 95.0 -tranche 94.0 \
        -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
        -R {input.refgenome} \
        -V {input.raw_vcf} \
        --trust-all-polymorphic \
        -AS \
        --resource:hapmap,known=false,training=true,truth=true,prior=15.0 \
        {params.hapmap} \
        --resource:omni,known=false,training=true,truth=false,prior=12.0 \
        {params.omni} \
        --resource:1000G,known=false,training=true,truth=false,prior=10.0 \
        {params.kg} \
        --resource dbsnp,known=true,training=false,truth=false,prior=2.0 \
        {params.dbsnp} \
        -an QD -an MQ -an MQRankSum -an ReadPosRankSum -an FS -an SOR {params.DP} {params.InbreedingCoeff} \
        -mode SNP \
        -O {output.recal_snp} \
        --tranches-file {output.trancesh_snp} \
        --tmp-dir {params.tdir} &> {log}
        """

rule VQSR_indel:
    input:
        raw_vcf = "../results/vcf/all_raw.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME'])
    output:
        recal_indel = "../results/vqsr/indel.recal",
        tranches_indel = "../results/vqsr/indel.tranches"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR'],
        mills = config['MILLS'],
        dbsnp = config['dbSNP'],
        axiom = config['AXIOM']
    log:
        "logs/gatk_VQSR/VQSR_indel.log"
    benchmark:
        "benchmarks/gatk_VQSR/VQSR_indel.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "gatk_VQSR for INDELs"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk VariantRecalibrator --java-options {params.maxmemory} \
        -tranche 100.0 -tranche 99.95 -tranche 99.9 \
        -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
        -tranche 95.0 -tranche 94.0 \
        -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
        --trust-all-polymorphic \
        -AS \
        -R {input.refgenome} \
        -V {input.raw_vcf} \
        --resource:mills,known=false,training=true,truth=true,prior=12.0 \
        {params.mills} \
        --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 \
        {params.dbsnp} \
        --resource:axiomPoly,known=false,training=true,truth=false,prior=10 \
        {params.axiom} \
	    -an QD -an MQRankSum -an ReadPosRankSum -an FS -an SOR \
        -mode INDEL \
        -O {output.recal_indel} \
        --tranches-file {output.tranches_indel} \
        --tmp-dir {params.tdir} &> {log}
        """

rule Apply_VQSR:
    input:
        raw_vcf = "../results/vcf/all_raw.vcf.gz",
        refgenome = expand("{refgenome}", refgenome = config['REFGENOME']),
        recal_indel = "../results/vqsr/indel.recal",
        tranches_indel = "../results/vqsr/indel.tranches",
        recal_snp = "../results/vqsr/snp.recal",
        tranches_snp = "../results/vqsr/snp.tranches"
    output:
        apply_snp = "../results/vqsr/apply_vqsr_snp.vcf.gz",
        apply_indel = "../results/vqsr/apply_vqsr_snp_indel.vcf.gz",
        select_pass = "../results/vcf/pass.vcf.gz"
    params:
        maxmemory = expand('"-Xmx{maxmemory}"', maxmemory = config['MAXMEMORY']['OTHER']),
        tdir = config['TEMPDIR']
    log:
        apply_vqsr_snp = "logs/gatk_VQSR/apply_VQSR_snp.log",
        apply_vqsr_indel = "logs/gatk_VQSR/apply_VQSR_indel.log",
        apply_vqsr_select = "logs/gatk_VQSR/apply_VQSR_select.log" 
    benchmark:
        "benchmarks/gatk_VQSR/apply_VQSR.tsv"
    conda:
        "../envs/gatk4.yaml"
    message:
        "Apply VQSR"
    resources: cpus=1, mem_mb=4000, time_min=1440, partition="serial"
    shell:
        """
        gatk ApplyVQSR --java-options {params.maxmemory} \
        -V {input.raw_vcf} \
        --recal-file {input.recal_snp} \
        -mode SNP \
        --tranches-file {input.tranches_snp} \
        --truth-sensitivity-filter-level 99.7 \
        --create-output-variant-index true \
        --tmp-dir {params.tdir} \
        -O {output.apply_snp} &> {log.apply_vqsr_snp}

        gatk ApplyVQSR --java-options {params.maxmemory} \
        -V {output.apply_snp} \
        --recal-file {input.recal_indel} \
        -mode INDEL \
        --tranches-file {input.tranches_indel} \
        --truth-sensitivity-filter-level 95 \
        --create-output-variant-index true \
        --tmp-dir {params.tdir} \
        -O {output.apply_indel}  &> {log.apply_vqsr_indel}

        gatk SelectVariants --java-options {params.maxmemory} \
        -R {input.refgenome} \
        -V {output.apply_indel} \
        -O {output.select_pass} \
        --exclude-filtered \
        --exclude-non-variants \
        --remove-unused-alternates \
        --tmp-dir {params.tdir} &> {log.apply_vqsr_select}
        """