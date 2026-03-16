#let configure_figures(body) = {

  show figure.caption: it => {
    set text(size: 9pt)
    set align(left)
    set par(justify: true)
    it
  }
    body
}
