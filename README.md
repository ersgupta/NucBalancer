# NucBalancer

NucBalancer is a versatile tool designed to assist in optimizing nucleotide pooling strategies for high-throughput genomic analyses. The tool evaluates nucleotide distribution uniformity across positions and allows users to set customizable red flag thresholds, ensuring optimal results while accommodating variability.

## Features

- Evaluate and optimize nucleotide distribution in pooling configurations.
- Define red flag thresholds for the entire set and individual positions.
- Flexible parameter customization to match specific experimental needs.
- Identify potential bias-inducing deviations from desired nucleotide percentages.

## Getting Started

### Prerequisites

- R (>=v3.6)
- Required packages: [shiny](https://cran.r-project.org/web/packages/shiny/index.html), [xtable](https://cran.r-project.org/web/packages/xtable/index.html)

### Installation
   ```bash
   git clone https://github.com/ersgupta/NucBalancer.git
   ```
### Install required packages
   ```bash
   install.packages("shiny")
   install.packages("xtable")
   ```
### Usage
   ```bash
   Rscript NucBalancer.R <sample_file> <barcodes_file> <max_red_overall> <max_red_per_position> <outfile>
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
Alternatively, NucBalancer is available at XXXX.

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
For questions or feedback, feel free to reach out to saurabh.gupta@curtin.edu.au / ankur.sharma@curtin.edu.au.
