process QUAST {
    tag "${meta.id}.${meta.type}.${meta.assembly}"
    label 'process_medium'
    debug true

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/quast:5.2.0--py39pl5321h2add14b_1' :
        'biocontainers/quast:5.2.0--py39pl5321h2add14b_1' }"
    containerOptions = "--user root"

    input:
    tuple val(meta) , path(consensus), path(ref)
    path(gff)

    output:
    tuple val(meta), path("${meta.id}.${meta.type}.${meta.assembly}_quast")           , emit: results
    tuple val(meta), path("${meta.id}.${meta.type}.${meta.assembly}_quast/report.tsv"), emit: tsv
    path "versions.yml"                                                               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args      = task.ext.args   ?: ''
    def prefix    = task.ext.prefix ?: "${meta.id}.${meta.type}.${meta.assembly}_quast"
    def features  = gff             ?  "--features $gff" : ''
    def reference = ref             ?  "-r $ref"       : ''
    """
    chmod 775 /usr/local/lib/python3.9/site-packages/quast_libs/
    if [[ "${meta.assembly}" == "contig" ]]; then
        echo "Option number 1"
        quast.py \\
            --output-dir $prefix \\
            $reference \\
            $features \\
            --threads $task.cpus \\
            --circos \\
            $args \\
            ${consensus.join(' ')}
    elif [[ "${meta.assembly}" == "scaffold" ]]; then
        echo "Option number 2"
        quast.py \\
            --output-dir $prefix \\
            --split-scaffolds \\
            $reference \\
            $features \\
            --threads $task.cpus \\
            --circos \\
            $args \\
            ${consensus.join(' ')}
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def args      = task.ext.args   ?: ''
    prefix        = task.ext.prefix ?: "${meta.id}"
    def features  = gff             ? "--features $gff" : ''
    def reference = ref           ? "-r $ref" : ''

    """
    mkdir -p $prefix
    touch $prefix/report.tsv
    touch $prefix/report.html
    touch $prefix/report.pdf
    touch $prefix/quast.log
    touch $prefix/transposed_report.txt
    touch $prefix/transposed_report.tex
    touch $prefix/icarus.html
    touch $prefix/report.tex
    touch $prefix/report.txt

    mkdir -p $prefix/basic_stats
    touch $prefix/basic_stats/cumulative_plot.pdf
    touch $prefix/basic_stats/Nx_plot.pdf
    touch $prefix/basic_stats/genome_GC_content_plot.pdf
    touch $prefix/basic_stats/GC_content_plot.pdf

    mkdir -p $prefix/icarus_viewers
    touch $prefix/icarus_viewers/contig_size_viewer.html

    ln -s $prefix/report.tsv ${prefix}.tsv

    if [ $ref ]; then
        touch $prefix/basic_stats/NGx_plot.pdf
        touch $prefix/basic_stats/gc.icarus.txt

        mkdir -p $prefix/aligned_stats
        touch $prefix/aligned_stats/NAx_plot.pdf
        touch $prefix/aligned_stats/NGAx_plot.pdf
        touch $prefix/aligned_stats/cumulative_plot.pdf

        mkdir -p $prefix/contigs_reports
        touch $prefix/contigs_reports/all_alignments_transcriptome.tsv
        touch $prefix/contigs_reports/contigs_report_transcriptome.mis_contigs.info
        touch $prefix/contigs_reports/contigs_report_transcriptome.stderr
        touch $prefix/contigs_reports/contigs_report_transcriptome.stdout
        touch $prefix/contigs_reports/contigs_report_transcriptome.unaligned.info
        mkdir -p $prefix/contigs_reports/minimap_output
        touch $prefix/contigs_reports/minimap_output/transcriptome.coords
        touch $prefix/contigs_reports/minimap_output/transcriptome.coords.filtered
        touch $prefix/contigs_reports/minimap_output/transcriptome.coords_tmp
        touch $prefix/contigs_reports/minimap_output/transcriptome.sf
        touch $prefix/contigs_reports/minimap_output/transcriptome.unaligned
        touch $prefix/contigs_reports/minimap_output/transcriptome.used_snps
        touch $prefix/contigs_reports/misassemblies_frcurve_plot.pdf
        touch $prefix/contigs_reports/misassemblies_plot.pdf
        touch $prefix/contigs_reports/misassemblies_report.tex
        touch $prefix/contigs_reports/misassemblies_report.tsv
        touch $prefix/contigs_reports/misassemblies_report.txt
        touch $prefix/contigs_reports/transcriptome.mis_contigs.fa
        touch $prefix/contigs_reports/transposed_report_misassemblies.tex
        touch $prefix/contigs_reports/transposed_report_misassemblies.tsv
        touch $prefix/contigs_reports/transposed_report_misassemblies.txt
        touch $prefix/contigs_reports/unaligned_report.tex
        touch $prefix/contigs_reports/unaligned_report.tsv
        touch $prefix/contigs_reports/unaligned_report.txt

        mkdir -p $prefix/genome_stats
        touch $prefix/genome_stats/genome_info.txt
        touch $prefix/genome_stats/transcriptome_gaps.txt
        touch $prefix/icarus_viewers/alignment_viewer.html

        ln -sf ${prefix}/contigs_reports/misassemblies_report.tsv ${prefix}_misassemblies.tsv
        ln -sf ${prefix}/contigs_reports/unaligned_report.tsv ${prefix}_unaligned.tsv
        ln -sf ${prefix}/contigs_reports/all_alignments_transcriptome.tsv ${prefix}_transcriptome.tsv

    fi

    if ([ $ref ] && [ $gff ]); then
        touch $prefix/genome_stats/features_cumulative_plot.pdf
        touch $prefix/genome_stats/features_frcurve_plot.pdf
    fi

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        quast: \$(quast.py --version 2>&1 | sed 's/^.*QUAST v//; s/ .*\$//')
    END_VERSIONS
    """
}
