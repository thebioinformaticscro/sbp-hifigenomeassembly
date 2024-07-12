process RAGTAG {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/ragtag:2.1.0--0ad61b661719a8ae' :
        'community.wave.seqera.io/library/ragtag:2.1.0--0ad61b661719a8ae' }"

    input:
    tuple val(meta), path(assembly)
    path(ref)

    output:
    tuple val(meta), path("*.fasta"), emit: fasta
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ragtag.py \\
        scaffold \\
        $args \\
        -u \\
        -t $task.cpus \\
        -o ${prefix} \\
        $ref \\
        $assembly

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ragtag: \$(ragtag.py --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        ragtag: \$(ragtag.py --version)
    END_VERSIONS
    """
}
