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

#let has_renderable_content(value) = {
  if value == none {
    false
  } else if type(value) == str {
    str(value) != ""
  } else if type(value) == content {
    true
  } else if value == () {
    false
  } else {
    true
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

#let format_title_page_date(value) = {
  if value == none or str(value) == "" {
    none
  } else {
    let raw = str(value)
    let parts = raw.split("-")
    if parts.len() == 3 {
      let day = if parts.at(0).len() > 1 and parts.at(0).starts-with("0") {
        parts.at(0).slice(1)
      } else {
        parts.at(0)
      }
      let month = if parts.at(1).len() > 1 and parts.at(1).starts-with("0") {
        parts.at(1).slice(1)
      } else {
        parts.at(1)
      }
      let year = parts.at(2)
      let month_name = if month == "1" {
        "January"
      } else if month == "2" {
        "February"
      } else if month == "3" {
        "March"
      } else if month == "4" {
        "April"
      } else if month == "5" {
        "May"
      } else if month == "6" {
        "June"
      } else if month == "7" {
        "July"
      } else if month == "8" {
        "August"
      } else if month == "9" {
        "September"
      } else if month == "10" {
        "October"
      } else if month == "11" {
        "November"
      } else if month == "12" {
        "December"
      } else {
        none
      }
      if month_name == none {
        raw
      } else {
        month_name + " " + day + ", " + year
      }
    } else {
      raw
    }
  }
}

#let no_break_string(value) = {
  if value == none {
    ""
  } else {
    str(value).replace(" ", " ")
  }
}

#let render_title_page_label_cell(label) = {
  text(weight: "semibold", fill: rgb("#555555"), label + ":")
}

#let title_page_info_row(label, value) = {
  if has_renderable_content(value) {
    (render_title_page_label_cell(label), value,)
  } else {
    ()
  }
}

#let render_title_page_basic_heading_line(
  content,
  heading_alignment: "center",
) = {
  let alignment = if str(heading_alignment) == "left" {
    left
  } else {
    center
  }
  set par(justify: false)
  set text(hyphenate: false)
  if str(heading_alignment) == "left" {
    align(left, block(width: 100%, content))
  } else {
    align(alignment, content)
  }
}

#let render_title_page_info_table(
  info_cells,
  table_alignment: "left",
) = {
  let resolved_label_alignment = if str(table_alignment) == "center" {
    right
  } else {
    left
  }
  let content_width = 8.8em + 1.3em + 24em
  let table_content = table(
    columns: (8.8em, 24em),
    align: (resolved_label_alignment + top, left + top),
    inset: 0pt,
    stroke: none,
    column-gutter: 1.3em,
    row-gutter: 0.6em,
    ..info_cells,
  )

  if str(table_alignment) == "center" {
    align(center, box(width: content_width, table_content))
  } else {
    align(left, block(width: 100%, table_content))
  }
}

