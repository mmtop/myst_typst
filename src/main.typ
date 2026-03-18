#import "layout/cover.typ": cover_page
#import "layout/titlepage.typ": title_page
#import "layout/frontmatter.typ": frontmatter_section, frontmatter_other
#import "layout/toc.typ": render_table_of_contents, render_list_of_figures, render_list_of_tables
#import "components/headings.typ": configure_headings
#import "components/figures.typ": configure_figures
#import "theme/colors.typ": * 
#import "theme/numbering.typ": setup-numbering
#import "helperfunctions.typ": *




#let thesis_template(
  title: "Untitled Thesis",
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
  frontmatter_numbering: "roman",
  mainmatter_numbering: "arabic",
  paper_size: "a4",
  margin_top_cm: 2.5cm,
  margin_bottom_cm: 2.5cm,
  margin_left_cm: 3.0cm,
  margin_right_cm: 2.0cm,
  font_body: "Libertinus Serif",
  font_mono: "DejaVu Sans Mono",
  font_size_pt: 11pt,
  line_spacing_em: 1.35em,
  toc_depth: 3,
  logo: none,
  cover_page_variant: "simple",
  cover_background_image: none,
  cover_title_box_opacity_pct: 55,
  title_page_variant: "1",
  title_page_image: none,
  title_page_image_anchor: none,
  title_page_image_width_cm: none,
  title_page_image_height_cm: none,
  title_page_image_dx_cm: none,
  title_page_image_dy_cm: none,
  heading_color: rgb("#0F172A"),
  body,
) = {
  let resolved_title = require_non_empty(title, "project.title", fallback: "Untitled Thesis")
  let resolved_supervisors = contributors_by_group(contributors, "supervisor", affiliation_catalog)
  let resolved_committee = contributors_by_group(contributors, "committee", affiliation_catalog)
  let front_numbering = resolve_numbering(frontmatter_numbering, default: "i")
  let main_numbering = resolve_numbering(mainmatter_numbering, default: "1")
  let resolved_logo_for_main = resolve_asset_path(logo, levels_up: 1)
  let resolved_logo_for_layout = resolve_asset_path(logo, levels_up: 2)
  let resolved_cover_background_image = resolve_asset_path(cover_background_image, levels_up: 2)
  let resolved_title_page_image = if show_title_page_image { resolve_asset_path(title_page_image, levels_up: 2)  } else {    none  }

  set page(
    paper: paper_size,
    margin: (
      top: margin_top_cm,
      bottom: margin_bottom_cm,
      left: margin_left_cm,
      right: margin_right_cm,
    ),
    numbering: front_numbering,
  )

  set text(
    font: font_body,
    size: font_size_pt,
    fill: rgb("#1E293B"),
  )

  set par(
    leading: line_spacing_em,
    spacing: 0.7em,
    justify: true,
    first-line-indent: 1.2em,
  )

  

  show math.equation: set block(spacing: 1em)

  show raw: set text(font: font_mono, size: font_size_pt - 1pt)
  show link: set text( fill: blue.darken(30%))
  
  show: body => setup-numbering(body)
  show: body => configure_headings(heading_color,body)
  show: body => configure_figures(body)

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
    set page(
      paper: paper_size,
      margin: (
        top: margin_top_cm,
        bottom: margin_bottom_cm,
        left: margin_left_cm,
        right: margin_right_cm,
      ),
      numbering: front_numbering,
      background: none,
    )
  }

// deserves its own component file. like below //
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
      page_image: resolved_title_page_image,
      page_image_anchor: title_page_image_anchor,
      page_image_width: title_page_image_width_cm,
      page_image_height: title_page_image_height_cm,
      page_image_dx: title_page_image_dx_cm,
      page_image_dy: title_page_image_dy_cm,
    )
  }

  pagebreak()
  frontmatter_section("Abstract", abstract)
  v(2em)
  frontmatter_other("Keywords", render_comma_list(keywords))
  pagebreak()
  frontmatter_section("Preface", preface)
  frontmatter_section("Acknowledgements", acknowledgements)
  frontmatter_section("Dedication", dedication)
  frontmatter_section("Colophon", colophon)
  

  if show_toc { render_table_of_contents(depth: toc_depth)  }
  if show_list_of_figures { render_list_of_figures() }
  if show_list_of_tables { render_list_of_tables()  }

  pagebreak()


//--------- layout main content ---------//
  set page(
    paper: paper_size,
    margin: (
      top: margin_top_cm,
      bottom: margin_bottom_cm,
      left: margin_left_cm,
      right: margin_right_cm,
    ),
    numbering: main_numbering,
    header: if resolved_logo_for_main != none {
      align(right, image(resolved_logo_for_main, width: 1.4cm)) //align should be adaptable.
    } else {
      none
    },
  )

  counter(page).update(1)

//---------include main content-------//
  [#body]
}
