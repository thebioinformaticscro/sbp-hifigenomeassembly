process CALL_SV {
    tag "${meta.id}.${meta.type}"
    label 'process_low'

    conda "bioconda::samtools=1.20 bioconda::svim-asm=1.0.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/samtools_svim-asm:a44fd8f7773aae2f' :
        'community.wave.seqera.io/library/samtools_svim-asm:a44fd8f7773aae2f' }"

    input:
    tuple val(meta), path(bam), path(ref)


    output:
    tuple val(meta), path("*_svim_output/*.png"), emit: png
    tuple val(meta), path("*_svim_output/*.vcf"), emit: vcf
    tuple val(meta), path("*_svim_output")      , emit: svim_dir
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}.${meta.type}"
    """
    samtools \\
        index \\
        $bam
    svim-asm \\
        $args \\
        haploid \\
        ${prefix}_svim_output \\
        $bam \\
        $ref 

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        callsv: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}.bam

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        callsv: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
}
