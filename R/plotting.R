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
rank_gap_stephist <- function(
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
    p <-
      gg_p_hist_step(d, .data$r_gap, n_bins = n_bins) +
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
      gg_p_hist_step(d, .data$r_gap, n_bins = n_bins) +
      ggplot2::aes(color = .data$signs) +
      ggplot2::scale_color_manual(values = tol_colors_alternating()) +
      ggplot2::facet_wrap(~ .data$bin_category)

    return(p)
  }
}
