#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  worker_threads:
    type: int
  estimated_average_genome_size:
    type: int
  estimated_total_genome_size:
    type: int
  nanopore_reads:
    type: File
  illumina_interlaced_reads:
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
  assemble_w_canu:
    run: canuTool.cwl
    in:
    out:
  polish_canu_assembly_w_pilon:
    run: pilonWorkflow.cwl
    in:
    out:
  assemble_short_with_spades:
    run: metaSpadesTool.cwl
    in:
    out:
  assemble_hybrid_with_spades:
    run: metaSpadesTool.cwl
    in:
    out:
  assemble_w_flye:
    run: flyeTool.cwl
    in:
      nanopore_raw_reads: nanopore_reads
      metagenome: true
      estimated_genome_size: estimated_total_genome_size
    out: [draft_assembly, assembly, output_directory]
  polish_flye_assembly_w_pilon:
    run: pilonWorkflow.cwl
    in:
    out:
  assemble_w_miniasm:
    run: miniasmWorkflow.cwl
    in:
    out:
  polish_miniasm_assembly_w_pilon:
    run: pilonWorkflow.cwl
    in:
    out:

steps:
  
