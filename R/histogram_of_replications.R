#' Histogram of replications for a selected KPI
#' 
#' @description
#' Accepts a table of replication results and a ggplot histogram object
#' for a selected column.
#' 
#' @param rep_table data.frame containing replications (rows) and KPIs (cols)
#' @param column_name string name of the KPI to plot
#' @param unit_label string of the x-axis label unit
#' @param n_bins number of bins for the histogram
#' 
#' @seealso [replication_results_table()] to create a table of replications
#' @returns plot
#' @importFrom ggplot2 ggplot geom_histogram xlab ylab aes
#' @importFrom dplyr select all_of
#' 
#' @export
histogram_of_replications <- function(rep_table, column_name, unit_label, n_bins=10){
  
  # check that rep table is at least a data.frame (format ignored)
  assertthat::assert_that(
    is.data.frame(rep_table) ,
    msg = "rep_table must be a data.frame."
  )
  
  # Divide the x range for selected column into n_bins
  binwidth <- diff(range(dplyr::select(rep_table, dplyr::all_of(column_name))))/n_bins
  
  g <- ggplot2::ggplot(rep_table, ggplot2::aes(.data[[column_name]])) +
    ggplot2::geom_histogram(binwidth = binwidth, fill="steelblue", colour = "black") + 
    ggplot2::xlab(paste(column_name, " (", unit_label, ")")) + 
    ggplot2::ylab("Replications")
  
  return(g)
}