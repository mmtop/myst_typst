#import "src/main.typ": thesis_template

// This file maps MyST metadata, part files, and export options
// into the Typst template arguments defined in src/main.typ.
//
// Navigation notes:
// - This file prefers `project.*` values and only falls back to `doc.*` when needed.
// - It reshapes some MyST metadata so the Typst layout files receive the simpler
//   tuples and strings they expect.
// - If an option is omitted here, the final default usually comes from src/main.typ.

#show: thesis_template.with(
  // Shared document metadata
  // These are the basic title, people, date, and keyword values reused across the template.
[# if project.title #]
  title: "[-project.title-]",
[# elif doc.title #]
  title: "[-doc.title-]",
[# else #]
  title: "Untitled Report",
[# endif #]

[# if project.subtitle #]
  subtitle: "[-project.subtitle-]",
[# elif doc.subtitle #]
  subtitle: "[-doc.subtitle-]",
[# else #]
  subtitle: none,
[# endif #]

  authors: (
[# if project.authors #]
[# for author in project.authors #]
    "[# if author.name #][-author.name-][# else #][-author-][# endif #]",
[# endfor #]
[# elif doc.authors #]
[# for author in doc.authors #]
    "[# if author.name #][-author.name-][# else #][-author-][# endif #]",
[# endfor #]
[# endif #]
  ),

  // Contributors keep their ids because the title page groups them by prefixes such as
  // `supervisor-1` and `committee-1`.
  contributors: (
[# if project.contributors #]
[# for contributor in project.contributors #]
    (
      id: "[# if contributor.id #][-contributor.id-][# else #][# endif #]",
      name: "[# if contributor.name #][-contributor.name-][# else #][-contributor-][# endif #]",
      affiliations: (
[# if contributor.affiliations #]
[# for affiliation_id in contributor.affiliations #]
        "[-affiliation_id-]",
[# endfor #]
[# endif #]
      ),
    ),
[# endfor #]
[# elif doc.contributors #]
[# for contributor in doc.contributors #]
    (
      id: "[# if contributor.id #][-contributor.id-][# else #][# endif #]",
      name: "[# if contributor.name #][-contributor.name-][# else #][-contributor-][# endif #]",
      affiliations: (
[# if contributor.affiliations #]
[# for affiliation_id in contributor.affiliations #]
        "[-affiliation_id-]",
[# endfor #]
[# endif #]
      ),
    ),
[# endfor #]
[# endif #]
  ),

  // The same affiliation source is mapped in two shapes:
  // - `affiliation_catalog` keeps ids so contributor affiliations can be resolved
  // - `affiliations` keeps only printable names for simple title-page rendering
  affiliation_catalog: (
[# if project.affiliations #]
[# for aff in project.affiliations #]
    (
      id: "[# if aff.id #][-aff.id-][# else #][# endif #]",
      name: "[# if aff.institution #][-aff.institution-][# elif aff.name #][-aff.name-][# else #][-aff-][# endif #]",
    ),
[# endfor #]
[# elif doc.affiliations #]
[# for aff in doc.affiliations #]
    (
      id: "[# if aff.id #][-aff.id-][# else #][# endif #]",
      name: "[# if aff.institution #][-aff.institution-][# elif aff.name #][-aff.name-][# else #][-aff-][# endif #]",
    ),
[# endfor #]
[# endif #]
  ),

  affiliations: (
[# if project.affiliations #]
[# for aff in project.affiliations #]
    "[# if aff.institution #][-aff.institution-][# elif aff.name #][-aff.name-][# else #][-aff-][# endif #]",
[# endfor #]
[# elif doc.affiliations #]
[# for aff in doc.affiliations #]
    "[# if aff.institution #][-aff.institution-][# elif aff.name #][-aff.name-][# else #][-aff-][# endif #]",
[# endfor #]
[# endif #]
  ),

  // MyST dates arrive as structured values; here they are turned into a simple string
  // that the Typst template can print directly.
[# if project.date #]
  date: "[-project.date.day-]-[-project.date.month-]-[-project.date.year-]",
[# elif doc.date #]
  date: "[-doc.date.day-]-[-doc.date.month-]-[-doc.date.year-]",
[# else #]
  date: none,
[# endif #]

  keywords: (
[# if project.keywords #]
[# for keyword in project.keywords #]
    "[-keyword-]",
[# endfor #]
[# elif doc.keywords #]
[# for keyword in doc.keywords #]
    "[-keyword-]",
[# endfor #]
[# endif #]
  ),

  // Thesis-specific metadata
  // These are layout-specific academic labels used mainly by the formal title page.
  thesis_degree: [# if options.thesis_degree #]"[-options.thesis_degree-]"[# else #]none[# endif #],
  thesis_program: [# if options.thesis_program #]"[-options.thesis_program-]"[# else #]none[# endif #],
  thesis_faculty: [# if options.thesis_faculty #]"[-options.thesis_faculty-]"[# else #]none[# endif #],
  thesis_institution: [# if options.thesis_institution #]"[-options.thesis_institution-]"[# else #]none[# endif #],
  thesis_defense_date: [# if options.thesis_defense_date #]"[-options.thesis_defense_date-]"[# else #]none[# endif #],

  // Optional front-matter part files
  // These come from separate MyST part files and are rendered before the main chapters.
  abstract: [# if parts.abstract #]"[-parts.abstract-]"[# else #]none[# endif #],
  preface: [# if parts.preface #]"[-parts.preface-]"[# else #]none[# endif #],
  acknowledgements: [# if parts.acknowledgements #]"[-parts.acknowledgements-]"[# else #]none[# endif #],
  dedication: [# if parts.dedication #]"[-parts.dedication-]"[# else #]none[# endif #],
  colophon: [# if parts.colophon #]"[-parts.colophon-]"[# else #]none[# endif #],

  // Document structure and front matter
  show_cover_full: [# if options.show_cover_full is defined #][-options.show_cover_full-][# else #]true[# endif #],
  show_title_page: [# if options.show_title_page is defined #][-options.show_title_page-][# else #]true[# endif #],
  show_contributor_affiliations: [# if options.show_contributor_affiliations is defined #][-options.show_contributor_affiliations-][# else #]true[# endif #],
  show_toc: [# if options.show_toc is defined #][-options.show_toc-][# else #]true[# endif #],
  show_list_of_figures: [# if options.show_list_of_figures is defined #][-options.show_list_of_figures-][# else #]false[# endif #],
  show_list_of_tables: [# if options.show_list_of_tables is defined #][-options.show_list_of_tables-][# else #]false[# endif #],
  toc_depth: [# if options.toc_depth #][-options.toc_depth-][# else #]2[# endif #],

  // Page layout
  paper_size: "[# if options.paper_size #][-options.paper_size-][# else #]a4[# endif #]",
  margin_top_cm: [# if options.margin_top_cm #][-options.margin_top_cm-]cm[# else #]2.5cm[# endif #],
  margin_bottom_cm: [# if options.margin_bottom_cm #][-options.margin_bottom_cm-]cm[# else #]2.5cm[# endif #],
  margin_left_cm: [# if options.margin_left_cm #][-options.margin_left_cm-]cm[# else #]2.5cm[# endif #],
  margin_right_cm: [# if options.margin_right_cm #][-options.margin_right_cm-]cm[# else #]2.5cm[# endif #],

  // Typography
  // Font family options are only passed when the user sets them explicitly.
  // Otherwise src/main.typ keeps the template's built-in fallback families.
  [# if options.font_body #]font_body: "[-options.font_body-]",[# endif #]
  [# if options.font_mono #]font_mono: "[-options.font_mono-]",[# endif #]
  [# if options.font_math #]font_math: "[-options.font_math-]",[# endif #]
  font_size_pt: [# if options.font_size_pt #][-options.font_size_pt-]pt[# else #]11pt[# endif #],
  line_spacing_em: [# if options.line_spacing_em #][-options.line_spacing_em-]em[# else #].6em[# endif #],

  // Bibliography
  // The bibliography file is discovered from MyST itself, while the remaining settings
  // come from user-facing PDF export options.
  bibliography_file: [# if doc.bibtex #]"[-doc.bibtex-]"[# else #]none[# endif #],
  show_bibliography: [# if options.show_bibliography is defined #][-options.show_bibliography-][# else #]true[# endif #],
  bibliography_title: [# if options.bibliography_title #]"[-options.bibliography_title-]"[# else #]"Bibliography"[# endif #],
  bibliography_style: [# if options.bibliography_style #]"[-options.bibliography_style-]"[# else #]"ieee"[# endif #],
  bibliography_numbered_heading: [# if options.bibliography_numbered_heading is defined #][-options.bibliography_numbered_heading-][# else #]false[# endif #],

  // Shared assets and branding
  // If no custom files are provided, the bundled template assets are used.
  logo: [# if options.logo #]"[-options.logo-]"[# else #]"src/assets/brand_assets/logo.svg"[# endif #],

  // Cover-page options
  cover_page_variant: "[# if options.cover_page_variant #][-options.cover_page_variant-][# else #]simple[# endif #]",
  cover_background_image: [# if options.cover_background_image #]"[-options.cover_background_image-]"[# elif options.cover_image #]"[-options.cover_image-]"[# else #]"src/assets/template_figures/defaultcover.jpg"[# endif #],
  cover_title_box_opacity_pct: [# if options.cover_title_box_opacity_pct is defined #][-options.cover_title_box_opacity_pct-][# else #]55[# endif #],

  // Title-page options
  title_page_variant: "[# if options.title_page_variant #][-options.title_page_variant-][# else #]simple[# endif #]",
  show_title_page_image: [# if options.show_title_page_image is defined #][-options.show_title_page_image-][# else #]true[# endif #],
  title_page_image: [# if options.title_page_image #]"[-options.title_page_image-]"[# else #]"src/assets/template_figures/defaultcover.jpg"[# endif #],
  title_page_image_anchor: [# if options.title_page_image_anchor is defined and options.title_page_image_anchor != none and options.title_page_image_anchor != "" #]"[-options.title_page_image_anchor-]"[# else #]"bottom"[# endif #],
  title_page_image_width_cm: [# if options.title_page_image_width_cm is defined and options.title_page_image_width_cm != none #][-options.title_page_image_width_cm-]cm[# else #]none[# endif #],
  title_page_image_height_cm: [# if options.title_page_image_height_cm is defined and options.title_page_image_height_cm != none #][-options.title_page_image_height_cm-]cm[# else #]none[# endif #],
  title_page_image_dx_cm: [# if options.title_page_image_dx_cm is defined and options.title_page_image_dx_cm != none #][-options.title_page_image_dx_cm-]cm[# else #]none[# endif #],
  title_page_image_dy_cm: [# if options.title_page_image_dy_cm is defined and options.title_page_image_dy_cm != none #][-options.title_page_image_dy_cm-]cm[# else #]none[# endif #]
)

// MyST injects additional helper imports here.
[-IMPORTS-]

// MyST injects the ordered document content stream here.
[-CONTENT-]
