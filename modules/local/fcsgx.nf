process FCSGX {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    # container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    #    'https://docker.io/ncbi/fcs-gx:0.5.4' :
    #    'docker.io/ncbi/fcs-gx:0.5.4' }"
    container 'docker.io/ncbi/fcs-gx:0.5.4'

    input:
    tuple val(meta), path(assembly)
    val(gxdb)
    val(tax_id)

    output:
    tuple val(meta), path("*.cleaned.fasta")                        , emit: cleaned_assembly
    tuple val(meta), path("*.contam.fasta")                         , emit: contam_fasta
    tuple val(meta), path("*_gx_out/*.fcs_gx_report.txt")  , emit: contam_report
    path "versions.yml"                                             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.${meta.type}"
    def VERSION = '0.5.4' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    python3 /app/bin/run_gx \\
        --fasta $assembly \\
        --out-dir ./${prefix}_gx_out \\
        --gx-db $gxdb/all.gxi \\
        --tax-id $tax_id \\
        $args

    name=\$(basename $assembly .fa.gz)
    zcat $assembly > \$name.fasta
    /app/bin/gx clean-genome \\
        -i \$name.fasta \\
        --action-report ./${prefix}_gx_out/*.fcs_gx_report.txt \\
        --contam-fasta-out ${prefix}.contam.fasta \\
        --output ${prefix}.cleaned.fasta \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fcsgx: $VERSION
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.contam.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fcsgx: $VERSION
    END_VERSIONS
    """
}
