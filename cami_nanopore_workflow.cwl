#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

requirements:
  InlineJavascriptRequirement: {}
  SubWorkflowFeatureRequirement: {}

inputs:
  worker_threads:
    type: int
  estimated_average_genome_size:
    type: int
  estimated_total_genome_size:
    type: int
  nanopore_reads:
    type: File
  illumina_interspaced_reads:
    type: File
  canu_redMemory:
    type: int?
  canu_oeaMemory:
    type: int?
  canu_batMemory:
    type: int?
  spades_memory:
    type: int?
  
outputs:
  canu:
    type: Directory
    outputSource: pool_canu/pool_directory
  canu_pilon:
    type: Directory
    outputSource: pool_canu_pilon/pool_directory
  spades_short:
    type: Directory
    outputSource: pool_spades_short/pool_directory
  spades_hybrid:
    type: Directory
    outputSource: pool_spades_hybrid/pool_directory
  flye:
    type: Directory
    outputSource: pool_flye/pool_directory
  flye_pilon:
    type: Directory
    outputSource: pool_flye_pilon/pool_directory
  miniasm:
    type: Directory
    outputSource: pool_miniasm/pool_directory
  miniasm_pilon:
    type: Directory
    outputSource: pool_miniasm_pilon/pool_directory

steps:
  assemble_w_canu:
    run: canuTool.cwl
    in:
      genomeSize: estimated_average_genome_size
      reads: nanopore_reads
      readMemory: canu_redMemory
      oeaMemory: canu_oeaMemory
      batMemory: canu_batMemory
    out: [output_directory, draft_assembly, contigs_read_layout, contigs_graph, unassembled, unitigs, unitigs_read_layout, unitigs_graph, report]
  assemble_short_with_spades:
    run: metaSpadesTool.cwl
    in:
      illumina_paired_end_interspaced_reads: illumina_interspaced_reads
      worker_threads: worker_threads
    out: [contigs, scaffolds, output_directory]
  assemble_hybrid_with_spades:
    run: metaSpadesTool.cwl
    in:
      illumina_paired_end_interspaced_reads: illumina_interspaced_reads
      nanopore_reads: nanopore_reads
      worker_threads: worker_threads
    out: [contigs, scaffolds, output_directory]
  assemble_w_flye:
    run: flyeTool.cwl
    in:
      nanopore_raw_reads: nanopore_reads
      metagenome: true
      estimated_genome_size: estimated_total_genome_size
    out: [draft_assembly, assembly, output_directory]
  assemble_w_miniasm:
    run: miniasmWorkflow.cwl
    in:
      reads: nanopore_reads
      worker_threads: worker_threads
    out: [assembly, unitigs_layout]
  polish_flye_assembly_w_pilon:
    run: pilonWorkflow.cwl
    in:
      worker_threads: worker_threads
      draft_genome: assemble_w_flye/assembly
      reads_interleaved: illumina_interspaced_reads
    out: [polished_assembly]
  polish_canu_assembly_w_pilon:
    run: pilonWorkflow.cwl
    in:
      worker_threads: worker_threads
      draft_genome: assemble_w_canu/draft_assembly
      reads_interleaved: illumina_interspaced_reads
    out: [polished_assembly]
  polish_miniasm_assembly_w_pilon:
    run: pilonWorkflow.cwl
    in:
      worker_threads: worker_threads
      draft_genome: assemble_w_miniasm/assembly
      reads_interleaved: illumina_interspaced_reads
a    out: [polished_assembly]
  pool_canu:
    run: poolingTool.cwl
    in:
      newname: "canu_assembly"
      directory_single: assemble_w_canu/canu_output
      file_single: assemble_w_canu/draft_assembly
    out: [pool_directory]
  pool_canu_pilon:
    run: poolingTool.cwl
    in:
      newname: "canu_assembly_polished_w_pilon"
      file_Single: polish_canu_assembly_w_pilon/polished_assembly
    out: [pool_directory]
  pool_spades_short:
    run: poolingTool.cwl
    in:
      newname: "spades_short_reads_assembly"
      directory_single: assemble_short_w_spades/output_directory
      file_single: assemble_short_w_spades/scaffolds
    out: [pool_directory]      
  pool_spades_hybrid:
    run: poolingTool.cwl
    in:
      newname: "spades_hybrid_assembly"
      directory_single: assemble_hybrid_w_spades/output_directory
      file_single: assemble_hybrid_w_spades/scaffolds
    out: [pool_directory]
  pool_flye:
    run: poolingTool.cwl
    in:
      newname: "flye_assembly"
      directory_single: assemble_w_flye/output_directory
      file_single: assemble_w_flye/assembly
    out: [pool_directory]
  pool_flye_pilon:
    run: poolingTool.cwl
    in:
      newname: "flye_assembly_polished_w_pilon"
      file_single: polish_flye_assembly_w_pilon/polished_assembly
    out: [pool_directory]
  pool_miniasm:
    run: poolingTool.cwl
    in:
      newname: "miniasm_assembly"
      file_array: [assemble_w_miniasm/assembly, assemble_w_miniasm/unitigs_layout]
    out: [pool_directory]
  pool_miniasm_pilon:
    run: poolingTool.cwl
    in:
      newname: "miniasm_assembly_polished_w_pilon"
      file_Single: polish_miniasm_assembly_w_pilon/polished_assembly
    out: [pool_directory]
  
