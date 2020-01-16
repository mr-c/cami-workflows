#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: metaquast.py
label: Uses quast to assess an assembly.

hints:
  DockerRequirement:
    dockerPull: ttubb/quast:5.0.2
  SoftwareRequirement:
    packages:
      quast:
        specs: [ https://identifiers.org/RRID:SCR_001228 ]
        version: [ "5.0.2" ]

requirements:
  InlineJavascriptRequirement: {}

arguments:
  - valueFrom: $("metaquast-"+(inputs.jobname))
    position: 0
    prefix: --output-dir

inputs:
  jobname:
    label: Name of the job, used for naming the output directory.
    type: string
  assembly:
    label: Assembly which quast will assess.
    type: File
    inputBinding:
      position: 6
  reference_genomes:
    label: Directory containing reference genomes.
    type: Directory
    inputBinding:
      prefix: -r
      position: 1
  feature_coordinates:
    label: File with genomic feature coordinates in the reference (GFF, BED, NCBI or TXT) (optional).
    type: File?
    inputBinding:
      prefix: --features
      position: 2
  min_contig:
    label: Lower threshold for contig length (optional).
    type: int?
    inputBinding:
      prefix: --min-contig
      position: 3
  worker_threads:
    label: CPU-threads used by tool.
    type: int
    default: 1
    inputBinding:
      prefix: --threads
      position: 4

outputs:
  report_directory:
    type: Directory
    label: Directory containing all quast report data.
    outputBinding:
      glob: $("metaquast-"+(inputs.jobname))

s:author:
  - class: s:Person
    s:email: mailto:tom.tubb@googlemail.com
    s:name: Tom Tubbesing
s:dateCreated: "2019-05-16"
s:license: "https://spdx.org/licenses/GPL-3.0-or-later.html"

$namespaces:
  s: http://schema.org/
  edam: http://edamontology.org/

$schemas:
  - http://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.20.owl
