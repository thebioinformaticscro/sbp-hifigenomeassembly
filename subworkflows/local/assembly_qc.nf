include { COV_TABLE                        } from '../../modules/local/covtable'
include { COV_TABLE_PLOT                   } from '../../modules/local/covtableplot'
include { BUSCO_BUSCO                      } from '../../modules/nf-core/busco/busco/main'
include { BUSCO_GENERATEPLOT               } from '../../modules/nf-core/busco/generateplot/main' 

workflow ASSEMBLY_QC {

    take:
    
    ch_assembly_fasta // channel: [ val(meta), path(fasta) ]

    main:

    ch_versions = Channel.empty()

    COV_TABLE ( ch_assembly_fasta )
    ch_versions = ch_versions.mix(COV_TABLE.out.versions.first())

    COV_TABLE_PLOT ( COV_TABLE.out.cov )
    ch_versions = ch_versions.mix(COV_TABLE_PLOT.out.versions.first())

    BUSCO_BUSCO ( ch_assembly_fasta )
    ch_versions = ch_versions.mix(BUSCO_BUSCO.out.versions.first())

    BUSCO_GENERATEPLOT ( BUSCO_BUSCO.out.summary )
    ch_versions = ch_versions.mix(BUSCO_GENERATEPLOT.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

