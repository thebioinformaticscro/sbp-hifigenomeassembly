process PREP_FASTAS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bioawk:1.0--h5bf99c6_6':
        'biocontainers/bioawk:1.0--h5bf99c6_6' }"

    input:
    tuple val(meta), path(scaffold)
    path(ref)
    path(chr_names)

    output:
    path("*ref.fasta")                        , emit: renamed_reference
    tuple val(meta), path("*scaffold.fasta")  , emit: renamed_scaffold
    path "versions.yml"                       , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args  = task.ext.args ?: '' // args is used for the main arguments of the tool
    prefix = task.ext.prefix ?: "${meta.id}"

    def VERSION = '1.0' // WARN: Version information not provided by tool on CLI. Please update this string when bumping container versions.
    """
    ref_name=\$(basename -s .fasta $ref)
    sed 's/_RagTag//' $scaffold > ${meta.id}_noragtag.scaffold.fasta
    for i in `cat $chr_names`; do
        cat $ref | bioawk -c fastx -v chr="\$i" '\$name==chr{print ">chr"\$name; print \$seq}' >> renamed_\${ref_name}.ref.fasta
        cat ${meta.id}_noragtag.scaffold.fasta | bioawk -c fastx -v chr="\$i" '\$name==chr{print ">"\$name; print \$seq}' >> renamed_${meta.id}.scaffold.fasta
    done
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bioawk: $VERSION
    END_VERSIONS
    """
}
