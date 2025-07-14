# Load required packages
library(shiny)
library(viridis)
library(scales)
library(tidyverse)
library(openxlsx)
library(BIGr)
library(DT)

# Format percent helper
format_percent <- function(x) {
  percent_format(accuracy = 0.1)(x)
}

#### UI ####
ui <- fluidPage(
  tags$head(
    tags$style(HTML(".header-img img { max-width: 300px; margin-bottom: 10px; }"))
  ),
  
  div(class = "header-img", img(src = "logos.png", alt = "Logos")),
  titlePanel("Line/lineage content estimation"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("reference_file", "Reference Genotypes (.txt)", accept = ".txt"),
      fileInput("ref_ids_file", "Reference IDs (.txt)", accept = ".txt"),
      fileInput("validation_file", "Validation Genotypes (.txt)", accept = ".txt"),
      numericInput("ploidy", "Ploidy", value = 2, min = 1, max = 20, step = 1),
      actionButton("run", "Run Estimation"),
      br(), br(),
      downloadButton("download_results", "Download Excel Results")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Instructions",
                 fluidRow(
                   column(12, wellPanel(HTML('
              <ul>
                <li>This tool was developed by Breeding Insight.</li>
                <li>It estimates the proportion of each of the lines/groups included in the <strong>reference population</strong> from genotype samples using methods from 
                  <a href="https://www.animalsciencepublications.org/publications/tas/articles/1/1/36" target="_blank">Funkhouser et al. (2017)</a>.</li>
                <li><strong>Input format:</strong></li>
                <ul>
                  <li><strong>Reference Genotypes:</strong> A genotype matrix (.txt) with SNPs in rows and samples in columns. The first column must be <code>ID</code>.</li>
                  <li><strong>Reference IDs:</strong> A two-column .txt file with population labels. Header example: <code>Group1</code>, <code>Group2</code>.</li>
                  <li><strong>Validation Genotypes:</strong> Same format as the reference genotype file.</li>
                </ul>
              </ul>
            ')))
                 ),
                 fluidRow(
                   column(6, 
                          h4("Example Reference IDs"), 
                          tableOutput("example_ids"),
                          br(),
                          downloadButton("download_ids", "Download Sample Reference IDs")
                   ),
                   column(6, 
                          h4("Example Genotypes"), 
                          tableOutput("example_genos"),
                          br(),
                          downloadButton("download_genos", "Download Sample Genotypes")
                   )
                 )
        ),
        
        tabPanel("Results Table", DTOutput("preview")),
        tabPanel("Ancestry Plot", plotOutput("bar_plot"))
      ),
      verbatimTextOutput("status")
    )
  )
)

#### SERVER ####
server <- function(input, output, session) {
  result_data <- reactiveVal(NULL)
  result_filename <- reactiveVal(NULL)
  
  observeEvent(input$run, {
    req(input$reference_file, input$ref_ids_file, input$validation_file)
    output$status <- renderText("Running estimation...")
    
    tryCatch({
      reference <- read.table(input$reference_file$datapath, header = TRUE, sep = "\t") %>%
        distinct(ID, .keep_all = TRUE) %>%
        column_to_rownames("ID")
      
      reference_ids <- read.table(input$ref_ids_file$datapath, header = TRUE, sep = "\t")
      ref_ids <- lapply(as.list(reference_ids), as.character)
      
      validation <- read.table(input$validation_file$datapath, header = TRUE, sep = "\t") %>%
        distinct(ID, .keep_all = TRUE) %>%
        column_to_rownames("ID")
      
      freq <- BIGr:::allele_freq_poly(reference, ref_ids, ploidy = input$ploidy)
      prediction <- BIGr:::solve_composition_poly(validation, freq, ploidy = input$ploidy)
      
      prediction <- as.data.frame(prediction)
      prediction <- prediction[, !colnames(prediction) %in% c("R2")]
      prediction[] <- lapply(prediction, as.numeric)
      
      columns_to_select <- colnames(prediction)
      
      pred_results <- prediction %>%
        rownames_to_column(var = "ID") %>%
        mutate(
          across(all_of(columns_to_select), ~format_percent(.)),
          `Predicted line` = columns_to_select[max.col(select(., all_of(columns_to_select)), ties.method = "first")]
        )
      
      result_data(pred_results)
      
      filename <- paste0("lineage_estimation_", format(Sys.Date(), "%Y-%m-%d"), ".xlsx")
      temp_path <- file.path(tempdir(), filename)
      result_filename(temp_path)
      openxlsx::write.xlsx(pred_results, file = temp_path, rowNames = FALSE)
      
      output$preview <- DT::renderDataTable({
        DT::datatable(pred_results, options = list(pageLength = 10))
      })
      
      pred_results_long <- prediction %>%
        rownames_to_column(var = "ID") %>%
        pivot_longer(cols = all_of(columns_to_select), names_to = "category", values_to = "percent")
      
      output$bar_plot <- renderPlot({
        ggplot(pred_results_long, aes(x = ID, y = percent, fill = category)) +
          geom_bar(stat = "identity") +
          scale_fill_viridis_d(option = "D") +
          scale_y_continuous(labels = percent_format(accuracy = 1)) +
          labs(x = "Individual ID", y = "Ancestry Proportion", fill = "Line") +
          theme_minimal() +
          theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8))
      })
      
      output$status <- renderText("Estimation complete. File ready for download.")
      
    }, error = function(e) {
      output$status <- renderText(paste("Error during estimation:", e$message))
    })
  })
  
  output$download_results <- downloadHandler(
    filename = function() basename(result_filename()),
    content = function(file) file.copy(result_filename(), file)
  )
  
  # Sample reference IDs with >2 rows and variable length names
  example_ids_df <- data.frame(
    Group1 = c("SampleAlpha", "S3", "ExampleFour", "",""),
    Group2 = c("SampleOne", "SampleTwo", "SampleThree", "SampleFour", "SampleFive"),
    Group3 = c("SampleX", "SampleYy", "SampleZzzz", "ExampleEight", "")
  )
  
  output$example_ids <- renderTable({
    example_ids_df
  }, bordered = TRUE)
  
  # Sample genotype matrix matching your example
  example_genos_df <- data.frame(
    ID = paste0("Sample", c("1", "2", "3", "4", "5")),
    Marker1 = as.integer(c(0, 0, 1, 2, 1)),
    Marker2 = as.integer(c(0, 1, 0, 1, 2)),
    Marker3 = as.integer(c(0, 0, 0, 1, 1)),
    Marker4 = as.integer(c(0, 0, 0, 0, 0))
  )
  
  output$example_genos <- renderTable({
    example_genos_df
  }, bordered = TRUE)
  
  # Download handlers for sample files
  output$download_ids <- downloadHandler(
    filename = function() "sample_reference_ids.txt",
    content = function(file) {
      write.table(example_ids_df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )
  
  output$download_genos <- downloadHandler(
    filename = function() "sample_genotypes.txt",
    content = function(file) {
      write.table(example_genos_df, file, sep = "\t", row.names = FALSE, quote = FALSE)
    }
  )
}

#### Run the app ####
shinyApp(ui, server)