#let render_title_page_basic_bottom_block(
  block_alignment: "left",
  confidentiality_statement: none,
  isbn: none,
) = {
  let block_items = ()
  if confidentiality_statement != none and str(confidentiality_statement) != "" {
    block_items += ([#text(size: 10pt, smallcaps(str(confidentiality_statement)))],)
  }
  if isbn != none and isbn != "" {
    block_items += ([#text(size: 10pt, [ISBN: #isbn])],)
  }

  if block_items.len() > 0 {
    let stack_body = stack(dir: ttb, spacing: 0.8em, ..block_items)
    v(1fr)
    if str(block_alignment) == "center" {
      align(center, stack_body)
    } else {
      align(left, block(width: 100%, stack_body))
    }
  }
}

#let render_title_page_formal_statement(
  degree: none,
  program: none,
  track: none,
  faculty: none,
  institution: none,
  defense_date: none,
) = {
  let sentence = ""
  let degree_text = no_break_string(degree)
  let program_text = no_break_string(program)
  let track_text = no_break_string(track)
  let faculty_text = no_break_string(faculty)
  let institution_text = no_break_string(institution)
  let defense_date_text = no_break_string(defense_date)

  if degree != none and str(degree) != "" {
    sentence = "to obtain the degree of " + degree_text
  }

  if program != none and str(program) != "" {
    if sentence == "" {
      sentence = program_text
    } else {
      sentence += " in " + program_text
    }
  }

  if track != none and str(track) != "" {
    if program != none and str(program) != "" {
      sentence += ", on the track " + track_text
    } else if sentence == "" {
      sentence = "on the track " + track_text
    } else {
      sentence += ", on the track " + track_text
    }
  }

  if faculty != none and str(faculty) != "" {
    if sentence == "" {
      sentence = faculty_text
    } else {
      sentence += ", at the " + faculty_text
    }
  }

  if institution != none and str(institution) != "" {
    if sentence == "" {
      sentence = institution_text
    } else {
      sentence += ", " + institution_text
    }
  }

  if defense_date != none and str(defense_date) != "" {
    if sentence == "" {
      sentence = "to be defended on " + defense_date_text
    } else {
      sentence += ", to be defended on " + defense_date_text
    }
  }

  if sentence == "" {
    none
  } else {
    align(center, block(width: 72%, [
      #set par(justify: false)
      #set text(hyphenate: false)
      #text(size: 10.5pt, fill: rgb("#555555"), sentence)
    ]))
  }
}

#let render_title_page_formal_info_rows(
  publication_date: none,
  cover_description: none,
) = {
  (
    title_page_info_row("Publication date", publication_date) +
    title_page_info_row("Cover", cover_description)
  )
}

#let render_title_page_formal_bottom_block(
  confidentiality_statement: none,
  isbn: none,
) = {
  render_title_page_basic_bottom_block(
    block_alignment: "center",
    confidentiality_statement: confidentiality_statement,
    isbn: isbn,
  )
}

#let title_page_basic_variant(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  isbn: none,
  date: none,
  degree: none,
  program: none,
  track: none,
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
  title_alignment: "center",
  table_alignment: "left",
  bottom_block_alignment: "left",
) = {
  let author_line = render_comma_list(authors)
  let author_affiliation_line = render_lines(affiliations)
  let author_cell = render_contributor_entries(
    if author_line == "" {
      ()
    } else {
      ((name: author_line, affiliation: author_affiliation_line),)
    },
    show_affiliations: true,
  )
  let supervisor_cell = render_contributor_entries(
    supervisors,
    show_affiliations: show_contributor_affiliations,
  )
  let committee_cell = render_contributor_entries(
    committee,
    show_affiliations: show_contributor_affiliations,
  )
  let author_label = if count_items(authors) > 1 { "Authors" } else { "Author" }
  let supervisor_label = if count_items(supervisors) > 1 { "Supervisors" } else { "Supervisor" }
  let committee_label = "Committee"
  let cover_cell = if show_cover_description and cover_description != none and str(cover_description) != "" {
    str(cover_description)
  } else {
    none
  }
  let bottom_confidentiality = if show_confidentiality_statement and confidentiality_statement != none and str(confidentiality_statement) != "" {
    confidentiality_statement
  } else {
    none
  }
  let author_rows = title_page_info_row(author_label, author_cell)
  let academic_rows = (
    title_page_info_row("Degree", degree) +
    title_page_info_row("Program", program) +
    title_page_info_row("Track", track) +
    title_page_info_row("Faculty", faculty) +
    title_page_info_row("Institution", institution)
  )
  let people_rows = (
    title_page_info_row(supervisor_label, supervisor_cell) +
    title_page_info_row(committee_label, committee_cell)
  )
  let date_rows = (
    title_page_info_row("Publication date", format_title_page_date(date)) +
    title_page_info_row("Defense date", defense_date)
  )
  let cover_rows = title_page_info_row("Cover", cover_cell)

  render_title_page_basic_heading_line(
    text(22pt, weight: "bold", title),
    heading_alignment: title_alignment,
  )

  if subtitle != none and subtitle != "" {
    v(0.5em)
    render_title_page_basic_heading_line(
      text(12pt, subtitle),
      heading_alignment: title_alignment,
    )
  }

  v(3.5cm)

  if author_rows != () {
    render_title_page_info_table(
      author_rows,
      table_alignment: table_alignment,
    )
  }

  if academic_rows != () {
    if author_rows != () {
      v(1.1em)
    }
    render_title_page_info_table(
      academic_rows,
      table_alignment: table_alignment,
    )
  }

  if people_rows != () {
    if author_rows != () or academic_rows != () {
      v(1.1em)
    }
    render_title_page_info_table(
      people_rows,
      table_alignment: table_alignment,
    )
  }

  if date_rows != () {
    if author_rows != () or academic_rows != () or people_rows != () {
      v(1.1em)
    }
    render_title_page_info_table(
      date_rows,
      table_alignment: table_alignment,
    )
  }

  if cover_rows != () {
    if author_rows != () or academic_rows != () or people_rows != () or date_rows != () {
      v(1.8em)
    }
    render_title_page_info_table(
      cover_rows,
      table_alignment: table_alignment,
    )
  }

  render_title_page_basic_bottom_block(
    block_alignment: bottom_block_alignment,
    confidentiality_statement: bottom_confidentiality,
    isbn: isbn,
  )
}

