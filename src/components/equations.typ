
// numbering of headings
  #set heading(numbering: (..args) => {
    let nums = args.pos()
    let level = nums.len()
    if level == 1 {[#numbering("1.", ..nums)]} else {[#numbering("1.1.1", ..nums)]}
    },
  )   
    
  //RESETING NUMBERING
#show heading.where(level: 1): it => {
  pagebreak()
  // Reset all counters with a new chapter
  counter(figure).update(0)                // all figures (irrespective of kind)
  counter(figure.where(kind: table)).update(0) // specific for tables
  counter(math.equation).update(0)
  
  it
}


// end numbering of headings

#set math.equation(numbering: (..args) => {
  let chapter = counter(heading).display((..nums) => nums.pos().at(0))
  [(#chapter.#numbering("1)", ..args.pos())]
})

#show math.equation: set block(spacing: 1em)

#body