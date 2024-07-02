include { BIOAWK as READ_LEN     } from '../../modules/nf-core/bioawk/main'
include { ASSEMBLY_STATS         } from '../../modules/local/assemblystats/main'
include { PLOT_READ_LEN          } from '../../modules/local/plotreadlen/main'


workflow HIFI_QC {

    take:
    
    ch_samplesheet // channel: [ val(meta), path(fastq.gz), path(ref.fasta) ]

    main:

    ch_fastq = ch_samplesheet.splitCSV ( header: true ).map { row -> tuple("${row.sample}", path("${row.fastq}")) }
    ch_fastq.view()

    ch_versions = Channel.empty()

    // READ_LEN ( ch_fastq )
    // ch_versions = ch_versions.mix(READ_LEN.out.versions.first())

    // ASSEMBLY_STATS ( ch_fastq )
    // ch_versions = ch_versions.mix(ASSEMBLY_STATS.out.versions.first())

    // PLOT_READ_LEN ( ASSEMBLY_STATS.out )


    // emit:
    // n50                = ASSEMBLY_STATS.out.n50           // channel: [ val(meta), path(txt) ]
    // read_len_plot      = PLOT_READ_LEN.out.read_len_plot  // channel: [ val(meta), path(png) ]

    versions           = ch_versions                      // channel: path(versions.yml)
}

