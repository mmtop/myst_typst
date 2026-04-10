#let render_comma_list(items) = {
  if items == none {
    ""
  } else if type(items) == str {
    items
  } else if items.len() == 0 {
    ""
  } else {
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

// Checks whether a contributor belongs to the supervisor or committee group.
#let contributor_group_matches(contributor_id, group) = {
  let normalized = if contributor_id == none { "" } else { str(contributor_id) }
       if group == "supervisor" {normalized == "supervisor" or normalized.starts-with("supervisor") or normalized == "advisor" or normalized.starts-with("advisor") }
  else if group == "committee" { normalized == "committee" or normalized.starts-with("committee") or normalized == "examiner" or normalized.starts-with("examiner") }
  else { false }
}

// Looks up the full affiliation name from an affiliation id.
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

// Turns one or more affiliation ids into a printable line for the title page.
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

// Collects contributors for one group and prepares their names and affiliations for display.
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

#let render_lines(items, fallback: none) = {
  if items == none {
    if fallback == none { "" } else { str(fallback) }
  } else if type(items) == str {
    items
  } else if items.len() == 0 {
    if fallback == none { "" } else { str(fallback) }
  } else {
    let output = ""
    for (index, item) in items.enumerate() {
      if index > 0 {
        output += "\n"
      }
      output += str(item)
    }
    output
  }
}

#let count_items(items) = {
  if items == none {
    0
  } else if type(items) == str {
    if items == "" { 0 } else { 1 }
  } else {
    items.len()
  }
}

#let render_contributor_entries(entries, show_affiliations: true) = {
  if entries == none {
    none
  } else if type(entries) == str {
    if entries == "" {
      none
    } else {
      [#entries]
    }
  } else if entries.len() == 0 {
    none
  } else {
    let rows = ()
    for entry in entries {
      let name = if type(entry) == str {
        str(entry)
      } else if entry.name == none {
        ""
      } else {
        str(entry.name)
      }
      let affiliation = if type(entry) == str {
        none
      } else {
        entry.affiliation
      }
      if name != "" {
        if show_affiliations and affiliation != none and str(affiliation) != "" {
          rows += ([
            #name
            #linebreak()
            #v(-1pt)
            #text(size: 9pt, style: "italic", fill: rgb("#555555"), str(affiliation))
          ],)
        } else {
          rows += ([#name],)
        }
      }
    }
    if rows.len() == 0 {
      none
    } else {
      stack(dir: ttb, spacing: 0.6em, ..rows)
    }
  }
}

#let resolve_title_page_variant(variant) = {
  // Supported variants: "1"/"basic"/"simple", "2"/"formal", and "3"/"custom".
  let normalized = str(variant)
  if normalized == "1" or normalized == "basic" or normalized == "simple" {
    "basic"
  } else if normalized == "2" or normalized == "formal" {
    "formal"
  } else if normalized == "3" or normalized == "custom" {
    "custom"
  } else {
    panic("Invalid title_page_variant '" + normalized + "'. Use '1'/'basic', '2'/'formal', or '3'/'custom'.")
  }
}

#let resolve_title_page_image_anchor(anchor) = {
  if anchor == none {
    bottom + center
  } else {
    let normalized = str(anchor)
    if normalized == "" or normalized == "none" {
      bottom + center
    } else if normalized == "top-right" {
      top + right
    } else if normalized == "top" {
      top + center
    } else if normalized == "top-left" {
      top + left
    } else if normalized == "center" {
      center
    } else if normalized == "bottom" {
      bottom + center
    } else if normalized == "bottom-right" {
      bottom + right
    } else if normalized == "bottom-left" {
      bottom + left
    } else {
      panic("Invalid title_page_image_anchor '" + normalized + "'. Use top-right, top, top-left, center, bottom, bottom-right, or bottom-left.")
    }
  }
}

