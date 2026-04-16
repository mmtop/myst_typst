#let setup-numbering(body) = {
  set heading(numbering: (..args) => {
    let nums = args.pos()
    let level = nums.len()
    if level == 1 {
      [#numbering("1.", ..nums)]
    } else {
      [#numbering("1.1.1", ..nums)]
    }
  })

  // reset counters at each new chapter
  show heading.where(level: 1): it => {
    counter(figure).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(math.equation).update(0)
    it
  }

  // equation numbering with chapter prefix
  set math.equation(numbering: (..args) => {
    let chapter = counter(heading).display((..nums) => nums.pos().at(0))
    [(#chapter.#numbering("1)", ..args.pos())]
  })

  set figure(numbering: (..args) => {
    let chapter = counter(heading).display((..nums) => nums.pos().at(0))
    [#chapter.#numbering("1", ..args.pos())]
  })

  body
}