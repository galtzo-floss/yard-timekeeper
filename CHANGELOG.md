# Changelog

[![SemVer 2.0.0][📌semver-img]][📌semver] [![Keep-A-Changelog 1.0.0][📗keep-changelog-img]][📗keep-changelog]

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][📗keep-changelog],
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html),
and [yes][📌major-versions-not-sacred], platform and engine support are part of the [public API][📌semver-breaking].
Please file a bug if you notice a violation of semantic versioning.

[📌semver]: https://semver.org/spec/v2.0.0.html
[📌semver-img]: https://img.shields.io/badge/semver-2.0.0-FFDD67.svg?style=flat
[📌semver-breaking]: https://github.com/semver/semver/issues/716#issuecomment-869336139
[📌major-versions-not-sacred]: https://tom.preston-werner.com/2022/05/23/major-version-numbers-are-not-sacred.html
[📗keep-changelog]: https://keepachangelog.com/en/1.0.0/
[📗keep-changelog-img]: https://img.shields.io/badge/keep--a--changelog-1.0.0-FFDD67.svg?style=flat

## [Unreleased]

### Added

### Changed

- kettle-jem-template-20260716-001 - Shim gemspec manifests now include
  `LICENSE.md` instead of nonexistent `LICENSE.txt`.
- kettle-jem-template-20260716-002 - Generated gemspec manifests now ship fewer
  repository-only files by default to reduce downstream distro packaging churn.
- kettle-jem-template-20260720-001 - Generated READMEs can now render
  template-managed corporate sponsor logos from project or family config.
- kettle-jem-template-20260720-002 - Generated development Gemfiles now use the
  released `tree_sitter_language_pack` gem 1.13.3 or newer by default.
- kettle-jem-template-20260720-003 - Generated StructuredMerge Git diff driver
  config now uses the installed `smorg-rb` Ruby driver name.
- kettle-jem-template-20260720-004 - Generated multi-engine workflow files now
  omit JRuby and TruffleRuby jobs when project config declares MRI-only engines.
- kettle-jem-template-20260720-005 - Generated README Support & Community rows
  now include a RubyForum help badge.
- kettle-jem-template-20260725-001 - Generated JRuby and TruffleRuby workflow
  files now run when pull request head branches start with `feature/release`,
  so release CI monitoring does not report intentionally skipped engine
  workflows as failures.

### Deprecated

### Removed

### Fixed

- Generated YARD title metadata normalization now replaces only the generated
  `Documentation by YARD ...` text when it appears inline with real HTML markup,
  preventing `_index.html` content wrapper deletion during docs regeneration.

### Security

## [0.2.4] - 2026-07-18

- TAG: [v0.2.4][0.2.4t]
- COVERAGE: 95.20% -- 119/125 lines in 3 files
- BRANCH COVERAGE: 86.54% -- 45/52 branches in 3 files
- 15.62% documented

### Fixed

- Restored generated YARD title/header metadata from git when rebuilding docs
  with a newer YARD version, including when the file also has real content
  changes that should be preserved.

## [0.2.3] - 2026-07-02

- TAG: [v0.2.3][0.2.3t]
- COVERAGE: 97.62% -- 82/84 lines in 3 files
- BRANCH COVERAGE: 93.33% -- 28/30 branches in 3 files
- 20.83% documented

### Fixed

- Package configured license files in gem release file lists.

## [0.2.2] - 2026-06-22

- TAG: [v0.2.2][0.2.2t]
- COVERAGE: 97.62% -- 82/84 lines in 3 files
- BRANCH COVERAGE: 93.33% -- 28/30 branches in 3 files
- 20.83% documented

### Added

- Added support for JRuby 10.1 and TruffleRuby 34.0.

### Changed

- Retemplated project metadata and CI/development automation with `kettle-jem` v7.0.0.

## [0.2.1] - 2026-06-04

- TAG: [v0.2.1][0.2.1t]
- COVERAGE: 98.80% -- 82/83 lines in 2 files
- BRANCH COVERAGE: 93.33% -- 28/30 branches in 2 files
- 20.83% documented

### Fixed

- Treated YARD generator version and Ruby version footer changes as generated
  documentation churn, so footer-only docs diffs are restored even when the
  toolchain version changes.

## [0.2.0] - 2026-06-03

- TAG: [v0.2.0][0.2.0t]
- COVERAGE: 100.00% -- 72/72 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 15.00% documented

### Added

- Added generated CI coverage for `rdoc` `~> 6.11` and `>= 7.0`.
- Added release checksum files for the `v0.1.0` gem package.
- Added generated StructuredMerge git driver configuration and repo-local
  template metadata under `.structuredmerge/`.
- Added generated documentation pages for IRP and YAML citation metadata.

### Changed

- Refreshed generated CI workflows, including coverage report verification,
  configurable coverage summary thresholds, and updated Ruby/Appraisal matrix
  wiring.
- Updated generated documentation dependencies to require `yard` >= 0.9.44,
  `yard-fence` >= 0.9.2, and `yard-yaml` >= 0.2.0.
- Updated generated development, test, style, and coverage dependency floors,
  including `kettle-dev` >= 2.0.8, `kettle-test` >= 2.0.3,
  `kettle-soup-cover` >= 2.0.1, `gitmoji-regex` >= 2.0.1, and current
  RuboCop-LTS style dependencies.
- Updated local workspace dependency wiring to use released `nomono` and
  generated local override Gemfiles.

### Removed

- Removed generated binstubs that are now resolved through the active bundle.
- Removed the legacy TruffleRuby 23.1 and CodeQL workflow files from generated
  CI.

### Fixed

- Pinned the auto-assign workflow action to the immutable v4 SHA.

## [0.1.0] - 2026-05-23

- TAG: [v0.1.0][0.1.0t]
- COVERAGE: 100.00% -- 72/72 lines in 2 files
- BRANCH COVERAGE: 96.15% -- 25/26 branches in 2 files
- 15.00% documented

### Added

- Initial release

[Unreleased]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.2.4...HEAD
[0.2.4]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.2.3...v0.2.4
[0.2.4t]: https://github.com/galtzo-floss/yard-timekeeper/releases/tag/v0.2.4
[0.2.3]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.2.2...v0.2.3
[0.2.3t]: https://github.com/galtzo-floss/yard-timekeeper/releases/tag/v0.2.3
[0.2.2]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.2.1...v0.2.2
[0.2.2t]: https://github.com/galtzo-floss/yard-timekeeper/releases/tag/v0.2.2
[0.2.1]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.2.0...v0.2.1
[0.2.1t]: https://github.com/galtzo-floss/yard-timekeeper/releases/tag/v0.2.1
[0.2.0]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.1.0...v0.2.0
[0.2.0t]: https://github.com/galtzo-floss/yard-timekeeper/releases/tag/v0.2.0
[0.1.0]: https://github.com/galtzo-floss/yard-timekeeper/compare/bffde1dbf4ceb71a29a72b5b2dfb79622a14417b...v0.1.0
[0.1.0t]: https://github.com/galtzo-floss/yard-timekeeper/releases/tag/v0.1.0
