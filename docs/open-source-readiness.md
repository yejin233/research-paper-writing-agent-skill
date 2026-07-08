# Open-Source Readiness Notes

This package was prepared as a clean open-source distribution of the local research-paper-writing-agent skill.

## Included

- `SKILL.md`
- `references/`
- `templates/`
- `examples/`
- `docs/`
- `tests/check-open-source.ps1`
- `README.md`
- `LICENSE`

## Excluded

- local backup files
- project-specific manuscripts
- result directories
- external GPT session files
- user browser profiles
- generated packages
- local status notes

## Before Publishing

1. Review `LICENSE` and set the correct copyright holder.
2. Run `tests/check-open-source.ps1`.
3. Review any warnings from the scanner.
4. Confirm template licenses are acceptable for redistribution.
5. Confirm the skill provenance is described accurately in the repository description or README.

## Known Caveat

Some upstream text may contain encoding artifacts inherited from the source skill. They are not private data, but maintainers may want to clean them in a later documentation polish pass.

