# manual

## cover page
- `cover_page_variant` (string): `simple`, `graphical`, or `custom`.
- `show_cover_subtitle` toggles the subtitle on the cover page for both simple and graphical variants.
- `cover_graphical_appearance` sets the graphical-cover contrast preset: `white-on-dark` or `black-on-light`.
- `cover_graphical_alignment` sets the graphical-cover alignment for the title box and bottom branding block: `left` or `center`.
- `cover_title_text_color` optionally overrides the graphical-cover text color with `white`, `black`, or a hex color like `#f5f5f5`.
- `cover_title_weight`, `cover_subtitle_weight`, and `cover_author_weight` optionally control the title, subtitle, and author font weights on the graphical cover.
- `cover_bottom_text_color` optionally overrides the graphical-cover text shown outside the title box, such as the logo caption or a bottom ISBN, with `white`, `black`, or a hex color.
- `cover_title_box_color` optionally overrides the graphical-cover title-box color with `black`, `white`, or a hex color.
- `cover_title_box_text` optionally adds extra text below the author line in the graphical-cover title box.
- `cover_title_box_opacity_pct` controls the opacity of that graphical-cover title box.
- `cover_isbn_position` chooses whether that ISBN appears in the `titlebox` or below the `logo`.
- `cover_logo_variant` optionally selects the graphical-cover logo tone: `white` or `black`.
- `cover_logo_white` and `cover_logo_black` optionally provide the white and black logo files used by the graphical cover.
- `cover_logo_text` optionally adds small text below the graphical-cover logo.
- `cover_logo_dx_cm` and `cover_logo_dy_cm` optionally nudge the graphical-cover logo horizontally and vertically.
- `cover_bottom_text_dx_cm` and `cover_bottom_text_dy_cm` optionally nudge the graphical-cover text block below the logo independently.
## title page
- `title_page_variant` (string): `basic`, `formal`, or `custom`.
- `title_page_basic_title_alignment` aligns the title and subtitle block in the basic/simple title-page layout: `left` or `center`.
- `title_page_basic_table_alignment` aligns the metadata table in the basic/simple title-page layout independently from the centered title block: `left` or `center`.
- `title_page_basic_bottom_block_alignment` aligns the bottom block in the basic/simple title-page layout independently from the metadata table: `left` or `center`.
- `title_page_logo_alignment` aligns the title-page logo independently in the basic/simple layout: `left` or `center`. The formal/custom path stays centered.
- `show_title_page_cover_description` toggles the optional cover description on the title page. In the basic/simple layout it becomes its own section above the bottom block, and in the formal/custom path it appears as a centered metadata row below the supervisor and committee table.
- `title_page_cover_description` sets the text for that cover description.
- `show_title_page_confidentiality_statement` toggles the optional confidentiality statement on the title page. In both the basic/simple and formal/custom layouts it is rendered in the bottom block together with the ISBN when present.
- `title_page_confidentiality_statement` sets the text for that confidentiality statement.
## logo
- `logo` sets the shared logo used on the title page and as a fallback on the graphical cover.

## metadata
- `isbn` is a shared project option under `project.options` and is the single source for the ISBN shown on the graphical cover and in the title-page bottom block.
- `thesis_track` optionally adds a specialization or track line to the title page metadata.

## numbering of eq tables / figures
