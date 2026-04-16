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

#let resolve_cover_page_variant(variant) = {
  let normalized = str(variant)
  if normalized == "1" or normalized == "simple" {
    "simple"
  } else if normalized == "2" or normalized == "graphical" {
    "graphical"
  } else if normalized == "3" or normalized == "custom" {
    "custom"
  } else {
    panic("Invalid cover_page_variant '" + normalized + "'. Use '1'/'simple', '2'/'graphical', or '3'/'custom'.")
  }
}

#let render_multiline_cover_text(value) = {
  if value == none or value == "" {
    []
  } else {
    let lines = str(value).split("\n")
    let output = []
    for (index, line) in lines.enumerate() {
      if index > 0 {
        output += [#linebreak()]
      }
      output += [#line]
    }
    output
  }
}

#let cover_page_simple(title, subtitle: none, authors: (), show_subtitle: true) = {
  set page(numbering: none)
  set par(first-line-indent: 0pt, justify: false)
  let author_line = render_comma_list(authors)
  v(12%)
  align(left, [
    #text(size: 40pt, weight: "bold", title)
    #if show_subtitle and subtitle != none and subtitle != "" [
      #v(0.35em)
      #text(size: 18pt, weight: "regular", subtitle)
    ]
    #v(0.7em)
    #line(length: 55%, stroke: 1.2pt + rgb("#666666"))
    #if author_line != "" [
      #v(1.0em)
      #text(size: 18pt, weight: "medium", author_line)
    ]
  ])
}

#let cover_page_graphical(
  title,
  subtitle: none,
  authors: (),
  image_path: none,
  box_opacity_pct: 55,
  box_fill: auto,
  title_text_fill: auto,
  bottom_text_fill: auto,
  title_weight: "regular",
  subtitle_weight: "regular",
  author_weight: "regular",
  show_subtitle: true,
  page_alignment: "left",
  title_box_text: none,
  isbn: none,
  isbn_position: "titlebox",
  logo_text: none,
  logo_dx: 0cm,
  logo_dy: 0cm,
  bottom_text_dx: 0cm,
  bottom_text_dy: 0cm,
  institution_line: none,
  logo: none,
) = context {
  if image_path == none {
    cover_page_simple(title, subtitle: subtitle, authors: authors, show_subtitle: show_subtitle)
  } else {
    let pw = page.width
    let ph = page.height
    let author_line = render_comma_list(authors)
    let resolved_box_fill = if box_fill == auto {
      let opacity_pct = if box_opacity_pct < 0 {
        0
      } else if box_opacity_pct > 100 {
        100
      } else {
        box_opacity_pct
      }
      color.hsv(0deg, 0%, 0%, opacity_pct * 1%)
    } else {
      box_fill
    }
    let resolved_title_text_fill = if title_text_fill == auto { white } else { title_text_fill }
    let resolved_bottom_text_fill = if bottom_text_fill == auto { resolved_title_text_fill } else { bottom_text_fill }
    let resolved_content_alignment = if str(page_alignment) == "center" { center } else { left }
    let render_bottom_isbn = isbn != none and isbn != "" and str(isbn_position) == "logo"
    let render_titlebox_isbn = isbn != none and isbn != "" and str(isbn_position) != "logo"

    set image(width: pw, height: ph, fit: "cover")
    set page(background: image(image_path), margin: 0pt)
    set par(first-line-indent: 0pt, justify: false)

    place(dy: 2cm, rect(
      width: 100%,
      inset: 30pt,
      fill: resolved_box_fill,
    )[
      #align(resolved_content_alignment, [
        #text(fill: resolved_title_text_fill, size: 40pt, weight: title_weight, title)

        #if show_subtitle and subtitle != none and subtitle != "" [
          #v(0.5em)
          #text(fill: resolved_title_text_fill, size: 20pt, weight: subtitle_weight, subtitle)
        ]

        #if author_line != "" [
          #v(3.5em)
          #text(fill: resolved_title_text_fill, size: 30pt, weight: author_weight, author_line)
        ]

        #if title_box_text != none and title_box_text != "" [
          #v(0.8em)
          #text(fill: resolved_title_text_fill, size: 12pt, weight: "regular", render_multiline_cover_text(title_box_text))
        ]

        #if render_titlebox_isbn [
          #v(0.8em)
          #text(fill: resolved_title_text_fill, size: 10pt, weight: "regular", [ISBN: #isbn])
        ]
      ])
    ])

    if logo != none or (logo_text != none and logo_text != "") or render_bottom_isbn {
      place(bottom + left, dy: -1.2cm, box(width: pw, inset: (left: 30pt, right: 30pt))[
        #align(resolved_content_alignment, [
          #if logo != none [
            #move(dx: logo_dx, dy: logo_dy)[
              #image(
                logo,
                width: 8cm,
                height: auto,
                fit: "contain",
              )
            ]
          ]

          #if logo_text != none and logo_text != "" or render_bottom_isbn [
            #v(0.2em)
            #move(dx: bottom_text_dx, dy: bottom_text_dy)[
              #if logo_text != none and logo_text != "" [
                #text(fill: resolved_bottom_text_fill, size: 10pt, weight: "regular", render_multiline_cover_text(logo_text))
              ]

              #if render_bottom_isbn [
                #if logo_text != none and logo_text != "" [
                  #v(0.5em)
                ]
                #text(fill: resolved_bottom_text_fill, size: 10pt, weight: "regular", [ISBN: #isbn])
              ]
            ]
          ]
        ])
      ])
    }
  }
}