#let render_title_page_image(
  image_path: none,
  anchor: none,
  width: none,
  height: none,
  dx: none,
  dy: none,
) = {
  if image_path != none {
    let resolved_width = if width == none { 5cm } else { width }
    let resolved_dx = if dx == none { 0cm } else { dx }
    let resolved_dy = if dy == none { 0cm } else { dy }
    let placement = resolve_title_page_image_anchor(anchor)
    if height == none {
      place(placement, dx: resolved_dx, dy: resolved_dy, image(
        image_path,
        width: resolved_width,
        fit: "contain",
      ))
    } else {
      place(placement, dx: resolved_dx, dy: resolved_dy, image(
        image_path,
        width: resolved_width,
        height: height,
        fit: "contain",
      ))
    }
  } else {
    none
  }
}

#let build_title_page_info_cells(
  authors: (),
  date: none,
  defense_date: none,
  supervisors: (),
  committee: (),
  show_contributor_affiliations: true,
) = {
  let author_line = render_comma_list(authors)
  let supervisor_cell = render_contributor_entries(
    supervisors,
    show_affiliations: show_contributor_affiliations,
  )
  let committee_cell = render_contributor_entries(
    committee,
    show_affiliations: show_contributor_affiliations,
  )
  let resolved_defense_date = if defense_date != none and defense_date != "" { defense_date } else { none }
  let resolved_date = if date != none and date != "" { date } else { none }
  let author_label = if count_items(authors) > 1 { "Authors" } else { "Author" }
  let supervisor_label = if count_items(supervisors) > 1 { "Supervisors" } else { "Supervisor" }
  let committee_label = if count_items(committee) > 1 { "Committee Members" } else { "Committee Member" }

  (
    author_label, author_line,
  ) + (
    if supervisor_cell != none {
      (supervisor_label, supervisor_cell,)
    } else {
      ()
    }
  ) + (
    if committee_cell != none {
      (committee_label, committee_cell,)
    } else {
      ()
    }
  ) + (
    if resolved_defense_date != none {
      ("Defense date", resolved_defense_date,)
    } else {
      ()
    }
  ) + (
    if resolved_date != none {
      ("Date", resolved_date,)
    } else {
      ()
    }
  )
}

