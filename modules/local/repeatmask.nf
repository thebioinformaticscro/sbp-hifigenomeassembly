process REPEAT_MASK {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::repeatmasker=4.1.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://hub.docker.com/r/dfam/tetools:1.88.5--e0b4778820d8':
        'hub.docker.com/r/dfam/tetools:1.88.5--e0b4778820d8' }"

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
