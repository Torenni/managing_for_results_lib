# Run this script from the managing_for_results_lib RStudio project root.
# It reads the existing .Rmd articles without changing them and regenerates
# the HTML files with a shared MADRA design and responsive typography.
if (!requireNamespace('rmarkdown', quietly = TRUE)) install.packages('rmarkdown')

root <- getwd()
if (!file.exists(file.path(root, 'managing_for_results_lib.Rproj'))) {
  stop('Open managing_for_results_lib.Rproj in RStudio, then run this script.')
}

css <- file.path(root, 'madra-article.css')
if (!file.exists(css)) stop('Copy madra-article.css into the repository root first.')

articles <- list(
  list(folder='managing-for-results', base='managing_for_results', topic='Managing for Results', date='October 21, 2026'),
  list(folder='adaptive-management', base='adaptive_management', topic='Adaptive Management', date='October 27, 2026')
)

for (article in articles) {
  folder <- file.path(root, 'blogs', article$folder)
  input <- file.path(folder, paste0(article$base, '.Rmd'))
  if (!file.exists(input)) stop('Missing source: ', input)

  before <- tempfile(fileext='.html')
  after <- tempfile(fileext='.html')
  writeLines(c(
    '<header class="madra-header"><nav class="madra-nav" aria-label="Article navigation">',
    '<a class="madra-wordmark" href="../../index.html">MADRA<small>MANAGING FOR DEVELOPMENT RESULTS ASSOCIATES</small></a>',
    '<a class="madra-back" href="../../index.html">&#8592; All articles</a>',
    '</nav></header>',
    '<section class="madra-hero"><div class="madra-hero-inner">',
    '<p class="madra-kicker" style="color:#edbe78">MADRA &middot; POLICY, GOVERNANCE &amp; DEVELOPMENT</p>',
    paste0('<p><strong>', article$topic, '</strong> &nbsp;|&nbsp; ', article$date, '</p>'),
    '</div></section>'
  ), before, useBytes=TRUE)
  writeLines(c(
    '<div class="madra-actions">',
    '<a class="madra-button" href="../../index.html">Explore all articles</a>',
    '<a class="madra-button alt" href="#header">Back to top &#8593;</a>',
    '</div>',
    '<footer class="madra-footer"><div class="madra-footer-inner">',
    '<p><strong>MADRA &middot; Research, Policy &amp; Development</strong></p>',
    '<p>Independent perspectives for evidence-informed development in Liberia and across Africa.</p>',
    '<p>&copy; 2026 MADRA</p></div></footer>'
  ), after, useBytes=TRUE)

  rmarkdown::render(
    input=input,
    output_format=rmarkdown::html_document(
      self_contained=TRUE,
      css=css,
      toc=FALSE,
      includes=rmarkdown::includes(before_body=before, after_body=after)
    ),
    output_file=paste0(article$base, '.html'),
    output_dir=folder,
    quiet=FALSE,
    envir=new.env(parent=globalenv())
  )
  unlink(c(before,after))
  message('Created: ', file.path(folder,paste0(article$base,'.html')))
}
message('Finished. Preview both HTML files, then commit and push them to GitHub.')
