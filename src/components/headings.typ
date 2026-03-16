#let configure_headings(heading_color,body) = {
  show heading: set text(fill: heading_color, weight: "semibold")
  show heading.where(level: 1): set block(above: 1.5em, below: 0.8em)
  show heading.where(level: 2): set block(above: 1.1em, below: 0.6em)
  body
}

  
