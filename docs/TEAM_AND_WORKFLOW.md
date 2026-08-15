# Team and development workflow

## Founding team

- Cam de Gooyer develops primarily on Windows.
- Daniel Perrem develops primarily on macOS.

Ownership of individual product areas will be recorded when the first tool and cloud implementation are selected. The repository does not invent permanent role boundaries before the team agrees them.

## Cross-platform contract

Windows and macOS are equal development targets, not a primary platform and a later port.

- Use UTF-8 and repository-controlled line endings.
- Use repository-relative paths in documentation, fixtures and configuration.
- Use platform path libraries in code; never assemble paths by concatenating `/` or `\\`.
- Treat filename case as significant even on case-insensitive machines.
- Do not store developer home paths, installed SketchUp paths or local ports as product configuration.
- Keep secrets and machine-specific settings in ignored environment/config files with safe examples.
- Prefer a cross-platform task entry point. If a native shell step is unavoidable, supply equivalent PowerShell and POSIX scripts and test both.
- Keep JSON and API payloads platform-independent. Model units are explicit millimetres, never machine locale defaults.
- Normalize canonical plan serialization before hashing so platform float formatting, hash ordering and newlines cannot change a plan hash.

## Change workflow

1. Start with an issue or short decision note that names the user outcome and affected contract.
2. Keep each change small enough for the other developer to review completely.
3. Add or update tests with the implementation.
4. Run contract and pure-planner tests locally.
5. Use pull requests for shared branches; do not rewrite another developer's published history.
6. Require the other founder's review for contract changes, architecture decisions, security boundaries, data migrations and AI production enablement.
7. Record real SketchUp smoke evidence for platform-sensitive releases.

## Initial branch and release policy

- Protect the default branch once the remote repository is created.
- Require passing required checks and one founder review.
- Use semantic versions for published contracts and runtime packages.
- Use immutable release tags and generated release notes.
- Do not ship from an unreviewed local build.

## Platform verification matrix

| Surface | Windows | macOS |
|---|---:|---:|
| Contract/schema validation | Required | Required |
| Pure deterministic planner tests | Required | Required |
| Runtime unit/integration tests | Required | Required |
| SketchUp preview/build | Required | Required |
| Inspect/rebuild/delete lifecycle | Required | Required |
| Installer, update and rollback | Required | Required |
| Unicode, paths and case handling | Required | Required |
