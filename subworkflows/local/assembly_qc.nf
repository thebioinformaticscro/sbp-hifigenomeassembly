include { BIOAWK as ASSEMBLY_SIZE          } from '../../modules/nf-core/bioawk/main'
include { BIOAWK as COV_TABLE              } from '../../modules/nf-core/bioawk/main'
include { COV_TABLE_PLOT                   } from '../../modules/local/covtableplot'
include { BUSCO_BUSCO                      } from '../../modules/nf-core/busco/busco/main'
include { BUSCO_GENERATEPLOT               } from '../../modules/nf-core/busco/generateplot/main' 
include { QUAST                            } from '../../modules/nf-core/quast/main'
include { KAT_HIST                         } from '../../modules/nf-core/kat/hist/main' 

workflow ASSEMBLY_QC {

    take:
    
    ch_assembly_fasta    // channel: [ val(meta), path(fa.gz) ]
    ch_assembly_scaffold // channel: [ val(meta), path(fasta) ]
    ch_corrected_ref     // channel: [ val(meta), path(fasta) ]
    ch_samplesheet


    main:

    ch_versions = Channel.empty()
    ch_optional_input = Channel.of("/")
    ch_fasta_empty = ch_assembly_fasta.combine(ch_optional_input)
    ch_fastq = ch_samplesheet.map { meta, file, fasta -> [meta, file] }

    ASSEMBLY_SIZE ( ch_fasta_empty )
    ch_versions = ch_versions.mix(ASSEMBLY_SIZE.out.versions.first())

    ch_assembly_length_empty = ch_assembly_fasta.combine(ch_optional_input)

    COV_TABLE ( ch_assembly_length_empty )
    ch_versions = ch_versions.mix(COV_TABLE.out.versions.first())

    ch_assembly_length_fasta = COV_TABLE.out.csv.combine(ASSEMBLY_SIZE.out.csv, by:0)

    COV_TABLE_PLOT ( ch_assembly_length_fasta )
    ch_versions = ch_versions.mix(COV_TABLE_PLOT.out.versions.first())

    BUSCO_BUSCO ( 
        ch_assembly_fasta,
        params.busco_mode,
        params.busco_lineage,
        params.busco_lineages_path,
        params.busco_config
    )
    ch_versions = ch_versions.mix(BUSCO_BUSCO.out.versions.first())
    
    BUSCO_GENERATEPLOT ( BUSCO_BUSCO.out.short_summaries_txt )
    ch_versions = ch_versions.mix(BUSCO_GENERATEPLOT.out.versions.first())

    // ch_assembly_fasta.view()
    // ch_corrected_ref.view()
    //ch_assembly_scaffold.view()

    ch_assembly_fasta_renamed = ch_assembly_fasta.map { meta, path ->  
                                        meta = meta + [assembly:'contig']
                                        [meta, path]
                                        }
    
    ch_corrected_ref_contig = ch_corrected_ref.map { meta, path ->  
                                        meta = meta + [assembly:'contig']
                                        [meta, path]
                                        }

    ch_assembly_scaffold_renamed = ch_assembly_scaffold.map { meta, path ->  
                                        meta = meta + [assembly:'scaffold']
                                        [meta, path]
                                        }

    ch_corrected_ref_scaffold = ch_corrected_ref.map { meta, path ->  
                                        meta = meta + [assembly:'scaffold']
                                        [meta, path]
                                        }
    //ch_assembly_fasta_renamed.view()
    //ch_corrected_ref_contig.view()
    // ch_assembly_ref = ch_assembly_fasta_renamed.combine(ch_corrected_ref_contig,by:0)
    // ch_assembly_ref.view()
    ch_assembly_scaffold_renamed.view()
    //ch_corrected_ref_scaffold.view()
    // ch_scaffold_ref = ch_assembly_scaffold_renamed.combine(ch_corrected_ref_scaffold,by:0)
    // //ch_scaffold_ref.view()
    // ch_contigs_scaffold_ref = ch_assembly_ref.mix(ch_scaffold_ref)
    // //ch_contigs_scaffold_ref.view()

    // QUAST (
    //     ch_contigs_scaffold_ref,
    //     params.ref_gff
    // )
    // ch_versions = ch_versions.mix(QUAST.out.versions.first())

    ch_fastq = ch_fastq.map { meta, path ->  
                                        meta = meta + [type:'primary']
                                        [meta, path]
                                        }

    ch_fastq1 = ch_fastq.map { meta, path ->  
                                        meta = meta + [type:'hap1']
                                        [meta, path]
                                        }
    ch_fastq2 = ch_fastq.map { meta, path ->  
                                        meta = meta + [type:'hap2']
                                        [meta, path]
                                        }
    ch_both_fastqs = ch_fastq1.mix(ch_fastq2)

    if (params.primary_only) {
        ch_fastqs = ch_fastq
    } else {
        ch_fastqs = ch_both_fastqs
    }

    ch_assembly_fastq = ch_assembly_fasta.combine(ch_fastqs, by:0)

    KAT_HIST ( ch_assembly_fastq )
    ch_versions = ch_versions.mix(KAT_HIST.out.versions.first())

    emit:
    kat_plots               = KAT_HIST.out.png                     // channel: [ val(meta), path(png) ]
    kat_data                = KAT_HIST.out.json
    // quast_plots             = QUAST.out.results                    // channel: [ val(meta), path(directory) ]
    // quast_data              = QUAST.out.tsv 
    cov_plot                = COV_TABLE_PLOT.out.pdf               // channel: [ val(meta), path(pdf) ]
    busco_plot              = BUSCO_GENERATEPLOT.out.png           // channel: [ val(meta), path(png) ]
    busco_data              = BUSCO_BUSCO.out.short_summaries_txt
    versions                = ch_versions                          // channel: [ versions.yml ]
}

