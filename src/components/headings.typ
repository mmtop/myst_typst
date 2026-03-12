#let configure_headings(color) = {
  // numbering of headings


  show heading: set text(fill: color, weight: "semibold")
  show heading.where(level: 1): set block(above: 1.5em, below: 0.8em)
  show heading.where(level: 2): set block(above: 1.1em, below: 0.6em)
  // numbering 1

//   show heading.where(level: 1): it => {
//   pagebreak()
//   // Reset all counters with a new chapter
//   counter(figure).update(0)                // all figures (irrespective of kind)
//   counter(figure.where(kind: table)).update(0) // specific for tables
//   counter(math.equation).update(0)
  
//   it
// }
}

  
