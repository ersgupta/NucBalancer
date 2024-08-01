# NucBalancer

NucBalancer is a versatile tool designed to assist in optimizing nucleotide pooling strategies for high-throughput genomic analyses. The tool evaluates nucleotide distribution uniformity across positions and allows users to set customizable red flag thresholds, ensuring optimal results while accommodating variability.

## Background
Optical barcoding is a crucial technique in high-throughput sequencing, allowing for the pooling of multiple samples in a single sequencing run. One of the significant challenges in designing optical barcodes is base balancing, which is essential for ensuring accurate sequencing and minimizing biases.

Ensuring sufficient sequence diversity in barcodes is essential to avoid sequence homology, which can lead to misassignments. However, achieving base balancing within diverse sequences is a challenge. Barcodes must be designed to include all four nucleotides (A, T, C, G) in roughly equal proportions to maintain balanced sequencing runs, which helps prevent systematic errors and improves the accuracy of base calling.

For optical barcoding to work effectively, the barcodes must produce clear, detectable signals. This means ensuring that the base composition does not skew the optical signals. Unbalanced barcodes can lead to variability in signal intensity, making it harder for the sequencer to distinguish between different barcodes. This requires careful consideration of base balancing to maintain consistent signal strength and quality.

NucBalancer can accommodate any length of barcodes, including dual indices (to be mentioned as concatenated sequences).

Note: NucBalancer has been internally used to run upto 20 samples using set of 96 barcodes, and tested to run upto 50 samples using set of 96 barcodes. The code is not restricted by the number of samples so it can in principle handle large number of samples/barcodes.

## Features

- Evaluate and optimize nucleotide distribution in pooling configurations.
- Define red flag thresholds for the entire set and individual positions.
- Flexible parameter customization to match specific experimental needs.
- Identify potential bias-inducing deviations from desired nucleotide percentages.

## Getting Started

### Prerequisites

- R (>=v3.6)
- Required packages: [optparse](https://cran.r-project.org/web/packages/optparse/index.html)
- Required packages for installing shiny app locally: [shiny](https://cran.r-project.org/web/packages/shiny/index.html), [xtable](https://cran.r-project.org/web/packages/xtable/index.html)

### Installation
   ```bash
   git clone https://github.com/ersgupta/NucBalancer.git
   ```
### Install required packages
   ```bash
   install.packages("optparse")

   # Optional
   install.packages("shiny")
   install.packages("xtable")
   ```
### Usage
   ```bash
   Rscript NucBalancer.R -s <sample_file> -b <barcodes_file> -r <max_red_overall> -p <max_red_per_position> -o <outfile>
   ```
#### Command Line Arguments:
| Option | Description|
| ---|---|
| sample_file | Path to the samples information file|
| barcodes_file| Path to the list of barcodes available for selection|
| max_red_overall| Maximum number of *red* flags allowed for the entire set|
| max_red_per_position | Maximum number of *red* flags allowed per position|
| outfile | Output file name|

#### ShinyApp
Alternatively, NucBalancer is available at https://ersgupta.shinyapps.io/nucleotidebalancer/.

### File formats
* Sample information file (Tab-separated file with the following columns):
  - Sample_ID : sample name.
  - pct : Pooling proportion of the sample (total of this column should be 1).
  - barcode : Barcode sequence of the sample, if assigned already. If not assigned mention "-".
  - barcode_id : Barcode ID, if assigned already. If not assigned mention "-".
 
* Barcodes file (Tab-separated file):
  - barcode_sequence : Barcode sequence.
  - barcode_id : Barcode ID

## License
This project is licensed under GPL v3.0 License.

## Contact
For questions or feedback, feel free to reach out to saurabh.gupta@curtin.edu.au / ankur.sharma@garvan.org.au.
