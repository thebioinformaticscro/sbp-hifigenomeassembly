include { RAGTAG                         } from '../../modules/local/ragtag'
include { PREP_FASTAS                    } from '../../modules/local/prepfastas'

workflow SCAFFOLD {

    take:
   
    ch_assembly_fasta          // channel: [ val(meta), path(fasta) ]
    ch_samplesheet             // channel: [ val(meta), path(fastq.gz), path(ref.fasta) ]
    ch_chr_names               // channel: [ path(chr_names) ]
    
    main:

    ch_ref = ch_samplesheet.map { meta, file, fasta -> [fasta] }
    ch_versions = Channel.empty()

    RAGTAG ( ch_assembly_fasta,
             ch_ref 
    )
    ch_versions = ch_versions.mix(RAGTAG.out.versions.first())

    PREP_FASTAS ( RAGTAG.out.fasta,
                  ch_ref,
                  ch_chr_names 
    )
    ch_versions = ch_versions.mix(PREP_FASTA.out.versions.first())

    // emit:
    // // TODO nf-core: edit emitted channels
    // bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    // bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    // csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    // versions = ch_versions                     // channel: [ versions.yml ]
}

