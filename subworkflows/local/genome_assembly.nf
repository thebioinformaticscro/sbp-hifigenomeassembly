include { HIFIASM                        } from '../../modules/nf-core/hifiasm/main'
include { ASSEMBLY_STATS2 as TO_FASTA    } from '../../modules/local/assemblystats2'
include { FCS_FCSADAPTOR                 } from '../../modules/nf-core/fcs/fcsadaptor/main'  
include { FCS_FCSGX                      } from '../../modules/nf-core/fcs/fcsgx/main'
include { REMOVE_CONTAMINANTS            } from '../../modules/local/removecontaminants'
include { SIMPLIFY_HEADERS               } from '../../modules/local/simplifyheaders'


workflow GENOME_ASSEMBLY {

    take:
    
    ch_samplesheet // channel: [ val(meta), path(fastq.gz), path(ref.fasta) ]

    main:

    ch_fastq = ch_samplesheet.map { meta, file, fasta -> [meta, file] }
    ch_versions = Channel.empty()

    HIFIASM ( ch_fastq )
    ch_versions = ch_versions.mix(HIFIASM.out.versions.first())

    TO_FASTA ( HIFIASM.out.processed_contigs )
    ch_versions = ch_versions.mix(TO_FASTA.out.versions.first())

    FCS_FCSADAPTOR ( TO_FASTA.out.fasta )
    ch_versions = ch_versions.mix(FCS_FCSADAPTOR.out.versions.first())

    FCS_FCSGX ( FCS_FCSADAPTOR.out.cleaned_assembly )
    ch_versions = ch_versions.mix(FCS_FCSGX.out.versions.first())

    // REMOVE_CONTAMINANTS ( FCS_FCSADAPTOR.out.fasta, FCS_FCSGX.out.con_report )
    // ch_versions = ch_versions.mix(REMOVE_CONTAMINANTS.out.versions.first())

    // SIMPLIFY_HEADERS ( REMOVE_CONTAMINANTS.out )
    // ch_versions = ch_versions.mix(SIMPLIFY_HEADERS.out.versions.first())

    // emit:
    // // TODO nf-core: edit emitted channels
    // bam      = SAMTOOLS_SORT.out.bam           // channel: [ val(meta), [ bam ] ]
    // bai      = SAMTOOLS_INDEX.out.bai          // channel: [ val(meta), [ bai ] ]
    // csi      = SAMTOOLS_INDEX.out.csi          // channel: [ val(meta), [ csi ] ]

    // versions = ch_versions                     // channel: [ versions.yml ]
}

