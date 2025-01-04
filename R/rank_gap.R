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