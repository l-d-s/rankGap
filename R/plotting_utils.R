# Theme for plots
#' @importFrom ggplot2 %+replace%
theme_clean <- function(...) {
  `%+replace%` <- ggplot2::`%+replace%`

  cowplot::theme_cowplot(...) %+replace%
    ggplot2::theme(
      strip.background = ggplot2::element_blank(),
      strip.text.y = ggplot2::element_text(angle = 0),
      strip.text = ggplot2::element_text(face = "plain"),
      axis.title.y = ggplot2::element_text(angle = 0, hjust = 0.5, vjust = 0.5),
      title = ggplot2::element_text(face = "plain", size = 11)
    )
}

gg_hist <- function(
  data,
  x_var,
  n_bins = 30,
  breaks = NULL,
  boundary = NULL,
  ...
) {
  ggplot2::ggplot(data, ggplot2::aes({{ x_var }})) +
    theme_clean() +
    ggplot2::geom_histogram(
      bins = n_bins,
      color = "white",
      breaks = breaks,
      boundary = boundary,
      ...
    ) +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(0, .1),
      limits = c(0, NA),
      name = ""
    )
}


# Scales for p-value-like quantities

scale_x_01 <- ggplot2::scale_x_continuous(
  expand = c(0, 0),
  breaks = c(0, .5, 1),
  labels = c("0", "0.5", "1")
)

scale_y_01 <- ggplot2::scale_y_continuous(
  expand = c(0, 0),
  breaks = c(0, .5, 1),
  labels = c("0", "0.5", "1")
)

gg_phist <- function(data, x_var, n_bins = 30) {
  ggplot2::ggplot(data, ggplot2::aes({{ x_var }})) +
    theme_clean() +
    ggplot2::geom_histogram(
      binwidth = 1 / n_bins,
      color = "white",
      boundary = 0
    ) +
    ggplot2::scale_y_continuous(
      breaks = scales::pretty_breaks(3),
      expand = ggplot2::expansion(0, .1)
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(0, .5, 1),
      labels = c("0", ".5", "1"),
      limits = c(0, 1)
    ) +
    ggplot2::ylab("")
}

gg_p_hist_step <- function(data, x_var, n_bins = 30) {
  ggplot2::ggplot(data, ggplot2::aes({{ x_var }})) +
    theme_clean() +
    ggplot2::stat_bin(
      boundary = 0,
      bins = n_bins,
      geom = "step",
      position = "identity"
    ) +
    ggplot2::scale_y_continuous(
      breaks = scales::pretty_breaks(3),
      expand = ggplot2::expansion(0, .1),
      limits = c(0, NA)
    ) +
    ggplot2::scale_x_continuous(
      breaks = c(0, .5, 1),
      labels = c("0", ".5", "1"),
      limits = c(0, 1),
      expand = ggplot2::expansion(c(0, 0))
    ) +
    ggplot2::ylab("")
}

gg_p_density_line <- function(data, x_var, unif_guide = FALSE) {
  p <- ggplot2::ggplot(data, ggplot2::aes({{ x_var }})) +
    theme_clean()

  if (unif_guide) {
    p <- p + ggplot2::geom_hline(yintercept = 1, color = "grey80")
  }

  p +
    ggplot2::stat_density(
      bounds = c(0, 1),
      geom = "line",
      position = "identity"
    ) +
    ggplot2::scale_y_continuous(
      breaks = scales::pretty_breaks(3),
      expand = ggplot2::expansion(c(0, .1)),
      limits = c(0, NA)
    ) +
    scale_x_01 +
    ggplot2::ylab("")
}

tol_colors <- c(
  "#117733",
  "#332288",
  "#AA4499",
  "#999933",
  "#44AA99",
  "#882255",
  "#88CCEE",
  "#DDCC77",
  "#CC6677"
)

tol_colors_alternating <- function() {
  # Colorblind-friendly palette
  #
  # c(rbind(a, b)) interleaves a and b:
  # https://stackoverflow.com/questions/25961897/how-to-merge-2-vectors-alternating-indexes
  #
  # Note: this is a function because otherwise we trigger
  # a "Namespace in Imports field not imported from:  ‘colorspace’"
  # warning due to a (here unproblematic, I think) _build-time_ dependency on
  # the colorspace package:
  # https://github.com/hadley/r-pkgs/issues/203
  c(rbind(tol_colors, colorspace::lighten(tol_colors, 0.5)))
}


stone_colors <-
  c(
    "#396AB1",
    "#DA7C30",
    "#3E9651",
    "#CC2529",
    "#535154",
    "#6B4C9A",
    "#922428",
    "#948B3D"
  )

stone_colors_alternating <- function() {
  c(rbind(stone_colors, colorspace::lighten(stone_colors, 0.5)))
}
