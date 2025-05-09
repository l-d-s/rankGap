#' MDEM data from B cells
#'
#' Collated output from an analysis of gene expression differences comparing
#' mice with three MDEMs (Mendelian disorders of the epigenetic machinery)
#' with matched wild type littermates.
#'
#' The analysis was conducted using `limma` and applied only to within-litter
#' comparisons.
#'
#' @format ## `d_B_limma`
#' A data frame with 13,474 rows and 25 columns:
#' \describe{
#'   \item{ensembl_id}{ENSEMBL ID for the gene}
#'   \item{logFC, AveExpr, t, P.Value, adj.P.Val, B, se, se_unshrunk}{
#'       Outputs from `limma` with MDEM acronym suffixed (KS1 = Kabuki syndrome
#'       Type 1; KS2 = Kabuki Syndrome Type 2; RT = Rubenstein-Taybi syndrome)}
#' }
#'
#' @source The data are based on a (private) re-analysis of raw expression data from
#' experiments described in the paper
#' \preformatted{@article{luperchioLeveragingMendelianDisorders2021,
#'  title = {Leveraging the Mendelian Disorders of the Epigenetic Machinery to Systematically Map Functional Epigenetic Variation},
#'  author = {Luperchio, Teresa Romeo and Boukas, Leandros and Zhang, Li and Pilarowski, Genay and Jiang, Jenny and Kalinousky, Allison and Hansen, Kasper D and Bjornsson, Hans T},
#'  editor = {Dekker, Job and Barkai, Naama},
#'  date = {2021-08-31},
#'  journaltitle = {eLife},
#'  volume = {10},
#'  pages = {e65884},
#'  publisher = {eLife Sciences Publications, Ltd},
#'  issn = {2050-084X},
#'  doi = {10.7554/eLife.65884},
#'  url = {https://doi.org/10.7554/eLife.65884},
#'  urldate = {2025-01-16},
#'  abstract = {Although each Mendelian Disorder of the Epigenetic Machinery
#'      (MDEM) has a different causative gene, there are shared disease
#'      manifestations. We hypothesize that this phenotypic convergence is a
#'      consequence of shared epigenetic alterations. To identify such shared
#'      alterations, we interrogate chromatin (ATAC-seq) and expression (RNA-seq)
#'      states in B cells from three MDEM mouse models (Kabuki [KS] type 1 and 2 and
#'      Rubinstein-Taybi type 1 [RT1] syndromes). We develop a new approach for the
#'      overlap analysis and find extensive overlap primarily localized in gene
#'      promoters. We show that disruption of chromatin accessibility at promoters
#'      often disrupts downstream gene expression, and identify 587 loci and 264
#'      genes with shared disruption across all three MDEMs. Subtle expression
#'      alterations of multiple, IgA-relevant genes, collectively contribute to IgA
#'      deficiency in KS1 and RT1, but not in KS2. We propose that the joint study of
#'      MDEMs offers a principled approach for systematically mapping functional
#'      epigenetic variation in mammals.},
#'  keywords = {chromatin,computational methods,epigenetics,histone machinery,IgA deficiency,Mendelian},
#' }}
"d_B_limma"
