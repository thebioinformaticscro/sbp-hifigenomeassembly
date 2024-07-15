include { ALIGN_FOR_SYNTENY      } from '../../modules/local/alignforsynteny'
include { SYRI                   } from '../../modules/local/syri'

workflow SYNTENY {

    take:

    ch_samplesheet
    ch_assembly_scaffold // channel: [ val(meta), path(scaffold_fasta) ]
   

    main:

    ch_ref = ch_samplesheet.map { meta, file, fasta -> [fasta] }
    ch_versions = Channel.empty()

    ALIGN_FOR_SYNTENY ( ch_assembly_scaffold,
                        ch_ref
    )
    ch_versions = ch_versions.mix(ALIGN_FOR_SYNTENY.out.versions.first())

    SYRI ( ALIGN_FOR_SYNTENY.out.sam,
           ch_ref,
           ch_assembly_scaffold
     )
    ch_versions = ch_versions.mix(SYRI.out.versions.first())

    // emit:
    // // TODO nf-core: edit emitted channels
    // bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    // bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    // csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    // versions = ch_versions                     // channel: [ versions.yml ]
}

