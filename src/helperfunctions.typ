
#let require_non_empty(value, field_name, fallback: none) = {
  if value == none or value == "" {
    if fallback != none { fallback } else {
      panic("Missing required metadata: " + field_name)
    }
  } else { value }
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
      if index > 0 { output += ", "  }
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
