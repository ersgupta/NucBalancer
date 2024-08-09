library(shiny)
library(xtable)

ui <- fluidPage(
	shinyjs::useShinyjs(),
	titlePanel("NucBalancer"),
	sidebarLayout(
		sidebarPanel(
			fileInput("data_file", "Upload Sample File (tsv)"),
			fileInput("barcode_file", "Upload Barcode File (tsv)"),
			sliderInput("max_reds_per_position", "Max Reds Per Position", min = 1, max = 4, value = 2),
			sliderInput("max_reds", "Max Reds Overall", min = 1, max = 80, value = 20),
			numericInput("runtime", "Runtime (in minutes)", min = 1, max = 60, value = 1),
			actionButton("load_example_data", "Load Example Data and Submit"),
			actionButton("submit_button", "Submit"),
			downloadButton("download_csv", "Download Table")
		),
		mainPanel(
			textOutput("text"),
			dataTableOutput("table")
		)
	)
)

server <- function(input, output, session) {
	data_processed <- reactiveVal(FALSE)
	filtered_data <- reactiveVal(NULL)
	
	observeEvent(input$load_example_data, {
	  ## example data
	  # Create the data frame
	  samples <- data.frame(
	    pct = c(0.1186, 0.0143, 0.0071, 0.0029, 0.1779, 0.0214, 0.0107, 0.0043, 0.1779, 0.0214, 0.0107, 0.0043, 0.1779, 0.0214, 0.0107, 0.0043, 0.1779, 0.0214, 0.0107, 0.0043),
	    barcode = c("-", "-", "-", "CCATTGTAAGTACGAATTGA", "-", "-", "-", "TAGTAGTTTGTCATCGGGCG", "-", "-", "-", "GATGGAAGGTAAATTGAGCA", "-", "-", "-", "ACAGGTTACGAGATAAACAG", "-", "-", "-", "AGTAGTTTGGATAGCATGCA"),
	    barcode_id = c("-", "-", "-", "pre_barcode1", "-", "-", "-", "pre_barcode2", "-", "-", "-", "pre_barcode3", "-", "-", "-", "pre_barcode4", "-", "-", "-", "pre_barcode5"),
	    row.names = c("Sample1", "Sample2", "Sample3", "Sample4", "Sample5", "Sample6", "Sample7", "Sample8", "Sample9", "Sample10", "Sample11", "Sample12", "Sample13", "Sample14", "Sample15", "Sample16", "Sample17", "Sample18", "Sample19", "Sample20"))
	  
	  # Create the data frame
	  barcodes <- data.frame(
	    barcode_id = c("barcode1","barcode2","barcode3","barcode4","barcode5","barcode6","barcode7","barcode8","barcode9","barcode10","barcode11","barcode12","barcode13","barcode14","barcode15","barcode16","barcode17","barcode18","barcode19","barcode20","barcode21","barcode22","barcode23","barcode24","barcode25","barcode26","barcode27","barcode28","barcode29","barcode30","barcode31","barcode32","barcode33","barcode34","barcode35","barcode36","barcode37","barcode38","barcode39","barcode40","barcode41","barcode42","barcode43","barcode44","barcode45","barcode46","barcode47","barcode48","barcode49","barcode50","barcode51","barcode52","barcode53","barcode54","barcode55","barcode56","barcode57","barcode58","barcode59","barcode60","barcode61","barcode62","barcode63","barcode64","barcode65","barcode66","barcode67","barcode68","barcode69","barcode70","barcode71","barcode72","barcode73","barcode74","barcode75","barcode76","barcode77","barcode78","barcode79","barcode80","barcode81","barcode82","barcode83","barcode84","barcode85","barcode86","barcode87","barcode88","barcode89","barcode90","barcode91","barcode92","barcode93","barcode94","barcode95","barcode96"),
	    row.names = c("GTAACATGCGAGTGTTACCT","GTGGATCAAAGCCAACCCTG","CACTACGAAATTAGACTGAT","CTCTAGCGAGTATCTTCATC","GTAGCCCTGTGAGCATCTAT","TAACGCGTGACCCTAACTTC","TCCCAAGGGTTACTACCTTT","CGAAGTATACGAACTTGGAG","AAGTGGAGAGTTCCTGTTAC","CGTGACATGCATGGTCTAAA","CGGAACCCAAGATTCGAGGA","CACCGCACCAGACTGTCAAT","ACAGTAACTAACAGTTCGTT","TCTACCATTTCGGGAGAGTC","CACGGTGAATGTTCGTCACA","GTAGACGAAACTAGTGTGGT","TCGGCTCTACCCGATGGTCT","AATGCCATGATACGTAATGC","GCCTTCGGTACCAACGATTT","GCACTGAGAATATGCGTGAA","TATTGAGGCACAGGTAAGTG","GCCCGATGGAAATCGTCTAG","TCTTACTTGCTGACCTCTAG","CGTCAAGGGCTAGGTCACTC","TGCGCGGTTTCAAGGATAAA","CAATCCCGACCCGAGTAGTA","ATGGCTTGTGGAATGTTGTG","TTCTCGATGATGTCGGGCAC","TCCGTTGGATACGTTCTCGC","ACGACTACCAACGACCCTAA","CGCGCACTTACCTGTATTCT","GCTACAAAGCCACGTGCCCT","TATCAGCCTAGTTTCGTCCT","AGAATGGTTTGAGGGTGGGA","ATGGGTGAAACTTGGGAATT","TCGTCAAGATGCAACTCAGG","TGCAATGTTCGCTTGTCGAA","TTAATACGCGCACCTCGGGT","CCTTCTAGAGAATACAACGA","GCAGTATAGGTTCCGTGCAC","TGGTTCGGGTGTGGCAGGAG","CCCAGCTTCTGACACCAAAC","CCTGTCAGGGAGCCCGTAAC","CGCTGAAATCAGGTGTCTGC","TGGTCCCAAGCCTCTGGCGT","ATGCGAATGGACAAGTGTCG","CGAATATTCGCTGGAAGCAA","GAATTGGTTAACTCTAGTAG","TTATTCGAGGCTGTCCTGCT","ATGGAGGGAGATAACCCATT","ACCAGACAACAGGAACTAGG","AACCACGCATATTCAGGTTA","CGCGGTAGGTCAGGATGTTG","TTGAGAGTCAAACCTGGTAG","GTCCTTCGGCTCATGCACAG","GAGCAAGGGCATTGACTTGG","TGTCCCAACGTCGATGTCCA","CACAATCCCAATATCCACAA","TCCGGGACAAGTGAATGCCA","CGTCCACCTGCATTCATGAC","AAGATTGGATAGCGGGATTT","AAGGGCCGCACTGATTCCTC","GAGAGGATATTTGAAATGGG","CCCACCACAAACCTCCGCTT","CGGCTGGATGTGATAAGCAC","TTGCCCGTGCGCGTGAGATT","AATGTATCCAAATGAGCTTA","CTCCTTTAGAGACATAGCTC","GTCCCATCAACGAACGTGAC","CCGGCAACTGCGGTTTAACA","TTCACACCTTTAGTGTACAC","GAGACGCACGCTATGAACAT","TGTAGTCATTCTTGATCGTA","CATGTGGGTTGATTCCTTTA","ATGACGTCGCAGGTCAGGAT","GCGCTTATGGGCCTGGCTAG","ATAGGGCGAGTGCATCGAGT","GCGGGTAAGTTAGCACTAAG","GTTTCACGATTTCGGCCAAA","TAAGCAACTGCTATACTCAA","CCGGAGGAAGTGCGGATGTT","ACTTTACGTGTGAACGCCCT","GATAACCTGCCATTAGAAAC","CTTGCATAAAATCAGGGCTT","ACAATGTGAACGTACCGTTA","TAGCATAGTGCGGCTCTGTC","CCCGTTCTCGGACGGATTGG","AGTTTCCTGGTGCCACACAG","AGCAAGAAGCTTGTGTTTCT","CCTATCCTCGGAATACTAAC","ACCTCGAGCTTGTGTTCGAT","ATAAGGATACATAGATAGGG","AGAACTTAGACGAGTCCTTT","TTATCTAGGGAAAGGCTCTA","ACAATCGATCTGACGGAATG","TGATGATTCAGTAGGAGTCG")
	  )
	  
	  shinyjs::html(id = "text", html = paste0("Example data loaded...<br>"), add = F)
	  #shinyjs::html(id = "text", html = paste0("Set the parameters and click <b>Submit</b>!<br>"), add = T)
	  process_data(samples, barcodes)
	})
	
	observeEvent(input$submit_button, {
	messages <- reactiveVal(character(0))
		req(input$data_file, input$barcode_file)
		if(!exists("samples")){
		  samples <- read.table(input$data_file$datapath, header=T, row.names=1, sep="\t")
		  barcodes <- read.table(input$barcode_file$datapath, row.names=1)  
		}else{
		}
		
		process_data(samples, barcodes)
	})
		
	process_data <- function(samples, barcodes){
		n_samples <- dim(samples)[1]
		runtime <- input$runtime
		shinyjs::html(id = "text", html = paste0("Processing data...<br>"), add = F)

		# Display the data frame
		print(data)
		
		################################
		max_red = input$max_reds
		max_red_per_position = input$max_reds_per_position
		min_red_till_now = 80
		min_red_per_position_till_now = 80
		extra_barcodes = setdiff(rownames(barcodes), subset(samples, barcode!='-')$barcode)
		extra_barcodes_num = sum(samples$barcode=='-')
		colnames(barcodes) <- c("barcode_id")
		shinyjs::html(id = "text", html = paste0("Total number of samples: ", n_samples, "<br>"), add = TRUE)
		shinyjs::html(id = "text", html = paste0("Number of barcodes: ", length(rownames(barcodes)), "<br>"), add=TRUE)
		shinyjs::html(id = "text", html = paste0("QC: Total sample percentage: ", round(sum(samples$pct)*100), "%", "<br>"), add=TRUE)
		shinyjs::html(id = "text", html = paste0("Maximum red per table: ", max_red, "<br>"), add=TRUE)
		shinyjs::html(id = "text", html = paste0("Runtime (in mins): ", runtime, "<br>"), add=TRUE)
		
	if(round(sum(samples$pct)*100) != 100){
		shinyjs::html(id = "text", html = paste0("QC Failed: Total sample percentage != 100%<br>"), add=TRUE)
		shinyjs::html(id = "text", html = paste0("Check Sample File, the sum of sample proportion column should be 1.<br>"), add=TRUE)
		exit(1)
	}	else if(dim(samples)[1] == 0 | dim(barcodes)[1] == 0){
	  shinyjs::html(id = "text", html = paste0("No samples or barcodes found!<br>"), add=TRUE)
	  shinyjs::html(id = "text", html = paste0("Check Sample and Barcodes files<br>"), add=TRUE)
	  exit(1)
	}
		

		start_time = Sys.time()
		runtime = runtime * 60
		  
		count=1
		while(TRUE) {
			if(count %% 10000 == 0) {
				shinyjs::html(id = "text", html = paste0("Processed ", count, " combinations...<br>"), add=TRUE)
			}
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
			if((sum(df1	== 'TRUE') <= max_red) & (max(colSums(df1)) <= max_red_per_position) & (sum(df1 == 'TRUE') <= min_red_till_now)){
				shinyjs::html(id = "text", html = paste0("####################################<br>"), add=TRUE)
				df_out = cbind(samples, list_barcodes, barcodes[list_barcodes, "barcode_id"])
				colnames(df_out) = c("Percentage","barcode","barcode_id", "Barcode","Barcode_ID")
				df_out$Sample = rownames(df_out)
				df_out = df_out[,c("Sample", "Percentage", "barcode", "barcode_id","Barcode", "Barcode_ID")]
				df_out[df_out$barcode_id != "-",]$Barcode_ID = df_out[df_out$barcode_id != "-",]$barcode_id
				df_out = df_out[,c("Sample", "Percentage", "Barcode", "Barcode_ID")]
				shinyjs::html(id = "text", html = paste0("Red flags found: ", sum(df1 == 'TRUE'), "<br><br>"), add=TRUE)
				
				df_print = print(xtable(df1, align=paste(rep("c",nchar(list_barcodes[1])+1), collapse = "")), type='html')
				df_print= gsub("TRUE", '<span style="color: red;">T</span>', df_print)
				df_print= gsub("FALSE", '<span style="color: green;">F</span>', df_print)
				shinyjs::html(id = "text", html = paste0(df_print,"<br>"), add=TRUE)
				shinyjs::html(id = "text", html = print(xtable(df_out[,-c(1)], include.rownames=F), type="html"), add=T)

				filtered_data(df_out)
				data_processed(TRUE)
				break
			}
		
			elapsed_time = as.numeric(Sys.time() - start_time, units="secs")
			
			if(elapsed_time > runtime){
			  
			  shinyjs::html(id = "text", html = paste0("Maximum runtime reached!<br>"), add=TRUE)
			  shinyjs::html(id = "text", html = paste0("If the set of barcodes is not optimal, considering re-running with increased time.<br>"), add=TRUE)
			  min_red_till_now = sum(df1=='TRUE')
			  min_red_per_position_till_now = max(colSums(df1))
			  
			  shinyjs::html(id = "text", html = paste0("####################################<br>"), add=TRUE)
			  df_out = cbind(samples, list_barcodes, barcodes[list_barcodes, "barcode_id"])
			  colnames(df_out) = c("Percentage","barcode","barcode_id", "Barcode","Barcode_ID")
			  df_out$Sample = rownames(df_out)
			  df_out = df_out[,c("Sample", "Percentage", "barcode", "barcode_id","Barcode", "Barcode_ID")]
			  df_out[df_out$barcode_id != "-",]$Barcode_ID = df_out[df_out$barcode_id != "-",]$barcode_id
			  df_out = df_out[,c("Sample", "Percentage", "Barcode", "Barcode_ID")]
			  shinyjs::html(id = "text", html = paste0("Red flags found: ", sum(df1 == 'TRUE'), "<br><br>"), add=TRUE)
			  
			  df_print = print(xtable(df1, align=paste(rep("c",nchar(list_barcodes[1])+1), collapse = "")), type='html')
			  df_print= gsub("TRUE", '<span style="color: red;">T</span>', df_print)
			  df_print= gsub("FALSE", '<span style="color: green;">F</span>', df_print)
			  shinyjs::html(id = "text", html = paste0(df_print,"<br>"), add=TRUE)
			  shinyjs::html(id = "text", html = print(xtable(df_out[,-c(1)], include.rownames=F), type="html"), add=T)
			  
			  filtered_data(df_out)
			  data_processed(TRUE)
			  
			  break
			}
			
		}
	}
	################################
	output$text <- renderPrint({
		shinyjs::html("text", "<br>")
	})
	
	output$table <- renderDataTable({
		if (data_processed()){
			filtered_data()
		}
	})
	
	output$download_csv <- downloadHandler(
		filename = function() {
			paste0("filtered_data_", Sys.Date(), ".csv")
		},
		content = function(file) {
			if (data_processed()) {
				write.csv(filtered_data(), file, row.names = FALSE)
			}
		}
	)
}
# Run the application 
shinyApp(ui = ui, server = server)
