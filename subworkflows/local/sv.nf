include { ALIGN_FOR_SV      } from '../../modules/local/alignforsv'
include { CALL_SV           } from '../../modules/local/callsv'

workflow SV {

    take:

    ch_assembly_scaffold        // channel: [ val(meta), path(scaffold_fasta) ]
    ch_corrected_ref            // channel: [ path(ref_fasta) ]

    main:

    ch_versions = Channel.empty()

    ALIGN_FOR_SV ( ch_assembly_scaffold,
                   ch_corrected_ref            // channel: [ path(ref_fasta) ]
    )
    ch_versions = ch_versions.mix(ALIGN_FOR_SV.out.versions.first())

    CALL_SV ( ALIGN_FOR_SV.out.bam,
              ch_corrected_ref 
    )
    ch_versions = ch_versions.mix(CALL_SV.out.versions.first())

    // emit:
    // bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    // bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    // csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    // versions = ch_versions                     // channel: [ versions.yml ]
}

