// This file controls the pages that come after the title page
// and before the main chapters. That includes the abstract,
// the keyword line, optional front-matter sections, and the
// navigation pages such as the table of contents, including the
// list of figures and the list of tables.



// Creates a full front-matter section with a centered heading above the text.
// It is used for longer pieces such as the abstract, preface, acknowledgements,
// dedication, or colophon. If no content is provided, the whole section is skipped.
#let render_frontmatter_section(title, content) = {
  if content != none and content != "" {
    align(center, text(15pt, weight: "bold", title))
    v(1.2em)
    content
  }
}

// Starts a new page and renders one optional front-matter section on it.
// If the section is empty, nothing is added.
#let render_optional_frontmatter_page(title, content) = {
  if content != none and content != "" {
    pagebreak()
    render_frontmatter_section(title, content)
  }
}

// Turns the MyST keyword list into one printable line such as:
// "myst, typst, thesis".
#let format_keywords(keywords) = {
       if keywords == none {   ""   }
  else if type(keywords) == str {    keywords   }
  else if keywords.len() == 0 {     ""  }
  else {
    let output = ""
    for (index, item) in keywords.enumerate() {
      if index > 0 { output += ", "  }
      output += str(item)
    }
    output
  }
}

// Places the keyword label on the left and the keyword list on the right.
// If the keywords wrap, the next line stays under the keyword text rather than
// starting again under the label.
// Keywords are optional and come from MyST metadata rather than from a part file.
#let render_keywords_box(keyword_text) = {
  if keyword_text != "" {
    align(left, table(
      columns: (auto, 1fr),
      column-gutter: 0.9em,
      stroke: none,
      inset: 0pt,
      align: (left, left),
      table.cell(inset: 0pt)[#text(weight: "bold")[Keywords:]],
      table.cell(inset: 0pt)[#keyword_text],
    ))
  }
}

// Renders the opening abstract page.
// If both the abstract and keywords are empty, this page is skipped.
#let render_abstract_page(abstract, keywords) = {
  let keyword_text = format_keywords(keywords)
  if (abstract != none and abstract != "") or keyword_text != "" {
    pagebreak()
    render_frontmatter_section("Abstract", abstract)
    if keyword_text != "" {
      v(1.5em)
      render_keywords_box(keyword_text)
    }
  }
}

// Renders the table of contents page.
#let render_table_of_contents(depth: 1) = {
  pagebreak()
  outline(
    title: strong("Contents"),
    depth: depth,
    indent: auto,
  )
}

// Renders the list of figures page.
#let render_list_of_figures() = {
  pagebreak()
  outline(
    title: strong("List of Figures"),
    target: figure.where(kind: "figure"), // MyST labels image figures with kind "figure".
    indent: auto,
  )
}

// Renders the list of tables page.
#let render_list_of_tables() = {
  pagebreak()
  outline(
    title: strong("List of Tables"),
    target: figure.where(kind: table),
    indent: auto,
  )
}

// Collects everything that appears before the main chapters.
// This keeps the front matter settings in one place and it is called from the main layout file.
#let render_frontmatter(
  abstract: none,
  keywords: (),
  preface: none,
  acknowledgements: none,
  dedication: none,
  colophon: none,
  show_toc: true,
  show_list_of_figures: false,
  show_list_of_tables: false,
  toc_depth: 2,
) = {
  render_abstract_page(abstract, keywords)

  // These sections already exist as optional (but default) MyST front-matter parts in the template.
  // If empty, they are skipped automatically.
  render_optional_frontmatter_page("Preface", preface)
  render_optional_frontmatter_page("Acknowledgements", acknowledgements)
  render_optional_frontmatter_page("Dedication", dedication)
  render_optional_frontmatter_page("Colophon", colophon)
  // Example for a truly custom section you may want to add later:
  // render_optional_frontmatter_page("Abbreviations", abbreviations)
  // To make that work, you would also need to add `abbreviations` as a new part
  // in template.yml, pass it through template.typ and main.typ, and then call it here.

  // Navigation pages for the document.
  if show_toc { render_table_of_contents(depth: toc_depth) }
  if show_list_of_figures { render_list_of_figures() }
  if show_list_of_tables { render_list_of_tables() }

  // End the front matter before switching to the main content layout.
  pagebreak()
}
