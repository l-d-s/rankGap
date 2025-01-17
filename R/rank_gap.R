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
  n_stats <- length(stats_list)
  rank_list <- lapply(stats_list, (\(x) rank(x, ties.method = ties_method)))
  rank_min <- do.call(pmin, rank_list)
  rank_max <- do.call(pmax, rank_list)
  r_gap_raw <- ((rank_max - rank_min) + nonzero_adj * 0.5) /
    (rank_max + nonzero_adj)
  r_gap <- r_gap_raw**(n_stats - 1)
  return(r_gap)
}

#' Conduct a rank-gap analysis; returns a data frame
#'
#' @export
rank_gap_df <- function(
    ...,
    n_max_rank_bins = 1,
    ties_method = "random",
    nonzero_adj = TRUE) {
  signed_stats_list <- list(...)
  if (is.null(names(signed_stats_list))) {
    names(signed_stats_list) <- paste0("s", seq_along(signed_stats_list))
  }

  rank_list <- lapply(
    signed_stats_list,
    (\(x) rank(abs(x), ties.method = ties_method))
  )

  d <- data.frame(signed_stats_list)

  d$concordances <-
    concordances(...) |>
    factor(ordered = TRUE)

  d$signs <- signs_pm(...)

  d$r_gap <- do.call(
    function(...) {
      rank_gap(..., ties_method = ties_method, nonzero_adj = nonzero_adj)
    },
    lapply(signed_stats_list, abs)
  )

  d$max_rank <- do.call(pmax, rank_list)

  if (n_max_rank_bins != 1) {
    d$max_rank_bin <- ggplot2::cut_number(
      d$max_rank,
      n_max_rank_bins,
      labels = FALSE
    ) |>
      factor(ordered = TRUE)
  }

  return(tibble::as_tibble(d))
}

#' Produce a rank-gap histogram, with fill mapped to combinations of signs,
#' from signed input scores
#' @param ... Signed input scores
#' @param n_bins Number of histogram bins
#' @param ties_method,nonzero_adj Arguments passed to `rank_gap()`
#'
#' @importFrom rlang .data
#' @export
rank_gap_hist <- function(
    ...,
    n_bins = 30,
    ties_method = "random",
    nonzero_adj = TRUE) {
  d <- rank_gap_df(
    ...,
    ties_method = ties_method,
    nonzero_adj = nonzero_adj
  )

  gg_phist(d, r_gap, n_bins = n_bins) +
    ggplot2::aes(fill = .data$signs) +
    ggplot2::scale_fill_manual(values = tol_colors_alternating())
}

#' Produce a rank-gap "line-histogram", with fill mapped to combinations of signs,
#' from signed input scores
#' @param ... Signed input scores
#' @param n_bins Number of histogram bins
#' @param ties_method,nonzero_adj Arguments passed to `rank_gap()`
#' @param n_max_rank_bins Number of quantile bins for the maximum rank, to 
#' focus on items ranked high across all input lists
#'
#' @importFrom rlang .data
#' @export
rank_gap_linehist <- function(
    ...,
    n_max_rank_bins = 1,
    n_bins = 30,
    ties_method = "random",
    nonzero_adj = TRUE) {
  d <- rank_gap_df(
    ...,
    ties_method = ties_method,
    nonzero_adj = nonzero_adj,
    n_max_rank_bins = n_max_rank_bins
  )
  
  if (n_max_rank_bins == 1) {
    p <- gg_phist_line(d, .data$r_gap, n_bins = n_bins) +
      ggplot2::aes(color = .data$signs) +
      ggplot2::scale_color_manual(values = tol_colors_alternating())
    
    return(p)
  } else {
    d_max <- d[d$max_rank_bin == n_max_rank_bins, ]
    d_rest <- d[d$max_rank_bin < n_max_rank_bins, ] |>
      transform(
        next_from_top = max_rank_bin == n_max_rank_bins - 1
      )

    p_max <- 
      gg_phist_line(d_max, .data$r_gap, n_bins = n_bins) +
      ggplot2::aes(color = .data$signs) +
      ggplot2::scale_color_manual(values = tol_colors_alternating())
    
    p_rest <- gg_phist_line(d_rest, r_gap, n_bins = n_bins) +
      ggplot2::aes(
        color = .data$next_from_top,
        group = interaction(
          .data$signs,
          .data$max_rank_bin)) +
      ggplot2::scale_color_manual(values = c("grey80", "black"))
    
    return(patchwork::wrap_plots(p_max,  p_rest, nrow = 1))
  }

}