#let cover_page_custom(
  title,
  subtitle: none,
  authors: (),
  image_path: none,
  box_opacity_pct: 55,
  box_fill: auto,
  title_text_fill: auto,
  bottom_text_fill: auto,
  title_weight: "regular",
  subtitle_weight: "regular",
  author_weight: "regular",
  show_subtitle: true,
  page_alignment: "left",
  title_box_text: none,
  isbn: none,
  isbn_position: "titlebox",
  logo_text: none,
  logo_dx: 0cm,
  logo_dy: 0cm,
  bottom_text_dx: 0cm,
  bottom_text_dy: 0cm,
  institution_line: none,
  logo: none,
) = {
  // Custom entry point: replace this with your own cover implementation.
  cover_page_simple(title, subtitle: subtitle, authors: authors, show_subtitle: show_subtitle)
}

#let cover_page(
  title,
  subtitle: none,
  authors: (),
  variant: "simple",
  image_path: none,
  box_opacity_pct: 55,
  box_fill: auto,
  title_text_fill: auto,
  bottom_text_fill: auto,
  title_weight: "regular",
  subtitle_weight: "regular",
  author_weight: "regular",
  show_subtitle: true,
  page_alignment: "left",
  title_box_text: none,
  isbn: none,
  isbn_position: "titlebox",
  logo_text: none,
  logo_dx: 0cm,
  logo_dy: 0cm,
  bottom_text_dx: 0cm,
  bottom_text_dy: 0cm,
  institution_line: none,
  logo: none,
) = {
  let mode = resolve_cover_page_variant(variant)
  if mode == "simple" {
    cover_page_simple(title, subtitle: subtitle, authors: authors, show_subtitle: show_subtitle)
  } else if mode == "graphical" {
    cover_page_graphical(
      title,
      subtitle: subtitle,
      authors: authors,
      image_path: image_path,
      box_opacity_pct: box_opacity_pct,
      box_fill: box_fill,
      title_text_fill: title_text_fill,
      bottom_text_fill: bottom_text_fill,
      title_weight: title_weight,
      subtitle_weight: subtitle_weight,
      author_weight: author_weight,
      show_subtitle: show_subtitle,
      page_alignment: page_alignment,
      title_box_text: title_box_text,
      isbn: isbn,
      isbn_position: isbn_position,
      logo_text: logo_text,
      logo_dx: logo_dx,
      logo_dy: logo_dy,
      bottom_text_dx: bottom_text_dx,
      bottom_text_dy: bottom_text_dy,
      institution_line: institution_line,
      logo: logo,
    )
  } else {
    cover_page_custom(
      title,
      subtitle: subtitle,
      authors: authors,
      image_path: image_path,
      box_opacity_pct: box_opacity_pct,
      box_fill: box_fill,
      title_text_fill: title_text_fill,
      bottom_text_fill: bottom_text_fill,
      title_weight: title_weight,
      subtitle_weight: subtitle_weight,
      author_weight: author_weight,
      show_subtitle: show_subtitle,
      page_alignment: page_alignment,
      title_box_text: title_box_text,
      isbn: isbn,
      isbn_position: isbn_position,
      logo_text: logo_text,
      logo_dx: logo_dx,
      logo_dy: logo_dy,
      bottom_text_dx: bottom_text_dx,
      bottom_text_dy: bottom_text_dy,
      institution_line: institution_line,
      logo: logo,
    )
  }
}
