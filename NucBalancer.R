# --------------------------------------------------------------------------------
# Title:        NucBalancer
#
# Author:       Saurabh Gupta
# Affiliation:  Curtin University, Perth, Australia
# Email:        saurabh.gupta@curtin.edu.au
#
# License:      GPL-3.0
# -

library(optparse)

option_list <- list(
  make_option(c("-s", "--samples"), type="character", default=NULL, help="Sample file", metavar="character"),
  make_option(c("-b", "--barcodes"), type="character", default=NULL, help="Barcodes file", metavar="character"),
  make_option(c("-r", "--max_red_overall"), type="numeric", default=0, help="Maximum number of reds overall", metavar="numeric"),
  make_option(c("-p", "--max_red_per_position"), type="numeric", default=0, help="Maximum number of reds per position", metavar="numeric"),
  make_option(c("-o", "--outfile"), type="character", default=NULL, help="Output file", metavar="character"),
  make_option(c("-t", "--runtime"), type="numeric", default=1, help="Number of minutes to find the best combination", metavar="character")
)

# Parse command line arguments
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Check if all required arguments are provided
if (is.null(opt$samples) | is.null(opt$barcodes) | is.null(opt$outfile)) {
  print_help(opt_parser)
  stop("Required arguments are missing", call.=FALSE)
}

data_file = opt$samples
barcode_file = opt$barcodes
max_reds = opt$max_red_overall
max_reds_per_position = opt$max_red_per_position
outfile = opt$outfile
runtime = opt$runtime * 60

samples <- read.table(data_file, header=T, row.names=1, sep="\t")
barcodes <- read.table(barcode_file, row.names=1)
n_samples <- dim(samples)[1]

print("Processing data...")
################################
max_red = max_reds
max_red_per_position = max_reds_per_position
min_red_till_now = 80
min_red_per_position_till_now = 80
extra_barcodes = setdiff(rownames(barcodes), subset(samples, barcode!='-')$barcode)
extra_barcodes_num = sum(samples$barcode=='-')
colnames(barcodes) <- c("barcode_id")

print(paste0("Total number of samples: ", n_samples))
print(paste0("Number of barcodes: ", length(rownames(barcodes))))
print(paste0("QC: Total sample percentage: ", round(sum(samples$pct)*100), "%"))
print(paste0("Maximum red per table: ", max_red))
print(paste0("Runtime (in mins): ", runtime/60))

if(round(sum(samples$pct)*100) != 100){
	print(paste0("QC Failed: Total sample percentage != 100%"))
	print(paste0("Check Sample File, the sum of sample proportion column should be 1."))
	exit(1)
}

start_time = Sys.time()

count=1
while(TRUE) {
	if(count %% 10000 == 0) {
		print(paste0("Processed ", count, " combinations..."))
	}
	elapsed_time = as.numeric(Sys.time() - start_time, units="secs")
	count = count + 1
	list_barcodes = c()
	set.seed(count); list_barcodes_additional <- sample(extra_barcodes, extra_barcodes_num, replace=F)
	j=1
	for(i in 1:n_samples){
		if(samples[i,'barcode'] == '-'){
			list_barcodes[i] = list_barcodes_additional[j]
			j <- j + 1
		} else {
			list_barcodes[i] = samples[i,'barcode']
		}
	}
	df = data.frame(matrix(0, ncol=nchar(list_barcodes[1]), nrow=4))
	colnames(df) = paste0("p",seq(1,nchar(list_barcodes[1])))
	rownames(df) = c('A', 'T', 'C', 'G')
	for(i in 1:length(list_barcodes)){
		barcode = list_barcodes[i]
		bases = strsplit(barcode, split="")[[1]]
		for(pos in 1:length(bases)){
			base = bases[pos]
			df[base, paste0("p",pos)] = df[base, paste0("p",pos)] + samples[i,'pct']
		}
	}
			
	df1 = df < 0.125 | df > 0.625
	if((sum(df1=='TRUE') <= min_red_till_now) || ((sum(df1=='TRUE') <= min_red_till_now) && (max(colSums(df1)) < min_red_per_position_till_now))){
		min_red_till_now = sum(df1=='TRUE')
		min_red_per_position_till_now = max(colSums(df1))
	}
	if(((sum(df1	== 'TRUE') <= max_red) & (max(colSums(df1)) <= max_red_per_position) & (sum(df1 == 'TRUE') <= min_red_till_now)) | (elapsed_time > runtime)){
		if(elapsed_time > runtime){
			print("Maximum time reached!")
			print("Printing the best combination found till now. If the results are not optimal, consider re-running by increasing the time.")
		}
		print("####################################")
		df_out = cbind(samples, list_barcodes, barcodes[list_barcodes, "barcode_id"])
		colnames(df_out) = c("Percentage","barcode","barcode_id", "Barcode","Barcode_ID")
		df_out$Sample = rownames(df_out)
		df_out = df_out[,c("Sample", "Percentage", "barcode", "barcode_id","Barcode", "Barcode_ID")]
		df_out[df_out$barcode_id != "-",]$Barcode_ID = df_out[df_out$barcode_id != "-",]$barcode_id
		df_out = df_out[,c("Sample", "Percentage", "Barcode", "Barcode_ID")]
		print(paste0("Red flags found: ", sum(df1 == 'TRUE')))
				
		print(df_out)
		break
	}
	#print(elapsed_time)
	
	if(elapsed_time > runtime){
	  break
	}
}

################################
write.csv(df_out, outfile, row.names = FALSE)
