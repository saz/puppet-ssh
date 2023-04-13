# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [10.0.0]
### Added
- Add support for client "match blocks" (#332, #333)
- Add data file for OpenBSD (#339)
- Add support for service_ensure/service_enable in `ssh::server::instances` (#338)
### Changed
- Use hiera instead of params.pp (#325, #328)
### Fixed
- Fix parameter lookup for `ssh::server` and `ssh::client` (#331)

## [9.0.0]
### Added
- Support for multiple instances (#318, #319, #321) - Thanks!
### Changed
- "hostkeys.pp" isn't marked private anymore (#317)

## [8.0.0]
### Changed
- update path to sftp server on Gentoo (#315, breaking change)

## [7.0.2]
### Added
- allow stdlib < 9.0.0 (#314)

## [7.0.1]
### Fixed
- ssh_config: Don't populate options that are set to undef (#312)

## [7.0.0]
### Fixed
- Fix grammar and spelling in various places
### Changed
- Use GitHub Actions instead of TravisCI
- Update module dependencies
### Removed
- Dropped support for puppet 4 and 5 (Breaking Change)

## [6.2.0]
### Changed
- support older facter versions (#293)

## [6.1.0]
### Fixed
- Fix absolute class name includes
- Use gid 0 instead of group name for $host_priv_key_group (#289)
- Sort hostkeys (#288)
- Do not show diff when installing a ssh private host key (#283)
- Don't populate options which have a value of `undef` (#281)
### Added
- document exclusion of interfaces and ipaddresses within hostkeys.pp (#267)
- add parameter to use trusted facts to hostkeys.pp (#226)

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
