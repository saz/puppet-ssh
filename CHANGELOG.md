# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.0.0]
### Fixed
- don't fail at deep_merge if hiera data not available, see #272
- Fix typo in match_block example in README, see #271, #273
### Added
- Add CHANGELOG (starting with this release), see #222
- Test module with Puppet 6.1, see #269
### Changed
- Convert `ipaddresses` to 4x API namespaced function, see #270
- Allow `puppetlabs` `stdlib` and `concat` 6.x, see #280
