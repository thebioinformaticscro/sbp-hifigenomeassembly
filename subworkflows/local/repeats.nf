include { REPEAT_MASK      } from '../../modules/local/repeatmask'
include { FIND_REPEATS     } from '../../modules/local/findrepeats'
include { FINAL_MASK       } from '../../modules/local/finalmask'

workflow REPEATS {

    take:

    ch_scaffold_fasta // channel: [ val(meta), path(scaffold_fasta) ]

    main:

    ch_versions = Channel.empty()

    REPEAT_MASK ( ch_scaffold_fasta,
                  params.species
    )
    ch_versions = ch_versions.mix(REPEAT_MASK.out.versions.first())

    FIND_REPEATS ( ch_scaffold_fasta )
    ch_versions = ch_versions.mix(FIND_REPEATS.out.versions.first())

    ch_masks = REPEAT_MASK.out.masked_fasta.combine(FIND_REPEATS.out.fa, by:0)

    FINAL_MASK ( ch_masks )
    ch_versions = ch_versions.mix(FINAL_MASK.out.versions.first())

    emit:
    masked_fasta      = FINAL_MASK.out.masked_fasta     // channel: [ val(meta), [ masked ] ]
    repeat_tbl        = FINAL_MASK.out.tbl              // channel: [ val(meta), [ tbl ] ]
    versions          = ch_versions                     // channel: [ versions.yml ]
}