#let title_page_formal_variant(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  isbn: none,
  date: none,
  degree: none,
  program: none,
  track: none,
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
  let supervisor_label = if count_items(supervisors) > 1 { "Supervisors" } else { "Supervisor" }
  let people_rows = (
    title_page_info_row(supervisor_label, supervisor_cell) +
    title_page_info_row("Committee", committee_cell)
  )
  let note_rows = render_title_page_formal_info_rows(
    publication_date: format_title_page_date(date),
    cover_description: if show_cover_description and cover_description != none and str(cover_description) != "" {
      str(cover_description)
    } else {
      none
    },
  )
  let formal_confidentiality_statement = if show_confidentiality_statement and confidentiality_statement != none and str(confidentiality_statement) != "" {
    confidentiality_statement
  } else {
    none
  }
  let formal_statement = render_title_page_formal_statement(
    degree: degree,
    program: program,
    track: track,
    faculty: faculty,
    institution: institution,
    defense_date: defense_date,
  )

  render_title_page_basic_heading_line(
    text(30pt, weight: "bold", title),
    heading_alignment: "center",
  )

  if subtitle != none and subtitle != "" {
    v(0.75em)
    render_title_page_basic_heading_line(
      text(16pt, subtitle),
      heading_alignment: "center",
    )
  }

  if author_line != "" {
    v(1.35em)
    align(center, text(10.5pt, fill: rgb("#666666"), "by"))
    v(0.3em)
    render_title_page_basic_heading_line(
      text(16pt, weight: "medium", author_line),
      heading_alignment: "center",
    )
  }

  if formal_statement != none {
    v(1.4em)
    formal_statement
  }

  if people_rows != () {
    v(2.1em)
    render_title_page_info_table(
      people_rows,
      table_alignment: "center",
    )
  }

  if note_rows != () {
    if people_rows != () {
      v(1.2em)
    } else {
      v(2.1em)
    }
    render_title_page_info_table(
      note_rows,
      table_alignment: "center",
    )
  }

  render_title_page_formal_bottom_block(
    confidentiality_statement: formal_confidentiality_statement,
    isbn: isbn,
  )
}

#let title_page_custom(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  isbn: none,
  date: none,
  degree: none,
  program: none,
  track: none,
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
) = {
  // Custom entry point: replace this with your own title-page implementation.
  title_page_formal_variant(
    title,
    subtitle: subtitle,
    authors: authors,
    affiliations: affiliations,
    isbn: isbn,
    date: date,
    degree: degree,
    program: program,
    track: track,
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
  )
}

#let title_page(
  title,
  subtitle: none,
  authors: (),
  affiliations: (),
  isbn: none,
  date: none,
  degree: none,
  program: none,
  track: none,
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
  basic_title_alignment: "center",
  basic_table_alignment: "left",
  basic_bottom_block_alignment: "left",
  logo_alignment: "center",
) = {
  let mode = resolve_title_page_variant(variant)

  if start_on_new_page {
    pagebreak()
  }

  if logo != none {
    let logo_anchor = if mode == "basic" and str(logo_alignment) == "left" {
      bottom + left
    } else {
      bottom + center
    }
    place(logo_anchor, dy: -0.9cm, image(logo, width: 1.9cm))
  }

  if mode == "basic" {
    title_page_basic_variant(
      title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      isbn: isbn,
      date: date,
      degree: degree,
      program: program,
      track: track,
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
      title_alignment: basic_title_alignment,
      table_alignment: basic_table_alignment,
      bottom_block_alignment: basic_bottom_block_alignment,
    )
  } else if mode == "formal" {
    title_page_formal_variant(
      title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      isbn: isbn,
      date: date,
      degree: degree,
      program: program,
      track: track,
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
    )
  } else {
    title_page_custom(
      title,
      subtitle: subtitle,
      authors: authors,
      affiliations: affiliations,
      isbn: isbn,
      date: date,
      degree: degree,
      program: program,
      track: track,
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
    )
  }

}
