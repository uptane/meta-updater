# AGENTS.md

Yocto layer providing OTA updates with OSTree and Aktualizr.

## Where to look

- `README.adoc`: overview, dependencies, links to the full documentation.
- `CONTRIBUTING.adoc`: branches, DCO and the contributor checklist.
- `classes/`: core logic (`sota.bbclass`, `image_types_ostree.bbclass`, `sota_<platform>.bbclass` for platform support).
- `recipes-*/`: recipes, grouped by area.
- `kas/`: kas configurations for supported machines.
- `lib/oeqa/selftest/cases/`: oe-selftest tests (`updater_*.py`).

## Testing

- Go through the contributor checklist in `CONTRIBUTING.adoc` before submitting.
- List in the PR description which checks were run and which were not; never claim a check that was not run.

## Commits and PRs

- Target `master`; backports go to the release branches.
- Every commit needs `Signed-off-by:` (`git commit -s`).
- AI-assisted commits use `Assisted-by: AGENT_NAME:MODEL_VERSION`, not `Co-Authored-By:`.
