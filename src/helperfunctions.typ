
// Keeps logo and image paths working when this template is built on different systems.
#let resolve_asset_path(path, levels_up: 1) = {
       if path == none {  none   }
  else if type(path) != str {     path  }
  else {
    // MyST can emit Windows-style separators such as `files\logo.svg`.
    // Normalize first, then rebase bare relative paths for nested layout files.
    let normalized = str(path).replace("\\", "/")
         if normalized.starts-with("/") or normalized.starts-with("./") or normalized.starts-with("../") or normalized.contains(":/") { normalized }
    else if levels_up == 2 {    "../../" + normalized  }
    else if levels_up == 1 {     "../" + normalized   }
    else {     normalized  }
  }
}

// Turns a list like several author names or keywords into one comma-separated line.
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

