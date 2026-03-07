#let frontmatter_section(title, content) = {
  if content != none and content != "" {
    
    align(center, text(15pt, weight: "bold", title))
    v(1.2em)
    content
  }
}

#let frontmatter_other(title, content) = {
  if content != none and content != "" {
    align(left, text(12pt, weight: "bold", title) + ": " + content)
    
  }
}