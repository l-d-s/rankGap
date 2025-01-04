#' Compute rank-gap statistics from input scores
#' 
#' @export
#' 
#' @param ... ≥2 vectors of input scores. These should all have the same length. (Missing values?)
#' @param ties_method Method of breaking ties; passed to `rank()`
#' @param nonzero_adj Whether to adjust ranks to avoid zero values of rank-gap statistics
#' 
#' @return A vector of rank-gap statistics, the same length as the input scores
rank_gap <- function(..., ties_method = "random", nonzero_adj = TRUE) {
  stats_list <- list(...)
  n_stats    <- length(stats_list)
  rank_list  <- lapply(stats_list, (\(x) rank(x, ties.method = ties_method)))
  rank_min   <- do.call(pmin, rank_list)
  rank_max   <- do.call(pmax, rank_list)
  r_gap_raw  <- ((rank_max - rank_min) + nonzero_adj * 0.5) / 
    (rank_max + nonzero_adj)
  r_gap      <- r_gap_raw ** (n_stats - 1)
  return(r_gap)
}