#let render_title_page_footer_notes(
  show_cover_description: false,
  cover_description: none,
  show_confidentiality_statement: false,
  confidentiality_statement: none,
) = {
  let notes = ()

  if show_cover_description and cover_description != none and str(cover_description) != "" {
    notes += ([#text(size: 10pt, [#strong[Cover:] #str(cover_description)])],)
  }

  if show_confidentiality_statement and confidentiality_statement != none and str(confidentiality_statement) != "" {
    notes += ([#text(size: 10pt, smallcaps(str(confidentiality_statement)))],)
  }

  if notes.len() > 0 {
    v(1fr)
    align(center, stack(dir: ttb, spacing: 0.8em, ..notes))
  }
}

#let title_page_basic_variant(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  date: none,
  degree: none,
  program: none,
  faculty: none,
  institution: none,
  defense_date: none,
  supervisors: (),
  committee: (),
  show_contributor_affiliations: true,
  show_cover_description: false,
  cover_description: none,
  show_confidentiality_statement: false,
  confidentiality_statement: none,
  page_image: none,
  page_image_anchor: none,
  page_image_width: none,
  page_image_height: none,
  page_image_dx: none,
  page_image_dy: none,
) = {
  let info_cells = build_title_page_info_cells(
    authors: authors,
    date: date,
    defense_date: defense_date,
    supervisors: supervisors,
    committee: committee,
    show_contributor_affiliations: show_contributor_affiliations,
  )

  render_title_page_image(
    image_path: page_image,
    anchor: page_image_anchor,
    width: page_image_width,
    height: page_image_height,
    dx: page_image_dx,
    dy: page_image_dy,
  )

  align(center, text(22pt, weight: "bold", title))

  if subtitle != none and subtitle != "" {
    v(0.5em)
    align(center, text(12pt, subtitle))
  }

  if degree != none and degree != "" {
    v(0.4em)
    align(center, degree)
  }

  if program != none and program != "" {
    align(center, program)
  }

  if institution != none and institution != "" {
    align(center, institution)
  }

  if faculty != none and faculty != "" {
    align(center, faculty)
  }

  v(2.3em)

  table(
    columns: (auto, 1fr),
    align: (left, left),
    stroke: none,
    ..info_cells,
  )

  render_title_page_footer_notes(
    show_cover_description: show_cover_description,
    cover_description: cover_description,
    show_confidentiality_statement: show_confidentiality_statement,
    confidentiality_statement: confidentiality_statement,
  )
}

#let title_page_formal_variant(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  date: none,
  degree: none,
  program: none,
  faculty: none,
  institution: none,
  defense_date: none,
  supervisors: (),
  committee: (),
  show_contributor_affiliations: true,
  show_cover_description: false,
  cover_description: none,
  show_confidentiality_statement: false,
  confidentiality_statement: none,
  page_image: none,
  page_image_anchor: none,
  page_image_width: none,
  page_image_height: none,
  page_image_dx: none,
  page_image_dy: none,
) = {
  let author_line = render_comma_list(authors)
  let affiliation_lines = render_lines(affiliations)
  let info_cells = build_title_page_info_cells(
    authors: authors,
    date: date,
    defense_date: defense_date,
    supervisors: supervisors,
    committee: committee,
    show_contributor_affiliations: show_contributor_affiliations,
  )
  let has_degree_line = degree != none and degree != ""
  let has_institution_line = institution != none and institution != ""
  let has_program_line = program != none and program != ""
  let has_faculty_line = faculty != none and faculty != ""
  let has_defense_line = defense_date != none and defense_date != ""

  render_title_page_image(
    image_path: page_image,
    anchor: page_image_anchor,
    width: page_image_width,
    height: page_image_height,
    dx: page_image_dx,
    dy: page_image_dy,
  )

  align(center, text(24pt, weight: "bold", title))

  if subtitle != none and subtitle != "" {
    v(0.6em)
    align(center, text(13pt, subtitle))
  }

  if author_line != "" {
    v(1.1em)
    align(center, text(10.5pt, fill: rgb("#666666"), "by"))
    v(0.35em)
    align(center, text(14pt, weight: "medium", author_line))
  }

  if affiliation_lines != "" {
    v(0.45em)
    align(center, text(10.5pt, fill: rgb("#555555"), affiliation_lines))
  }

  if has_degree_line or has_institution_line or has_program_line or has_faculty_line or has_defense_line {
    v(1.2em)
  }

  if has_degree_line {
    align(center, [to obtain the degree of #degree])
  }

  if has_program_line {
    align(center, program)
  }

  if has_faculty_line {
    align(center, faculty)
  }

  if has_institution_line {
    align(center, [at the #institution])
  }

  if has_defense_line {
    align(center, [to be defended publicly on #defense_date.])
  }

  v(2.1em)

  table(
    columns: (auto, 1fr),
    align: (left, left),
    stroke: none,
    ..info_cells,
  )

  render_title_page_footer_notes(
    show_cover_description: show_cover_description,
    cover_description: cover_description,
    show_confidentiality_statement: show_confidentiality_statement,
    confidentiality_statement: confidentiality_statement,
  )
}

#let title_page_custom(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  date: none,
  degree: none,
  program: none,
  faculty: none,
  institution: none,
  defense_date: none,
  supervisors: (),
  committee: (),
  show_contributor_affiliations: true,
  show_cover_description: false,
  cover_description: none,
  show_confidentiality_statement: false,
  confidentiality_statement: none,
  page_image: none,
  page_image_anchor: none,
  page_image_width: none,
  page_image_height: none,
  page_image_dx: none,
  page_image_dy: none,
) = {
  // Custom entry point: replace this with your own title-page implementation.
  title_page_formal_variant(
    title,
    subtitle: subtitle,
    authors: authors,
    affiliations: affiliations,
    date: date,
    degree: degree,
    program: program,
    faculty: faculty,
    institution: institution,
    defense_date: defense_date,
    supervisors: supervisors,
    committee: committee,
    show_contributor_affiliations: show_contributor_affiliations,
    show_cover_description: show_cover_description,
    cover_description: cover_description,
    show_confidentiality_statement: show_confidentiality_statement,
    confidentiality_statement: confidentiality_statement,
    page_image: page_image,
    page_image_anchor: page_image_anchor,
    page_image_width: page_image_width,
    page_image_height: page_image_height,
    page_image_dx: page_image_dx,
    page_image_dy: page_image_dy,
  )
}

#let title_page(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  date: none,
  degree: none,
  program: none,
  faculty: none,
  institution: none,
  defense_date: none,
  supervisors: (),
  committee: (),
  show_contributor_affiliations: true,
  logo: none,
  variant: "basic",
  start_on_new_page: false,
  show_cover_description: false,
  cover_description: none,
  show_confidentiality_statement: false,
  confidentiality_statement: "This thesis is confidential and cannot be made public.",
  page_image: none,
  page_image_anchor: none,
  page_image_width: none,
  page_image_height: none,
  page_image_dx: none,
  page_image_dy: none,
) = {
  let mode = resolve_title_page_variant(variant)

  if start_on_new_page {
    pagebreak()
  }

  if logo != none {
    place(bottom + center, dy: -0.9cm, image(logo, width: 1.9cm))
  }

  if mode == "basic" {
    title_page_basic_variant(
      title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      date: date,
      degree: degree,
      program: program,
      faculty: faculty,
      institution: institution,
      defense_date: defense_date,
      supervisors: supervisors,
      committee: committee,
      show_contributor_affiliations: show_contributor_affiliations,
      show_cover_description: show_cover_description,
      cover_description: cover_description,
      show_confidentiality_statement: show_confidentiality_statement,
      confidentiality_statement: confidentiality_statement,
      page_image: page_image,
      page_image_anchor: page_image_anchor,
      page_image_width: page_image_width,
      page_image_height: page_image_height,
      page_image_dx: page_image_dx,
      page_image_dy: page_image_dy,
    )
  } else if mode == "formal" {
    title_page_formal_variant(
      title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      date: date,
      degree: degree,
      program: program,
      faculty: faculty,
      institution: institution,
      defense_date: defense_date,
      supervisors: supervisors,
      committee: committee,
      show_contributor_affiliations: show_contributor_affiliations,
      show_cover_description: show_cover_description,
      cover_description: cover_description,
      show_confidentiality_statement: show_confidentiality_statement,
      confidentiality_statement: confidentiality_statement,
      page_image: page_image,
      page_image_anchor: page_image_anchor,
      page_image_width: page_image_width,
      page_image_height: page_image_height,
      page_image_dx: page_image_dx,
      page_image_dy: page_image_dy,
    )
  } else {
    title_page_custom(
      title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      date: date,
      degree: degree,
      program: program,
      faculty: faculty,
      institution: institution,
      defense_date: defense_date,
      supervisors: supervisors,
      committee: committee,
      show_contributor_affiliations: show_contributor_affiliations,
      show_cover_description: show_cover_description,
      cover_description: cover_description,
      show_confidentiality_statement: show_confidentiality_statement,
      confidentiality_statement: confidentiality_statement,
      page_image: page_image,
      page_image_anchor: page_image_anchor,
      page_image_width: page_image_width,
      page_image_height: page_image_height,
      page_image_dx: page_image_dx,
      page_image_dy: page_image_dy,
    )
  }

}
