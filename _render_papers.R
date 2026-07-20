# _render_papers.R -- emits the HTML for the publications list on index.qmd.
# Inputs:
#   knorre_publications.bib -- owned by Zotero/Better BibTeX auto-export. Never hand-edit.
#   papers.yml              -- hand-edited: display order, summaries, replication links.
# Convention: every paper listed in papers.yml must have images/{key}.png and papers/{key}.pdf.
# The render stops with a clear error if either file is missing.

library(RefManageR)
library(yaml)

BibOptions(check.entries = FALSE)
bib <- suppressMessages(ReadBib("knorre_publications.bib"))
meta <- read_yaml("papers.yml")$papers

site_keys <- vapply(meta, function(p) p$key, character(1))
missing_in_bib <- setdiff(site_keys, names(bib))
if (length(missing_in_bib) > 0) {
  stop("papers.yml lists keys that are not in the bib: ",
       paste(missing_in_bib, collapse = ", "),
       ". Did Better BibTeX change a citation key? Pin keys in Zotero.")
}
not_on_site <- setdiff(names(bib), site_keys)
if (length(not_on_site) > 0) {
  message("bib entries not shown on the site (no papers.yml entry): ",
          paste(not_on_site, collapse = ", "))
}

for (m in meta) {
  key <- m$key
  entry <- bib[key]

  img <- paste0("images/", key, ".png")
  pdf <- paste0("papers/", key, ".pdf")
  if (!file.exists(img)) stop("Missing figure for ", key, ": ", img)
  if (!file.exists(pdf)) stop("Missing PDF for ", key, ": ", pdf)

  authors <- paste(entry$author, collapse = ", ")
  title   <- gsub("\\\\&", "&", gsub("[{}]", "", entry$title))
  journal <- gsub("\\\\&", "&", entry$journal)
  year    <- entry$year
  doi     <- entry$doi
  url     <- entry$url

  cite <- paste0(authors, " (", year, "). <em>", journal, "</em>.")

  # PDF first; then DOI (a real DOI gets the doi.org resolver, anything else
  # in the doi/url fields is linked as-is); then optional replication package.
  links <- paste0('<a href="', pdf, '" target="_blank">PDF</a> ')
  if (!is.null(doi) && nchar(doi) > 0) {
    href <- if (grepl("^10\\.", doi)) paste0("https://doi.org/", doi) else doi
    links <- paste0(links, '<a href="', href, '" target="_blank">DOI</a> ')
  } else if (!is.null(url) && nchar(url) > 0) {
    links <- paste0(links, '<a href="', url, '" target="_blank">DOI</a> ')
  }
  if (!is.null(m$replication)) {
    links <- paste0(links, '<a href="', m$replication,
                    '" target="_blank">Replication package</a> ')
  }

  cat(sprintf(
'<div class="paper-entry">
<img src="%s" alt="Figure from %s">
<div class="paper-info">
<div class="paper-title">%s</div>
<div class="paper-cite">%s</div>
<div class="paper-summary">%s</div>
<div class="paper-links">%s</div>
</div>
</div>
', img, title, title, cite, m$summary, links))
}
