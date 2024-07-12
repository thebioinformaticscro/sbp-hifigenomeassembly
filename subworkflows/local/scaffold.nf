include { RAGTAG                        } from '../../modules/local/ragtag'
include { BIOAWK as PREP_FASTA          } from '../../modules/nf-core/bioawk/main'

workflow SCAFFOLD {

    take:
   
    ch_assembly_fasta          // channel: [ val(meta), path(fasta) ]
    ch_samplesheet             // channel: [ val(meta), path(fastq.gz), path(ref.fasta) ]
    ch_chr_names               // channel: [ path(chr_names) ]
    
    main:

    ch_ref = ch_samplesheet.map { meta, file, fasta -> [meta, fasta] }
    ch_versions = Channel.empty()

    RAGTAG ( ch_assembly_fasta,
             ch_ref 
    )
    ch_versions = ch_versions.mix(RAGTAG.out.versions.first())

    // PREP_FASTA ( RAGTAG.out.scaffold,
    //              ch_ref 
    // )
    // ch_versions = ch_versions.mix(PREP_FASTA.out.versions.first())

    // emit:
    // // TODO nf-core: edit emitted channels
    // bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    // bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    // csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    // versions = ch_versions                     // channel: [ versions.yml ]
}

