#' Compute rank-gap statistics from input scores
#'
#' @export
#'
#' @param ... ≥2 vectors of input scores. These should all have the same length. 
#' (Missing values?)
#' @param ties_method Method of breaking ties; passed to `rank()`
#' @param nonzero_adj Whether to adjust ranks to avoid zero values of rank-gap 
#' statistics
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

### Signs and concordances #####################################

signs_mat_from_vecs <- function(vec_list) {
  m <- (do.call(cbind, vec_list)) |> sign()
  # Sign matrix
  # Randomly break ties for 0s—not sure what's best here
  m_ <- ifelse(m == 0, sample(c(-1, 1), length(m), replace = TRUE), m) 
  return(m_)
}

#' Compute a vector of signs from a collection of vector inputs
#'
#' @export
#'
#' @param ... ≥2 vectors of numeric input scores. These should all have the same
#' length. (Missing values?)
#' @return A character vector summarizing the signs of the inputs (Missing 
#' values?)
signs_pm <- function(...) {
  m <- signs_mat_from_vecs(list(...))
  # Plusses and minuses
  pm <- matrix(c("-", NA, "+")[m + 2], dim(m))
  # Flatten to string
  pm_str <- apply(pm, 1, (\(x) paste0(x, collapse = "")))
  return(pm_str)
}

#' Compute a vector of concordances from a collection of vector inputs
#'
#' @export
#'
#' @param ... ≥2 vectors of input scores. These should all have the same length.
#' (Missing values?)
#' @return A character vector summarizing the "concordances" of the inputs,
#' which are defined as the signs up to exchanging `-` and `+` and are denoted
#' using vertical bars and dashes (so that e.g. `++-` and `--+` yeild 
#' concordance `||-`) (Missing values?)
concordances <- function(...) {
  m <- signs_mat_from_vecs(list(...))
  # Equivalence classes
  grp <- t(apply(m, 1, (\(v) v[1] * v)))
  pm <- matrix(c("-", NA, "|")[grp + 2], dim(grp))
  pm_str <- apply(pm, 1, (\(x) paste0(x, collapse = "")))
  return(pm_str)
}
