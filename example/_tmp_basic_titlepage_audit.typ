#import "../src/layout/titlepage.typ": title_page

#set page(margin: (top: 2.5cm, bottom: 2.5cm, left: 2.5cm, right: 2.5cm))
#set text(font: "Libertinus Serif", size: 11pt)
#set par(leading: 0.6em, spacing: 0.7em, justify: true, first-line-indent: 1.2em)

#title_page(
  title: [Basic Variant Audit],
  subtitle: [Centered title block with left-aligned metadata and bottom block],
  authors: ("Student Name",),
  affiliations: ("Delft University of Technology",),
  isbn: "978-94-0000-000-0",
  date: "22-2-2026",
  degree: "Master of Science",
  program: "Applied Physics",
  track: "Physics for Instrumentation",
  faculty: "Faculty of Applied Sciences",
  institution: "Delft University of Technology",
  defense_date: "Friday June 19, 2026 at 10:00",
  supervisors: ((name: "Prof. Supervisor", affiliation: "Delft University of Technology"),),
  committee: (
    (name: "Dr. Committee One", affiliation: "Delft University of Technology"),
    (name: "Dr. Committee Two", affiliation: "External Institute"),
  ),
  show_contributor_affiliations: true,
  logo: "../src/assets/brand_assets/logo.svg",
  variant: "basic",
  show_cover_description: true,
  cover_description: "The cover image is a template demonstration background.",
  show_confidentiality_statement: true,
  confidentiality_statement: "This thesis is confidential and cannot be made public.",
  basic_title_alignment: "center",
  basic_table_alignment: "left",
  basic_bottom_block_alignment: "left",
  logo_alignment: "left",
)
