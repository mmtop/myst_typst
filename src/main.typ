#import "layout/cover.typ": cover_page
#import "layout/titlepage.typ": title_page, contributors_by_group
#import "layout/frontmatter.typ": render_frontmatter
#import "layout/bibliography.typ": render_bibliography

// Use this file as the main Typst layout entry point for the template.
// It receives normalized metadata, part files, and export options from template.typ,
// applies the global page and text styling, and then assembles the cover page,
// title page, front matter, main content, and bibliography.

////////////////////////////////////////////////////////////////////////
// This is the main template function that assembles the whole document.
////////////////////////////////////////////////////////////////////////

#let thesis_template(
  // Shared document metadata.
  title: "Untitled Report",
  subtitle: none,
  authors: (),
  isbn: none,
  contributors: (),
  affiliation_catalog: (),
  affiliations: (),
  date: none,
  doi: none,
  keywords: (),

  // Template options for layout and content control. 
  // These are all optional and they are specified in the options.yml file, and they have to be routed via other template files to get here - they are all documented in the template.yml file where they are defined as part of the template configuration.
  thesis_degree: none,
  thesis_program: none,
  thesis_track: none,
  thesis_faculty: none,
  thesis_institution: none,
  thesis_defense_date: none,

  // Optional front-matter part files.
  abstract: none,
  preface: none,
  acknowledgements: none,
  dedication: none,
  colophon: none,

 
  /////////////////////////////////////////////////////////
  // This section defines global defaults for the document.
  /////////////////////////////////////////////////////////

  // Page layout.
  paper_size: "a4",
  margin_top_cm: 2.5cm,
  margin_bottom_cm: 2.5cm,
  margin_left_cm: 2.5cm,
  margin_right_cm: 2.5cm,

  // Typography.
  // The template default to Typst's built-in font stack deliberately as a typographic choice.
  // Also, it ensures that fresh installs work without extra setup. 
  // Bundled recommendations live in src/assets/fonts:
  // STIX Two Text + STIX Two Math for legacy serif and math, known from TeX documents,
  // Atkinson Hyperlegible Next and Atkinson Hyperlegible Mono for accessible sans serif body and code fonts - recommended for documents that may be read by people with dyslexia and visual impairments.
  // JetBrains Mono is the recommended code font in all cases for its readability and aesthetics, and it is used as the default monospace font for all documents.
  font_body: "Libertinus Serif",
  font_mono: "DejaVu Sans Mono",
  font_math: "New Computer Modern Math",
  font_size_pt: 11pt,
  line_spacing_em: 0.7em,


  // This is an example how a shared assets (branding) can be defined in the main template and then used in multiple layout files, including the cover page and the title page.
  logo: "src/assets/brand_assets/logo.svg",

 // This section defines defaults decisions for some export toggles for the front matter design.
  show_cover_full: true,
  show_title_page: true,
  show_contributor_affiliations: true,
  frontmatter_order: ("abstract", "preface", "acknowledgements", "dedication", "colophon"),
  show_toc: true,
  show_list_of_figures: false,
  show_list_of_tables: false,
  toc_depth: 2,
  show_verso_blank_page_statement: false,
  verso_blank_page_statement: "This page is intentionally left blank.",

  // Cover page options.
  cover_page_variant: "simple",
  show_cover_subtitle: true,
  cover_background_image: "src/assets/template_figures/defaultcover.jpg",
  cover_graphical_appearance: "white-on-dark",
  cover_graphical_alignment: "left",
  cover_title_text_color: none,
  cover_bottom_text_color: none,
  cover_title_weight: "regular",
  cover_subtitle_weight: "regular",
  cover_author_weight: "regular",
  cover_title_box_color: none,
  cover_title_box_text: none,
  cover_title_box_opacity_pct: 55,
  cover_isbn_position: "titlebox",
  cover_logo_variant: none,
  cover_logo_white: "src/assets/brand_assets/international-logo_white_rgb.svg",
  cover_logo_black: "src/assets/brand_assets/international-logo_black_rgb.svg",
  cover_logo_text: none,
  cover_logo_dx_cm: 0cm,
  cover_logo_dy_cm: 0cm,
  cover_bottom_text_dx_cm: 0cm,
  cover_bottom_text_dy_cm: 0cm,

  // Title page.
  title_page_variant: "basic",
  title_page_basic_title_alignment: "center",
  title_page_basic_table_alignment: "left",
  title_page_basic_bottom_block_alignment: "left",
  title_page_logo_alignment: "center",
  show_title_page_cover_description: false,
  title_page_cover_description: none,
  show_title_page_confidentiality_statement: false,
  title_page_confidentiality_statement: "This thesis is confidential and cannot be made public.",
  title_page_formal_statement: none,
  body,

  // Default bibliography options.
  bibliography_file: none,
  show_bibliography: true,
  bibliography_title: "Bibliography",
  bibliography_style: "chicago-author-date",
  bibliography_numbered_heading: false,

) = {


  // The resolve_* helpers interpret user deciscions(toggles, options and imports) and turn them into values that can be used in the layout blocks.
  
  // This resolve_asset_path helper normalizes Windows separators 
  // and relative paths so the same config values keep working locally 
  // and in GitHub template bundles. 
  // Asset paths may be used from this file or from nested layout files.
  let resolve_asset_path = (path, levels_up: 1) => {
    if path == none {
      none
    } else if type(path) != str {
      path
    } else {
      let normalized = str(path).replace("\\", "/")
      if normalized.starts-with("/") or normalized.starts-with("./") or normalized.starts-with("../") or normalized.contains(":/") {
        normalized
      } else if levels_up == 2 {
        "../../" + normalized
      } else if levels_up == 1 {
        "../" + normalized
      } else {
        normalized
      }
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // The following group of helpers resolves cover page, title page and front matter design options.
  let resolve_cover_appearance = appearance => {
    let normalized = str(appearance)
    if normalized == "white-on-dark" or normalized == "black-on-light" {
      normalized
    } else {
      panic("Invalid cover_graphical_appearance '" + normalized + "'. Use 'white-on-dark' or 'black-on-light'.")
    }
  }

  let resolve_black_white_choice = (value, option_name) => {
    if value == none or value == "" {
      panic("Option '" + option_name + "' must be 'white' or 'black'.")
    } else {
      let normalized = str(value)
      if normalized == "white" or normalized == "black" {
        normalized
      } else {
        panic("Invalid " + option_name + " '" + normalized + "'. Use 'white' or 'black'.")
      }
    }
  }

  let resolve_cover_color_choice = (value, option_name) => {
    if value == none or value == "" {
      panic("Option '" + option_name + "' must be 'white', 'black', or a hex color like '#f5f5f5'.")
    } else {
      let normalized = str(value)
      if normalized == "white" or normalized == "black" {
        normalized
      } else if normalized.starts-with("#") and (normalized.len() == 4 or normalized.len() == 7) {
        normalized
      } else if normalized.len() == 3 or normalized.len() == 6 {
        "#" + normalized
      } else {
        panic("Invalid " + option_name + " '" + normalized + "'. Use 'white', 'black', or a hex color like '#f5f5f5'.")
      }
    }
  }

  let resolve_cover_color_fill = (value, option_name) => {
    let normalized = resolve_cover_color_choice(value, option_name)
    if normalized == "white" {
      white
    } else if normalized == "black" {
      black
    } else {
      rgb(normalized)
    }
  }

  let resolve_left_center_choice = (value, option_name) => {
    let normalized = str(value)
    if normalized == "left" or normalized == "center" {
      normalized
    } else {
      panic("Invalid " + option_name + " '" + normalized + "'. Use 'left' or 'center'.")
    }
  }

  let resolve_cover_isbn_position = value => {
    let normalized = str(value)
    if normalized == "titlebox" or normalized == "logo" {
      normalized
    } else {
      panic("Invalid cover_isbn_position '" + normalized + "'. Use 'titlebox' or 'logo'.")
    }
  }

  ////////////////////////////////////////////////////////////////////////////////////
  // Some values are reused in multiple layout blocks, so they are resolved once here.
  let resolved_title = if title == none or title == "" { "Untitled Report" } else { title }
  let resolved_supervisors = contributors_by_group(contributors, "supervisor", affiliation_catalog)
  let resolved_committee = contributors_by_group(contributors, "committee", affiliation_catalog)
  let resolved_logo_for_layout = resolve_asset_path(logo, levels_up: 2)
  let resolved_cover_background_image = resolve_asset_path(cover_background_image, levels_up: 2)
  let resolved_cover_logo_white = resolve_asset_path(cover_logo_white, levels_up: 2)
  let resolved_cover_logo_black = resolve_asset_path(cover_logo_black, levels_up: 2)
  let resolved_cover_appearance = resolve_cover_appearance(cover_graphical_appearance)
  let resolved_cover_alignment = resolve_left_center_choice(cover_graphical_alignment, "cover_graphical_alignment")

  ///////////////////////////////////////////////////////////////////////////////////////////////
  // This group of helpers resolves the logic around the color scheme of the cover page variants.
  let resolved_cover_box_opacity_pct = if cover_title_box_opacity_pct < 0 {
    0
  } else if cover_title_box_opacity_pct > 100 {
    100
  } else {
    cover_title_box_opacity_pct
  }

  let resolved_cover_title_text_color_value = if cover_title_text_color != none and cover_title_text_color != "" {
    resolve_cover_color_choice(cover_title_text_color, "cover_title_text_color")
  } else if resolved_cover_appearance == "black-on-light" {
    "black"
  } else {
    "white"
  }

  let resolved_cover_title_box_color_value = if cover_title_box_color != none and cover_title_box_color != "" {
    resolve_cover_color_choice(cover_title_box_color, "cover_title_box_color")
  } else if resolved_cover_appearance == "black-on-light" {
    "white"
  } else {
    "black"
  }

  let resolved_cover_logo_tone = if cover_logo_variant != none and cover_logo_variant != "" {
    resolve_black_white_choice(cover_logo_variant, "cover_logo_variant")
  } else if resolved_cover_appearance == "black-on-light" {
    "black"
  } else {
    "white"
  }

  let resolved_cover_title_text_fill = resolve_cover_color_fill(resolved_cover_title_text_color_value, "cover_title_text_color")
  
  let resolved_cover_bottom_text_color_value = if cover_bottom_text_color != none and cover_bottom_text_color != "" {
    resolve_cover_color_choice(cover_bottom_text_color, "cover_bottom_text_color")
  } else {
    resolved_cover_title_text_color_value
  }

  let resolved_cover_bottom_text_fill = resolve_cover_color_fill(resolved_cover_bottom_text_color_value, "cover_bottom_text_color")

  let resolved_cover_title_box_fill = resolve_cover_color_fill(resolved_cover_title_box_color_value, "cover_title_box_color").transparentize((100 - resolved_cover_box_opacity_pct) * 1%)

  let resolved_cover_logo_for_layout = if resolved_cover_logo_tone == "black" {
    if resolved_cover_logo_black != none { resolved_cover_logo_black } else { resolved_logo_for_layout }
  } else {
    if resolved_cover_logo_white != none { resolved_cover_logo_white } else { resolved_logo_for_layout }
  }

  let resolved_cover_isbn_position = resolve_cover_isbn_position(cover_isbn_position)
  let resolved_title_page_basic_title_alignment = resolve_left_center_choice(title_page_basic_title_alignment, "title_page_basic_title_alignment")
  let resolved_title_page_basic_table_alignment = resolve_left_center_choice(title_page_basic_table_alignment, "title_page_basic_table_alignment")
  let resolved_title_page_basic_bottom_block_alignment = resolve_left_center_choice(title_page_basic_bottom_block_alignment, "title_page_basic_bottom_block_alignment")
  let resolved_title_page_logo_alignment = resolve_left_center_choice(title_page_logo_alignment, "title_page_logo_alignment")


  /////////////////////////////////////////////////////////////////////////////////
  // This helper ensures that the main matter "always" starts on a right-hand page. 
  // If the option to show a blank page statement is enabled, 
  // it adds a usual "intentinally blank" statement on the verso page 
  // instead of leaving it completely blank.
  let start_mainmatter_on_recto = (
    show_blank_statement: false,
    blank_statement: "This page is intentionally left blank.",
  ) => {
    if show_blank_statement {
      context {
        if calc.rem(here().page(), 2) == 0 {
          align(center + horizon)[
            #text(
              size: 9pt,
              fill: gray,
            )[#blank_statement]
          ]
          pagebreak()
        }
      }
    } else {
      pagebreak(to: "odd", weak: true)
    }
  }   


  //////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////////
  // Global page setup.
  // Keep in mind that some of these settings are overridden later for the main matter, 
  // but it is easier to set them here as a default for the whole document 
  // and then change them back for the main matter.


   // For example, the page numbering starts as roman for the front matter and then it is switched to arabic when the main matter starts.
   set page(
    paper: paper_size,
    margin: (
      top: margin_top_cm,
      bottom: margin_bottom_cm,
      left: margin_left_cm,
      right: margin_right_cm,
    ),
    numbering: "i",
  )

  set text(
    font: font_body,
    size: font_size_pt,
    fill: rgb("#1E293B"),
  )

  set par(
    leading: line_spacing_em,
    spacing: 1.3*line_spacing_em,
    justify: true,
    first-line-indent: 1em,
  )

  set list(
    indent: 1em,
    body-indent: 0.5em,
    spacing: line_spacing_em,
  )

  set enum(
    indent: 1em,
    body-indent: 0.5em,
    spacing: line_spacing_em,
  )

  // Shared component styling.
  show math.equation: set text(font: font_math)
  show math.equation: set block(spacing: 1em)
  show raw: set text(font: font_mono, size: font_size_pt - 1pt)
  show link: set text(fill: blue.darken(30%))

  let setup-numbering(body) = {
    set heading(numbering: (..args) => {
      let nums = args.pos()
      let level = nums.len()
      if level == 1 {
        [#numbering("1.", ..nums)]
      } else {
        [#numbering("1.1.1", ..nums)]
      }
    })

    // Reset counters at each new chapter. (I am not sure about that one!)
    show heading.where(level: 1): it => {
      counter(figure).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      it
    }

    // Equation and figure numbering use the current chapter as a prefix. (I might want to add an option for tables too)
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

  // Helper function for headings style.
  let configure_headings(body) = {
    show heading: set text(fill: rgb("#0F172A"), weight: "semibold")

    show heading.where(level: 1): set block(
      above: 4.2 * line_spacing_em,
      below: 2.1 * line_spacing_em,
    )
    // show heading.where(level: 1): set text(size: font_size_pt * 1.8)

    show heading.where(level: 2): set block(
      above: 3.3 * line_spacing_em,
      below: 1.6 * line_spacing_em,
    )
    // show heading.where(level: 2): set text(size: font_size_pt * 1.45)

    show heading.where(level: 3): set block(
      above: 2.6 * line_spacing_em,
      below: 1.25 * line_spacing_em,
    )
    // show heading.where(level: 3): set text(size: font_size_pt * 1.2)

    show heading.where(level: 4): set block(
      above: 2.0 * line_spacing_em,
      below: 0.95 * line_spacing_em,
    )
    // show heading.where(level: 4): set text(size: font_size_pt * 1.05)

    show heading.where(level: 5): set block(
      above: 1.6 * line_spacing_em,
      below: 0.8 * line_spacing_em,
    )
    // show heading.where(level: 5): set text(size: font_size_pt)

    body
  }

  // Helper function for figure styling.
  let configure_figures(body) = {
    show figure.caption: it => {
      set text(size: 9pt)
      set align(left)
      set par(justify: true)
      it
    }

    body
  }

  // Global numbering and component rules.
  show: body => setup-numbering(body)
  show: body => configure_headings(body)
  show: body => configure_figures(body)


  ///////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////
  // Document assembly and rendering starts here.
  ///////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////

  // Cover page assembly.
  if show_cover_full {
    cover_page(
      resolved_title,
      subtitle: subtitle,
      authors: authors,
      variant: cover_page_variant,
      image_path: resolved_cover_background_image,
      box_fill: resolved_cover_title_box_fill,
      title_text_fill: resolved_cover_title_text_fill,
      bottom_text_fill: resolved_cover_bottom_text_fill,
      title_weight: cover_title_weight,
      subtitle_weight: cover_subtitle_weight,
      author_weight: cover_author_weight,
      show_subtitle: show_cover_subtitle,
      page_alignment: resolved_cover_alignment,
      title_box_text: cover_title_box_text,
      isbn: isbn,
      isbn_position: resolved_cover_isbn_position,
      logo_text: cover_logo_text,
      logo_dx: cover_logo_dx_cm,
      logo_dy: cover_logo_dy_cm,
      bottom_text_dx: cover_bottom_text_dx_cm,
      bottom_text_dy: cover_bottom_text_dy_cm,
      institution_line: thesis_institution,
      logo: resolved_cover_logo_for_layout,
    )

    // Reset the page background and keep roman numbering for the title page
    // and the remaining front matter after the full cover.
    set page(
      paper: paper_size,
      margin: (
        top: margin_top_cm,
        bottom: margin_bottom_cm,
        left: margin_left_cm,
        right: margin_right_cm,
      ),
      numbering: "i",
      background: none,
    )
  }

  // Title page assembly.
  if show_title_page {
    title_page(
      resolved_title,
      subtitle: subtitle,
      authors: authors,
      isbn: isbn,
      doi: doi,
      affiliations: affiliations,
      date: date,
      degree: thesis_degree,
      program: thesis_program,
      track: thesis_track,
      faculty: thesis_faculty,
      institution: thesis_institution,
      defense_date: thesis_defense_date,
      supervisors: resolved_supervisors,
      committee: resolved_committee,
      show_contributor_affiliations: show_contributor_affiliations,
      logo: resolved_logo_for_layout,
      variant: title_page_variant,
      basic_title_alignment: resolved_title_page_basic_title_alignment,
      basic_table_alignment: resolved_title_page_basic_table_alignment,
      basic_bottom_block_alignment: resolved_title_page_basic_bottom_block_alignment,
      logo_alignment: resolved_title_page_logo_alignment,
      start_on_new_page: show_cover_full,
      show_cover_description: show_title_page_cover_description,
      cover_description: title_page_cover_description,
      show_confidentiality_statement: show_title_page_confidentiality_statement,
      confidentiality_statement: title_page_confidentiality_statement,
      formal_statement: title_page_formal_statement,
    )
  }

  // Front matter between the title page and the main chapters assembly.
  render_frontmatter(
    abstract: abstract,
    keywords: keywords,
    preface: preface,
    acknowledgements: acknowledgements,
    dedication: dedication,
    colophon: colophon,
    frontmatter_order: frontmatter_order,
    show_toc: show_toc,
    show_list_of_figures: show_list_of_figures,
    show_list_of_tables: show_list_of_tables,
    toc_depth: toc_depth,
  )

  // Ensures the main matter starts on an odd page.
  start_mainmatter_on_recto(
    show_blank_statement: show_verso_blank_page_statement,
    blank_statement: verso_blank_page_statement,
  )

  ///////////////////////////////////////////////////////////////////////////////////
  // Main matter uses arabic page numbers, 
  // so the page numbering is reset here with the new format.
  set page(
    paper: paper_size,
    margin: (
      top: margin_top_cm,
      bottom: margin_bottom_cm,
      left: margin_left_cm,
      right: margin_right_cm,
    ),
    numbering: "1",
  )
  // Restart page numbering when the main matter begins.
  counter(page).update(1)

  ///////////////////////////////////////////////////////////
  // MyST adds the ordered chapter and appendix content here.
  // Currently, appendices are considered a part of the main matter and they follow the same layout rules, but I want to add an option later to customize them separately.

  [#body]

  // (Optional) bibliography assembly after the document content.
  render_bibliography(
    bibliography_file: bibliography_file,
    show_bibliography: show_bibliography,
    bibliography_title: bibliography_title,
    bibliography_style: bibliography_style,
    bibliography_numbered_heading: bibliography_numbered_heading,
  )
}
