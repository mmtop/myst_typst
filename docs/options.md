# Typst Options

## Layout options
- `show_cover_full` (boolean): Render a cover page.
- `show_title_page` (boolean): Render a title page.
- `show_title_page_image` (boolean): Enable or disable title-page image rendering.
- `show_contributor_affiliations` (boolean): Show supervisor/committee affiliations on the detailed title-page layouts (dark gray italic line under each name).
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
- `paper_size` (string): Typst paper size. Default is `a4`. Common values are `a4` and `us-letter`.
- `margin_top_cm` (number): Top margin in cm. Default is `2.5`.
- `margin_bottom_cm` (number): Bottom margin in cm. Default is `2.5`.
- `margin_left_cm` (number): Left margin in cm. Default is `2.5`.
- `margin_right_cm` (number): Right margin in cm. Default is `2.5`.
- `font_body` (string): Body font family. Default is `Libertinus Serif`.
- `font_mono` (string): Monospace font family. Default is `DejaVu Sans Mono`.
- `font_math` (string): Math font family for equations. Use a real math font. Default is `New Computer Modern Math`.
- `font_size_pt` (number): Base font size in points. Default is `11`.
- `line_spacing_em` (number): Paragraph leading in em. Default is `0.6`.
- `toc_depth` (number): Depth for table of contents.

The `paper_size` setting is passed directly to Typst's page setup and applies to the cover, front matter, main matter, and bibliography. If you switch to `us-letter`, you can usually keep the same defaults and only adjust margins later if your institution asks for something more specific.

## Bundled fonts
- The template bundles `STIX Two Text`, `STIX Two Math`, `JetBrains Mono`, `Atkinson Hyperlegible Next`, and `Atkinson Hyperlegible Mono` in `src/assets/fonts`.
- Recommended for GitHub Pages, CI, and also local builds: point Typst to that folder through the `TYPST_FONT_PATHS` environment variable.
- Local alternative: install the bundled font families on your machine so Typst can find them like normal system fonts.
- Until you enable those bundled fonts, the template falls back to `Libertinus Serif`, `DejaVu Sans Mono`, and `New Computer Modern Math`.
- Recommended bundled serif preset: `font_body: STIX Two Text`, `font_math: STIX Two Math`, `font_mono: JetBrains Mono`.
- Recommended bundled accessible sans preset: `font_body: Atkinson Hyperlegible Next`, `font_math: New Computer Modern Math`, `font_mono: JetBrains Mono`.
- `Atkinson Hyperlegible Mono` is bundled as an optional matching mono companion, but `JetBrains Mono` remains the default recommendation for code.

## Cover page options
- `cover_page_variant` (string): `simple`, `graphical`, or `custom`.
- `show_cover_subtitle` (boolean): Show or hide the document subtitle on the cover page.
- `cover_background_image` (file): Background image path for graphical cover.
- `cover_graphical_appearance` (string): Graphical-cover contrast preset: `white-on-dark` or `black-on-light`.
- `cover_graphical_alignment` (string): Graphical-cover alignment for the title box and bottom branding block: `left` or `center`.
- `cover_title_text_color` (string, optional): Override graphical-cover title-box text color with `white`, `black`, or a hex color like `#f5f5f5`.
- `cover_bottom_text_color` (string, optional): Override graphical-cover text shown outside the title box, such as the logo caption or a bottom ISBN, with `white`, `black`, or a hex color like `#f5f5f5`.
- `cover_title_box_color` (string, optional): Override graphical-cover title-box base color with `black`, `white`, or a hex color like `#f5f5f5`.
- `cover_title_box_text` (string, optional): Extra text shown in the graphical-cover title box below the author line. Newlines are preserved.
- `cover_title_box_opacity_pct` (number): Opacity of the graphical cover title box (0-100).
- `cover_isbn_position` (string): Placement of the cover ISBN: `titlebox` or `logo`.
- `cover_logo_variant` (string, optional): Override graphical-cover logo selection with `white` or `black`.
- `cover_logo_white` (file, optional): White logo file used by the graphical cover.
- `cover_logo_black` (file, optional): Black logo file used by the graphical cover.
- `cover_logo_text` (string, optional): Small text shown below the graphical-cover logo. Newlines are preserved.
- `cover_logo_dx_cm` (number, optional): Horizontal offset for the graphical-cover logo in cm.
- `cover_logo_dy_cm` (number, optional): Vertical offset for the graphical-cover logo in cm.
- `cover_bottom_text_dx_cm` (number, optional): Horizontal offset for the graphical-cover text block below the logo in cm.
- `cover_bottom_text_dy_cm` (number, optional): Vertical offset for the graphical-cover text block below the logo in cm.
- `cover_image` (file): Legacy alias for `cover_background_image`.

## Title page options
- `title_page_variant` (string): `basic`, `formal`, or `custom`. The legacy value `simple` is still accepted as an alias for `basic`.
- `show_title_page_cover_description` (boolean): Show the optional cover description line near the bottom of the title page.
- `title_page_cover_description` (string): Text for the optional cover description line on the title page.
- `show_title_page_confidentiality_statement` (boolean): Show the optional confidentiality statement near the bottom of the title page.
- `title_page_confidentiality_statement` (string): Text for the optional confidentiality statement. Default is `This thesis is confidential and cannot be made public.`
- `title_page_image` (file): Optional image on title page.
- `title_page_image_anchor` (string, optional): `top-right`, `top`, `top-left`, `center`, `bottom`, `bottom-right`, or `bottom-left`.
- `title_page_image_width_cm` (number, optional): Image width in cm. Default is `5`.
- `title_page_image_height_cm` (number, optional): Image height in cm. If omitted, image height is automatic.
- `title_page_image_dx_cm` (number, optional): Horizontal offset in cm for placed title-page image. Default is `0`.
- `title_page_image_dy_cm` (number, optional): Vertical offset in cm for placed title-page image. Default is `0`.
- `logo` (file): Shared logo path used on the title page and as a fallback for the graphical cover when no cover-specific logo file is available.
- `isbn` (string, optional): Shared project option used as the canonical ISBN source for the graphical cover.

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
1. Set `cover_page_variant: custom` in `example/typst_export_config.yml`.
2. Edit `templates/thesis-typst/src/layout/cover.typ`.
3. Replace `cover_page_custom(...)` while keeping its signature stable.
4. If you add new knobs, register them in `templates/thesis-typst/template.yml` and map them in `templates/thesis-typst/template.typ`.

For title-page customization:
1. Set `title_page_variant: custom` in `example/typst_export_config.yml`.
2. Edit `templates/thesis-typst/src/layout/titlepage.typ`.
3. Replace `title_page_custom(...)` while keeping its signature stable.
4. If you add new knobs, register them in `templates/thesis-typst/template.yml` and map them in `templates/thesis-typst/template.typ`.

## Active export config
- In the example project, the active export profile is `example/typst_export_config.yml`.
