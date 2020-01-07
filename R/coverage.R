
#' tabulator for covr outputs
#' @rdname covrtab
#' @aliases covr_tab
#' @param x instance of coverage S3 class from covr package
#' @param group character(1) tells how to group data, see covr:::print.coverage
#' @param by character(1) report by line or expression
#' @param \dots unused
#' @export
covr_tab = function (x, group = c("functions"), by = "line", 
    ...) UseMethod("covr_tab")

#' produce textual summary of covr analysis
#' @rdname covrtab
#' @import covr
#' @method covr_tab coverage
#' @param x result of `package_coverage`
#' @param group character(1)
#' @param by character(1)
#' @param \dots not used
#' @note This is because package_coverage uses message to report summaries.  We
#' use the 'functions' setting for 'group' by default.
#' @export
covr_tab.coverage = function (x, group = c("functions"), by = "line", 
    ...) 
{
    if (length(x) == 0) {
        return()
    }
    group <- match.arg(group)
    type <- attr(x, "type")
    if (is.null(type) || type == "none") {
        type <- NULL
    }
    df <- tally_coverage(x, by = by)
    if (!NROW(df)) {
        return(invisible())
    }
    percents <- tapply(df$value, df[[group]], FUN = function(x) (sum(x > 
        0)/length(x)) * 100)
    overall_percentage <- percent_coverage(df, by = by)
#    message(crayon::bold(paste(collapse = " ", c(attr(x, "package")$package, 
#        to_title(type), "Coverage: "))), format_percentage(overall_percentage))
    by_coverage <- percents[order(percents, names(percents))]
    list(overall = overall_percentage, specific=by_coverage)
}

