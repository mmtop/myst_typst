#import "layout/cover.typ": cover_page
#import "layout/titlepage.typ": title_page
#import "layout/frontmatter.typ": frontmatter_section, frontmatter_other
#import "layout/toc.typ": render_table_of_contents, render_list_of_figures, render_list_of_tables
#import "components/headings.typ": configure_headings
#import "theme/colors.typ": * 


#let require_non_empty(value, field_name, fallback: none) = {
  if value == none or value == "" {
    if fallback != none {
      fallback
    } else {
      panic("Missing required metadata: " + field_name)
    }
  } else {
    value
  }
}

#let resolve_numbering(mode, default: "1") = {
       if mode == none {    default  } 
  else if mode == "none" {  none   } 
  else if mode == "roman" {  "i"   } 
  else if mode == "arabic" {  "1"  } 
  else { default }
}

#let resolve_asset_path(path, levels_up: 1) = {
       if path == none {  none   } 
  else if type(path) != str {     path  } 
  else if path.starts-with("/") or path.starts-with("./") or path.starts-with("../") or path.contains(":/") {     path   } 
  else if levels_up == 2 {    "../../" + path  } 
  else if levels_up == 1 {     "../" + path   } 
  else {     path  }
}

#let render_comma_list(items) = {
       if items == none {   ""   } 
  else if type(items) == str {    items   } 
  else if items.len() == 0 {     ""  } 
  else {
    let output = ""
    for (index, item) in items.enumerate() {
      if index > 0 {
        output += ", "
      }
      output += str(item)
    }
    output
  }
}

#let contributor_group_matches(contributor_id, group) = {
  let normalized = if contributor_id == none { "" } else { str(contributor_id) }
       if group == "supervisor" {normalized == "supervisor" or normalized. starts-with("supervisor") or normalized == "advisor" or normalized.starts-with("advisor") } 
  else if group == "committee" { normalized == "committee" or normalized.starts-with("committee") or normalized == "examiner" or normalized.starts-with("examiner") } 
  else {  false  }
}

#let resolve_affiliation_name(affiliation_id, affiliation_catalog) = {
  let requested_id = if affiliation_id == none { "" } else { str(affiliation_id) }
  if requested_id == "" or affiliation_catalog == none or type(affiliation_catalog) == str {
    none
  } else {
    let result = none
    for item in affiliation_catalog {
      if type(item) != str {
        let item_id = if item.id == none { "" } else { str(item.id) }
        if item_id == requested_id {
          result = if item.name == none { none } else { str(item.name) }
        }
      }
    }
    result
  }
}

#let resolve_affiliation_line(affiliation_ids, affiliation_catalog) = {
  if affiliation_ids == none {
    none
  } else if type(affiliation_ids) == str {
    let direct = str(affiliation_ids)
    if direct == "" {
      none
    } else {
      let resolved = resolve_affiliation_name(direct, affiliation_catalog)
      if resolved == none { direct } else { resolved }
    }
  } else {
    let names = ()
    for aff_id in affiliation_ids {
      let aff_name = resolve_affiliation_name(aff_id, affiliation_catalog)
      if aff_name != none and aff_name != "" {
        names += (aff_name,)
      } else if aff_id != none and str(aff_id) != "" {
        names += (str(aff_id),)
      }
    }
    let rendered = render_comma_list(names)
    if rendered == "" { none } else { rendered }
  }
}

#let contributors_by_group(contributors, group, affiliation_catalog) = {
  if contributors == none or type(contributors) == str {
    ()
  } else {
    let output = ()
    for contributor in contributors {
      if type(contributor) != str {
        let contributor_id = if contributor.id == none { "" } else { str(contributor.id) }
        let name = if contributor.name == none { "" } else { str(contributor.name) }
        if name != "" and contributor_group_matches(contributor_id, group) {
          let affiliation = resolve_affiliation_line(contributor.affiliations, affiliation_catalog)
          output += ((
            name: name,
            affiliation: affiliation,
          ),)
        }
      }
    }
    output
  }
}

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
    fill: default_text_color,
  )

  set par(
    leading: line_spacing_em,
    spacing: 0.7em,
    justify: true,
    first-line-indent: 1.2em,
  )

//--All about numbering--//

  // numbering of headings

  set heading(numbering: (..args) => {
    let nums = args.pos()
    let level = nums.len()
    if level == 1 {[#numbering("1.", ..nums)]} else {[#numbering("1.1.1", ..nums)]}
    },
  )   
    
  // resetting numbering of table, equations, and figures with new chapter
  show heading.where(level: 1): it => {  
    // Reset all counters with a new chapter
    counter(figure).update(0)                // all figures (irrespective of kind)
    counter(figure.where(kind: table)).update(0) // specific for tables
    counter(math.equation).update(0)
    
    it
  }


  // numbering of equations with chapter number as prefix
  set math.equation(numbering: (..args) => {
    let chapter = counter(heading).display((..nums) => nums.pos().at(0))
    [(#chapter.#numbering("1)", ..args.pos())]
  })

  show math.equation: set block(spacing: 1em)

//--all about figures--//

  // set figure.caption(supplement: [Figuur]) ideally language option!
//set figure(  supplement: [#emph[Supplement]] )
 show figure.caption: it => {
  set align(left)
  set par(justify: true)
  set text(size: 10pt)
  it
}


  show raw: set text(font: font_mono, size: font_size_pt - 1pt)
  
  configure_headings(red) // should be checked, ideally, in its current state, just include it above.


// deserves its own component file. //
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
