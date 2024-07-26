include { ALIGN_FOR_SV      } from '../../modules/local/alignforsv'
include { CALL_SV           } from '../../modules/local/callsv'

workflow SV {

    take:

    ch_assembly_scaffold        // channel: [ val(meta), path(scaffold_fasta) ]
    ch_corrected_ref            // channel: [ path(ref_fasta) ]

    main:

    ch_versions = Channel.empty()
    ch_scaffold_ref = ch_assembly_scaffold.combine(ch_corrected_ref)

    ALIGN_FOR_SV ( ch_scaffold_ref )          // channel: [ path(ref_fasta) ]
    ch_versions = ch_versions.mix(ALIGN_FOR_SV.out.versions.first())

    ch_sv_bam_ref = ALIGN_FOR_SV.out.bam.combine(ch_corrected_ref)
    //ch_sv_bam_ref.view()
    CALL_SV ( ch_sv_bam_ref )
    ch_versions = ch_versions.mix(CALL_SV.out.versions.first())

    emit:
    sv_calls     = CALL_SV.out.vcf          // channel: [ val(meta), [ vcf ] ]
    sv_plot      = CALL_SV.out.png          // channel: [ val(meta), [ png ] ]
    versions     = ch_versions              // channel: [ versions.yml ]
}

