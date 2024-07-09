process ASSEMBLY_STATS {
    tag "$meta.id"
    label 'process_low'

    conda "bioconda::assembly-stats=1.0.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioawk:1.0--h5bf99c6_6':
        'biocontainers/bioawk:1.0--h5bf99c6_6' }"

    input:
    tuple val(meta), path(input)

    output:
    tuple val(meta), path("*.txt"), emit: txt
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: "${meta.id}"
    """
    zcat $input | assembly-stats > ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        assemblystats: \$(assembly-stats --version)
    END_VERSIONS
    """

    // stub:
    // def prefix = task.ext.prefix ?: "${meta.id}"

    // """
    // touch ${prefix}

    // cat <<-END_VERSIONS > versions.yml
    // "${task.process}":
    //     assemblystats: \$(assembly-stats --version)
    // END_VERSIONS
    // """
}
