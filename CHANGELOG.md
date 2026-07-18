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

### Deprecated

### Removed

### Fixed

- Restored generated YARD title/header metadata from git when rebuilding docs
  with a newer YARD version, including when the file also has real content
  changes that should be preserved.

### Security

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

[Unreleased]: https://github.com/galtzo-floss/yard-timekeeper/compare/v0.2.3...HEAD
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
