#' Compute rank-gap statistics from input scores
#'
#' @export
#'
#' @param ... ≥2 vectors of \emph{unsigned} input scores. These should all have
#' the same length.
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
#' @param ... Vectors of \emph{signed} input scores; these should be of equal 
#' length
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

  gg_phist(d, .data$r_gap, n_bins = n_bins) +
    ggplot2::aes(fill = .data$signs) +
    ggplot2::scale_fill_manual(values = tol_colors_alternating())
}

#' Produce a rank-gap "line-histogram" based on signed input scores, with fill 
#' mapped to combinations of signs
#' @param ... Vectors of \emph{signed} input scores; these should be of equal 
#' length
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
    # Need to separately handle 2 and >2 bins in order to
    # have "next x%" bin
    if (n_max_rank_bins == 2) {
      bin_cat_labels <-
        paste0(
          c("top ", "bottom "),
          signif(
            100 / (
              c(1, 1 / (n_max_rank_bins - 1)) *
                n_max_rank_bins),
            2
          ),
          "%"
        )

      d$bin_category <-
        # Would love a dplyr::case_when solution here...
        ifelse(
          d$max_rank_bin == n_max_rank_bins,
          1, 2
        ) |>
        factor(levels = 1:2, labels = bin_cat_labels)
    } else {
      bin_cat_labels <-
        paste0(
          c("top ", "next ", "bottom "),
          signif(
            100 / (
              c(1, 1, 1 / (n_max_rank_bins - 2)) *
                n_max_rank_bins),
            2
          ),
          "%"
        )

      d$bin_category <-
        # Would love a dplyr::case_when solution here...
        ifelse(
          d$max_rank_bin == n_max_rank_bins,
          1,
          ifelse(
            d$max_rank_bin == n_max_rank_bins - 1,
            2,
            3
          )
        ) |>
        factor(levels = 1:3, labels = bin_cat_labels)
    }


    p <-
      gg_phist_line(d, .data$r_gap, n_bins = n_bins) +
      ggplot2::aes(color = .data$signs) +
      ggplot2::scale_color_manual(values = tol_colors_alternating()) +
      ggplot2::facet_wrap(~ .data$bin_category)

    return(p)
  }
}
