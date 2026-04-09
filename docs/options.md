# Typst Options

## Layout options
- `show_cover_full` (boolean): Render a cover page.
- `show_title_page` (boolean): Render a title page.
- `show_title_page_image` (boolean): Enable or disable title-page image rendering.
- `show_contributor_affiliations` (boolean): Show supervisor/committee affiliations on the title page (dark gray italic line under each name).
- `show_toc` (boolean): Render the table of contents.
- `show_list_of_figures` (boolean): Render list of figures.
- `show_list_of_tables` (boolean): Render list of tables.
- `show_bibliography` (boolean): Render the bibliography chapter.
- `bibliography_title` (string): Title for the bibliography chapter. Default is `Bibliography`.
- `bibliography_style` (string): Typst bibliography style. Default is `ieee`.
  Common built-in styles include `ieee`, `apa`, `mla`, `chicago-author-date`, and `chicago-notes`.
- `bibliography_numbered_heading` (boolean): Number the bibliography chapter heading. Default is `false`.

Front matter uses roman page numbers and the main matter uses arabic page numbers by default.
Users who want to change this can edit the `numbering:` lines in `src/main.typ`.

## Page and typography options
- `paper_size` (string): Typst paper size, for example `a4`.
- `margin_top_cm` (number): Top margin in cm.
- `margin_bottom_cm` (number): Bottom margin in cm.
- `margin_left_cm` (number): Left margin in cm.
- `margin_right_cm` (number): Right margin in cm.
- `font_body` (string): Body font family.
- `font_mono` (string): Monospace font family.
- `font_math` (string): Math font family for equations. Use a real math font.
- `font_size_pt` (number): Base font size in points.
- `line_spacing_em` (number): Paragraph leading in em.
- `toc_depth` (number): Depth for table of contents.

## Cover page options
- `cover_page_variant` (string): `simple`, `graphical`, or `custom`.
- `cover_background_image` (file): Background image path for graphical cover.
- `cover_title_box_opacity_pct` (number): Opacity of the graphical cover title box (0-100).
- `cover_image` (file): Legacy alias for `cover_background_image`.

## Title page options
- `title_page_variant` (string): `simple`, `formal`, or `custom`.
- `title_page_image` (file): Optional image on title page.
- `title_page_image_anchor` (string, optional): `top-right`, `top`, `top-left`, `center`, `bottom`, `bottom-right`, or `bottom-left`.
- `title_page_image_width_cm` (number, optional): Image width in cm. Default is `5`.
- `title_page_image_height_cm` (number, optional): Image height in cm. If omitted, image height is automatic.
- `title_page_image_dx_cm` (number, optional): Horizontal offset in cm for placed title-page image. Default is `0`.
- `title_page_image_dy_cm` (number, optional): Vertical offset in cm for placed title-page image. Default is `0`.
- `logo` (file): Header and title-page logo path.

## Path handling
- File paths are normalized to forward slashes before Typst loads them, which keeps Windows, macOS, Linux, and CI builds aligned.
- Prefer forward slashes in config values even on Windows, for example `files/logo.svg` or `config/assets/logo.svg`.
- Bare relative paths are rebased internally because some assets are loaded from `src/main.typ` and others from `src/layout/*.typ`.

## Shared thesis metadata (not PDF layout options)
These fields are semantic metadata and should stay in shared config:
- `project.options.thesis_degree`
- `project.options.thesis_program`
- `project.options.thesis_faculty`
- `project.options.thesis_institution`
- `project.options.thesis_defense_date`
- `project.authors` (students only)
- `project.contributors` (supervisors/committee keyed by contributor `id` prefix, recommended: `supervisor-1`, `committee-1`, ...)

At render time, MyST injects `project.options.*` into template `options.*`.

## Bibliography placement
The bibliography is currently rendered after the MyST content stream. In the current template structure, appendices are part of that same stream, so the bibliography appears after them.

## Appendix note
Appendices are currently treated like regular late chapters.

That means:
- they stay in the same MyST `toc` list as the rest of the document
- their headings use the same chapter numbering system as the main matter
- figures and equations in appendices also keep using the current chapter-based numbering

For clarity, appendix files should keep their titles written out explicitly, for example `# Appendix A: Extra Data`.

## Custom variant entry points
For cover-page customization:
1. Set `cover_page_variant: custom` in `config/exports/typst_config.yml`.
2. Edit `templates/thesis-typst/src/layout/cover.typ`.
3. Replace `cover_page_custom(...)` while keeping its signature stable.
4. If you add new knobs, register them in `templates/thesis-typst/template.yml` and map them in `templates/thesis-typst/template.typ`.

For title-page customization:
1. Set `title_page_variant: custom` in `config/exports/typst_config.yml`.
2. Edit `templates/thesis-typst/src/layout/titlepage.typ`.
3. Replace `title_page_custom(...)` while keeping its signature stable.
4. If you add new knobs, register them in `templates/thesis-typst/template.yml` and map them in `templates/thesis-typst/template.typ`.

## Active export config
- Single export profile: `config/exports/typst_config.yml`.
