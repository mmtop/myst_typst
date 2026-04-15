#import "layout/cover.typ": cover_page
#import "layout/titlepage.typ": title_page, contributors_by_group
#import "layout/frontmatter.typ": render_frontmatter
#import "layout/bibliography.typ": render_bibliography

#import "components/headings.typ": configure_headings
#import "components/figures.typ": configure_figures

#import "theme/colors.typ": default_text_color, default_heading_color
#import "theme/numbering.typ": setup-numbering

// Use this file as the main Typst layout entry point for the template.
// It receives normalized metadata, part files, and export options from template.typ,
// applies the global page and text styling, and then assembles the cover page,
// title page, front matter, main content, and bibliography.

#let thesis_template(
  title: "Untitled Report",
  subtitle: none,
  authors: (),
  contributors: (),
  affiliation_catalog: (),
  affiliations: (),
  date: none,
  keywords: (),

  thesis_degree: none,
  thesis_program: none,
  thesis_faculty: none,
  thesis_institution: none,
  thesis_defense_date: none,

  abstract: none,
  preface: none,
  acknowledgements: none,
  dedication: none,
  colophon: none,

  show_cover_full: true,
  show_title_page: true,
  show_title_page_image: true,
  show_contributor_affiliations: true,
  show_toc: true,
  show_list_of_figures: false,
  show_list_of_tables: false,
  toc_depth: 2,

  paper_size: "a4",
  margin_top_cm: 2.5cm,
  margin_bottom_cm: 2.5cm,
  margin_left_cm: 2.5cm,
  margin_right_cm: 2.5cm,

  // Keep the template default on Typst's built-in font stack so fresh installs
  // work without extra setup. Bundled alternatives live in src/assets/fonts:
  // STIX Two Text + STIX Two Math, JetBrains Mono, Atkinson Hyperlegible Next,
  // and Atkinson Hyperlegible Mono. JetBrains Mono is the recommended code font.
  font_body: "Libertinus Serif",
  font_mono: "DejaVu Sans Mono",
  font_math: "New Computer Modern Math",
  font_size_pt: 11pt,
  line_spacing_em: 0.6em,

  bibliography_file: none,
  show_bibliography: true,
  bibliography_title: "Bibliography",
  bibliography_style: "ieee",
  bibliography_numbered_heading: false,

  logo: "src/assets/brand_assets/logo.svg",
  cover_page_variant: "simple",
  cover_background_image: "src/assets/template_figures/defaultcover.jpg",
  cover_title_box_opacity_pct: 55,

  title_page_variant: "basic",
  title_page_image: "src/assets/template_figures/defaultcover.jpg",
  title_page_image_anchor: "bottom",
  title_page_image_width_cm: none,
  title_page_image_height_cm: none,
  title_page_image_dx_cm: none,
  title_page_image_dy_cm: none,
  show_title_page_cover_description: false,
  title_page_cover_description: none,
  show_title_page_confidentiality_statement: false,
  title_page_confidentiality_statement: "This thesis is confidential and cannot be made public.",
  body,
) = {
  // Asset paths may be used from this file or from nested layout files.
  // This helper normalizes Windows separators and rebases bare relative paths
  // so the same config values keep working locally and in exported template bundles.
  let resolve_asset_path = (path, levels_up: 1) => {
    if path == none {
      none
    } else if type(path) != str {
      path
    } else {
      let normalized = str(path).replace("\\", "/")
      if normalized.starts-with("/") or normalized.starts-with("./") or normalized.starts-with("../") or normalized.contains(":/") {
        normalized
      } else if levels_up == 2 {
        "../../" + normalized
      } else if levels_up == 1 {
        "../" + normalized
      } else {
        normalized
      }
    }
  }

  // Some values are reused in multiple layout blocks, so they are resolved once here.
  // Bundled fallback assets also live here so template.typ can stay a thin mapping layer.
  let resolved_title = if title == none or title == "" { "Untitled Report" } else { title }
  let resolved_supervisors = contributors_by_group(contributors, "supervisor", affiliation_catalog)
  let resolved_committee = contributors_by_group(contributors, "committee", affiliation_catalog)
  let resolved_logo_for_layout = resolve_asset_path(logo, levels_up: 2)
  let resolved_cover_background_image = resolve_asset_path(cover_background_image, levels_up: 2)
  let resolved_title_page_image = if show_title_page_image {
    resolve_asset_path(title_page_image, levels_up: 2)
  } else {
    none
  }

  // Global page setup for the front matter.
  // Change the numbering here if you want a different front-matter page style.
  set page(
    paper: paper_size,
    margin: (
      top: margin_top_cm,
      bottom: margin_bottom_cm,
      left: margin_left_cm,
      right: margin_right_cm,
    ),
    numbering: "i",
  )

  // Global text defaults for the document body.
  set text(
    font: font_body,
    size: font_size_pt,
    fill: default_text_color,
  )

  set par(
    leading: line_spacing_em,
    spacing: 0.7em,
    justify: true,
    first-line-indent: 1.2em,
  )

  // Shared component styling.
  show math.equation: set text(font: font_math)
  show math.equation: set block(spacing: 1em)
  show raw: set text(font: font_mono, size: font_size_pt - 1pt)
  show link: set text(fill: blue.darken(30%))

  // Global numbering and component rules.
  show: body => setup-numbering(body)
  show: body => configure_headings(default_heading_color, body)
  show: body => configure_figures(body)

  // Optional cover page.
  if show_cover_full {
    cover_page(
      resolved_title,
      subtitle: subtitle,
      authors: authors,
      variant: cover_page_variant,
      image_path: resolved_cover_background_image,
      box_opacity_pct: cover_title_box_opacity_pct,
      institution_line: thesis_institution,
      logo: resolved_logo_for_layout,
    )

    // Reset the page background and keep roman numbering for the title page
    // and the remaining front matter after the full cover.
    set page(
      paper: paper_size,
      margin: (
        top: margin_top_cm,
        bottom: margin_bottom_cm,
        left: margin_left_cm,
        right: margin_right_cm,
      ),
      numbering: "i",
      background: none,
    )
  }

  // Optional title page.
  if show_title_page {
    title_page(
      resolved_title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      date: date,
      degree: thesis_degree,
      program: thesis_program,
      faculty: thesis_faculty,
      institution: thesis_institution,
      defense_date: thesis_defense_date,
      supervisors: resolved_supervisors,
      committee: resolved_committee,
      show_contributor_affiliations: show_contributor_affiliations,
      logo: resolved_logo_for_layout,
      variant: title_page_variant,
      start_on_new_page: show_cover_full,
      show_cover_description: show_title_page_cover_description,
      cover_description: title_page_cover_description,
      show_confidentiality_statement: show_title_page_confidentiality_statement,
      confidentiality_statement: title_page_confidentiality_statement,
      page_image: resolved_title_page_image,
      page_image_anchor: title_page_image_anchor,
      page_image_width: title_page_image_width_cm,
      page_image_height: title_page_image_height_cm,
      page_image_dx: title_page_image_dx_cm,
      page_image_dy: title_page_image_dy_cm,
    )
  }

  // Front matter between the title page and the main chapters.
  render_frontmatter(
    abstract: abstract,
    keywords: keywords,
    preface: preface,
    acknowledgements: acknowledgements,
    dedication: dedication,
    colophon: colophon,
    show_toc: show_toc,
    show_list_of_figures: show_list_of_figures,
    show_list_of_tables: show_list_of_tables,
    toc_depth: toc_depth,
  )

  // Main matter uses arabic page numbers.
  set page(
    paper: paper_size,
    margin: (
      top: margin_top_cm,
      bottom: margin_bottom_cm,
      left: margin_left_cm,
      right: margin_right_cm,
    ),
    numbering: "1",
  )

  // Restart page numbering when the main matter begins.
  counter(page).update(1)

  // MyST adds the ordered chapter and appendix content here.
  [#body]

  // Optional bibliography after the document content.
  render_bibliography(
    bibliography_file: bibliography_file,
    show_bibliography: show_bibliography,
    bibliography_title: bibliography_title,
    bibliography_style: bibliography_style,
    bibliography_numbered_heading: bibliography_numbered_heading,
  )
}
