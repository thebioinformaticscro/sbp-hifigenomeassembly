process RAGTAG {
    tag "$meta.id"
    label 'process_high'

    conda "bioconda::bioawk=1.0 bioconda::ragtag=2.1.0 bioconda::samtools=1.20"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/bioawk_ragtag_samtools:55562fd922507e03' :
        'community.wave.seqera.io/library/bioawk_ragtag_samtools:55562fd922507e03' }"

    input:
    tuple val(meta), path(assembly), path(ref)

    output:
    //tuple val(meta), path("*_ragtag_output/ragtag.scaffold.stats")  , emit: stats 
    tuple val(meta), path("*_ragtag_output/ragtag.patch.renamed.fasta"), emit: fasta // change to ragtag.scaffold.fasta if scaffolding is final step
    tuple val(meta), path("*_ragtag_output/ragtag.patch.agp")          , emit: agp // change to ragtag.scaffold.agp if scaffolding is final step
    tuple val(meta), path("*_ragtag_output")                           , emit: ragtag_dir
    path "versions.yml"                                                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    bioawk -c fastx '{print \$name "\t" length(\$seq)}' "${ref}" | grep "chr" > scaffold.lengths
    ragtag.py \\
        correct \\
        $args \\
        -t $task.cpus \\
        -o ${meta.id}.${meta.type}_ragtag_output \\
        $ref \\
        $assembly

    ragtag.py \\
        patch \\
        $args \\
        --aligner minimap2 \\
        -u \\
        -t $task.cpus \\
        -o ${meta.id}.${meta.type}_ragtag_output \\
        ${meta.id}.${meta.type}_ragtag_output/ragtag.correct.fasta \\
        $ref

    mv scaffold.lengths ${meta.id}.${meta.type}_ragtag_output/
    cd ${meta.id}.${meta.type}_ragtag_output/
    bioawk -c fastx '{print \$name "\t" length(\$seq)}' ragtag.patch.fasta > patch.lengths
    map_chrom_names.py scaffold.lengths patch.lengths
    awk 'FNR==NR { a[">"\$1]=\$2; next } \$1 in a { sub(/>.*/,">"a[\$1],\$1)}1' map_ids.txt ragtag.patch.fasta > ragtag.patch.renamed.fasta

    cd .. 
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
