include { REPEAT_MASK      } from '../../modules/local/repeatmask'
include { FIND_REPEATS     } from '../../modules/local/findrepeats'
include { FINAL_MASK     } from '../../modules/local/finalmask'

workflow REPEATS {

    take:

    ch_scaffold_fasta // channel: [ val(meta), path(scaffold_fasta) ]

    main:

    ch_versions = Channel.empty()

    REPEAT_MASK ( ch_scaffold_fasta )
    ch_versions = ch_versions.mix(REPEAT_MASK.out.versions.first())

    FIND_REPEATS ( ch_scaffold_fasta )
    ch_versions = ch_versions.mix(FIND_REPEATS.out.versions.first())

    FINAL_MASK ( REPEAT_MASK.out.masked,
                 FIND_REPEATS.out.fasta
    )
    ch_versions = ch_versions.mix(FINAL_MASK.out.versions.first())

    emit:
    // TODO nf-core: edit emitted channels
    bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    versions = ch_versions                     // channel: [ versions.yml ]
}

