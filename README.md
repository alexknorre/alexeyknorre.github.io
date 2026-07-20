# alexknorre.com

Personal academic website. Quarto, single page, deployed on GitHub Pages.

## Architecture

```
Zotero collection "_knorre_publications"
        | Better BibTeX auto-export ("on change", one-way)
        v
knorre_publications.bib        <- machine-owned. NEVER hand-edit.
        |
        |   papers.yml         <- hand-owned: display order, summaries,
        |                         replication links. The only file to edit
        v                         when changing the publications list.
_render_papers.R               <- joins bib + yml, emits HTML paper cards.
        ^
        | source()d by the R chunk in index.qmd during render
```

Everything else on the page (bio, Data section, CV link) is ordinary
markdown in `index.qmd`.

## Conventions

Citation keys are the join key for everything. For every paper listed in
`papers.yml` there must exist:

- `images/{key}.png` -- a figure from the paper, shown on the card
- `papers/{key}.pdf` -- the full text, linked from the card

The render **stops with an error** naming the key if either file is
missing, or if a `papers.yml` key is absent from the bib. A bib entry
without a `papers.yml` entry is fine: it just doesn't show on the site
(a note listing such entries is printed at render time).

Keys are currently UNPINNED in Zotero (BBT generates them). If BBT ever
regenerates a key (typical cause: adding another same-author-same-year
paper reshuffles a `b` suffix), the render fails with "papers.yml lists
keys that are not in the bib". Fix: update the key in `papers.yml` and
rename the two asset files, or pin keys in Zotero (Extra field line
`Citation Key: xxx`).

## Adding a paper

1. Add the item to the `_knorre_publications` collection in Zotero.
   BBT rewrites `knorre_publications.bib` automatically.
2. Add an entry to `papers.yml` (position = position on the page).
3. Drop `images/{key}.png` and `papers/{key}.pdf`.
4. Render, check, publish (below).

## Build and deploy

```
quarto render                  # build into _site/, check it locally
git add -A && git commit
git push origin main
quarto publish gh-pages        # render + push built site to gh-pages
```

GitHub Pages serves the `gh-pages` branch at alexknorre.com (CNAME).
`main` carries source only; `_site/` is gitignored.

R dependencies of the render: RefManageR, yaml (both on CRAN; yaml ships
with knitr anyway).

## Legacy PDF aliases

Before July 2026 the papers used different citation keys
(e.g. `knorre2023shootings`, now `knorre_macdonald_2023`). Old-name
copies of the 10 PDFs live in `papers/` so that inbound links from
before the rename keep working. Git stores identical files once, so
they cost nothing. This set is frozen: never add new aliases, and do
not delete them.

## 404

`404.html` is a hand-written static page (pixel-art), copied verbatim
into the build via the `resources` list in `_quarto.yml`. GitHub Pages
serves it automatically for any missing path.
