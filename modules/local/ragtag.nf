process RAGTAG {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::ragtag=2.1.0 bioconda::samtools=1.20"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/ragtag_samtools:de13f7e6599e59b4' :
        'community.wave.seqera.io/library/ragtag_samtools:de13f7e6599e59b4' }"

    input:
    tuple val(meta), path(assembly), path(ref)

    output:
    //tuple val(meta), path("*_ragtag_output/ragtag.scaffold.stats")    , emit: stats 
    tuple val(meta), path("*_ragtag_output/ragtag.scaffold.fasta")    , emit: fasta // change to ragtag.scaffold.fasta if scaffolding is final step
    tuple val(meta), path("*_ragtag_output/ragtag.scaffold.agp")      , emit: agp // hange to ragtag.scaffold.agp if scaffolding is final step
    tuple val(meta), path("*_ragtag_output")                          , emit: ragtag_dir
    path "versions.yml"                                               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    ragtag.py \\
        correct \\
        $args \\
        -t $task.cpus \\
        -o ${meta.id}.${meta.type}_ragtag_output \\
        $ref \\
        $assembly

    ragtag.py \\
        scaffold \\
        $args \\
        -t $task.cpus \\
        -o ${meta.id}.${meta.type}_ragtag_output \\
        $ref \\
        ${meta.id}.${meta.type}_ragtag_output/ragtag.correct.fasta

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
