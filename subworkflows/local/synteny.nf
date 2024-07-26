include { ALIGN_FOR_SYNTENY      } from '../../modules/local/alignforsynteny'
include { SYRI                   } from '../../modules/local/syri'

workflow SYNTENY {

    take:

    ch_samplesheet
    ch_assembly_scaffold // channel: [ val(meta), path(scaffold_fasta) ]
    ch_corrected_ref     // channel: [ path(fasta) ]

    main:
    ch_versions = Channel.empty()
    ch_scaffold_ref = ch_assembly_scaffold.combine(ch_corrected_ref)

    ALIGN_FOR_SYNTENY ( ch_scaffold_ref )
    ch_versions = ch_versions.mix(ALIGN_FOR_SYNTENY.out.versions.first())

    ch_synteny_scaffold = ALIGN_FOR_SYNTENY.out.sam.combine(ch_assembly_scaffold, by:0)
    //ch_synteny_scaffold.view()
    ch_synteny_scaffold_ref = ch_synteny_scaffold.combine(ch_corrected_ref)
    //ch_synteny_scaffold_ref.view()

    SYRI ( ch_synteny_scaffold_ref )
    ch_versions = ch_versions.mix(SYRI.out.versions.first())

    emit:
    synteny_plot      = SYRI.out.png           // channel: [ val(meta), path(png) ]
    versions          = ch_versions            // channel: [ versions.yml ]
}

