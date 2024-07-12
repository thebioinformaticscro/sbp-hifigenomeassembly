include { BIOAWK as ASSEMBLY_SIZE          } from '../../modules/nf-core/bioawk/main'
include { BIOAWK as COV_TABLE              } from '../../modules/nf-core/bioawk/main'
include { COV_TABLE_PLOT                   } from '../../modules/local/covtableplot'
include { BUSCO_BUSCO                      } from '../../modules/nf-core/busco/busco/main'
include { BUSCO_GENERATEPLOT               } from '../../modules/nf-core/busco/generateplot/main' 

workflow ASSEMBLY_QC {

    take:
    
    ch_assembly_fasta // channel: [ val(meta), path(fa.gz) ]

    main:

    ch_versions = Channel.empty()
    ch_optional_input = Channel.of("/")
    ch_fasta_empty = ch_assembly_fasta.combine(ch_optional_input)

    ASSEMBLY_SIZE ( ch_fasta_empty )
    ch_versions = ch_versions.mix(ASSEMBLY_SIZE.out.versions.first())

    ch_assembly_length_empty = ch_assembly_fasta.combine(ch_optional_input)

    COV_TABLE ( ch_assembly_length_empty )
    ch_versions = ch_versions.mix(COV_TABLE.out.versions.first())

    ch_assembly_length_fasta = COV_TABLE.out.csv.combine(ASSEMBLY_SIZE.out.csv, by:0)

    COV_TABLE_PLOT ( ch_assembly_length_fasta )
    ch_versions = ch_versions.mix(COV_TABLE_PLOT.out.versions.first())

    BUSCO_BUSCO ( 
        ch_assembly_fasta,
        params.busco_mode,
        params.busco_lineage,
        params.busco_lineages_path,
        params.busco_config
    )
    ch_versions = ch_versions.mix(BUSCO_BUSCO.out.versions.first())

    BUSCO_GENERATEPLOT ( BUSCO_BUSCO.out.short_summaries_txt )
    ch_versions = ch_versions.mix(BUSCO_GENERATEPLOT.out.versions.first())

    // emit:
    // // TODO nf-core: edit emitted channels
    // bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    // bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    // csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    // versions = ch_versions                     // channel: [ versions.yml ]
}

