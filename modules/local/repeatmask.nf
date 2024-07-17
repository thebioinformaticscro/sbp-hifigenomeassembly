process REPEAT_MASK {
    tag "$meta.id"
    label 'process_high'

    input:
    tuple val(meta), path(scaffold)
    val(species)

    output:
    tuple val(meta), path("*.fa.masked"), emit: masked_fasta
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    RepeatMasker \\
    $args \\
    -species $species \\
    -s \\
    -parallel $task.cpus \\
    -xsmall \\
    -alignments $scaffold

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        repeatmask: \$(RepeatMasker --version)
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.fa.masked

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        repeatmask: \$(RepeatMasker --version)
    END_VERSIONS
    """
}
