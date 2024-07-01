include { ALIGN_FOR_SV      } from '../../modules/local/alignforsv'
include { CALL_SV      } from '../../modules/local/callsv'

workflow SV {

    take:

    ch_scaffold_fasta // channel: [ val(meta), path(scaffold_fasta) ]
    ch_ref            // channel: [ val(meta), path(ref_fasta)]

    main:

    ch_versions = Channel.empty()

    // TODO nf-core: substitute modules here for the modules of your subworkflow

    ALIGN_FOR_SV ( ch_scaffold_fasta,
                   ch_ref
    )
    ch_versions = ch_versions.mix(ALIGN_FOR_SV.out.versions.first())

    CALL_SV ( ALIGN_FOR_SV.out.bam,
              ch_ref 
    )
    ch_versions = ch_versions.mix(CALL_SV.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

