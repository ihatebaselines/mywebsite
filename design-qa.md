# Design QA — portfolio refresh

## Reference and scope

- Visual direction: supplied cream-and-teal portfolio mockup with playful cat/ocean artwork.
- Existing content remains available; homepage now carries the README, project, highlight, competition, blog, and explore sections.
- Latest bug reports: low-contrast event gallery controls and project-card imagery overlapping text.

## Checks performed

- Homepage at 1440 × 1000: project-card image and text tracks stay separate (18 px gap); three-column cards stack image above copy.
- Homepage at 390 × 844: cards reflow to one column; document width remains within the viewport (375 CSS px content inside 390 px viewport).
- CEOAI blog detail at 1440 × 1000: gallery title resolves to dark theme text; inactive controls use muted readable text, active control uses teal-tinted surface and dark text; no horizontal overflow.
- `npm run build`: passed; all 33 static pages generated.

## Fixes

- Removed legacy white-on-dark colors from resource/gallery UI and mapped them to the active design tokens.
- Constrained card image boxes to their grid tracks (`width: 100%`, `min-width: 0`) so aspect ratio cannot make them overlap copy.
- Changed three-column cards to a vertical image-then-copy layout and enabled long headings to wrap.

## Follow-up

- Type validation is disabled by the repository's Next.js build config; run a separate typecheck once the existing generated-type/tooling setup is repaired.
- Automated lint is currently blocked by the repository's ESLint/runtime `react/display-name` error.
