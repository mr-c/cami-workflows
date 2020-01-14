#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: metaspades.py

hints:
  DockerRequirement:
    dockerPull: ttubb/spades:latest

arguments:
  - valueFrom: "SPAdes-assembly"
    prefix: -o
    position: 0

inputs:
  illumina_paired_end_interspaced_reads:
    type: File
    inputBinding:
      position: 1
      prefix: --12        
  illumina_paired_end_forward_reads:
    type: File?
    inputBinding:
      position: 1
      prefix: --1
  illumina_paired_end_reverse_reads:
    type: File?
    inputBinding:
      position: 1
      prefix: --2
  nanopore_reads:
    type: File?
    inputBinding:
      position: 2
      prefix: --nanopore
  worker_threads:
    type: int?
    inputBinding:
      position: 3
      prefix: --threads
  memory:
    type: int?
    inputBinding:
      position: 3
      prefix: --memory

outputs:
  contigs:
    type: File
    outputBinding:
      glob: contigs.fasta
  scaffolds:
    type: File
    outputBinding:
      glob: scaffolds.fasta
  output_directory:
    type: Directory
    outputBinding:
      glob: .
  
