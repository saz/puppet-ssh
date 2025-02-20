# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [13.1.0]
### Added
- puppet/systemd: allow 8.x (#404)

## [13.0.0]
### Removed
- BREAKING CHANGE: remove Ubuntu 18.04 as supported OS (#402)
### Fixed
- ssh_instance: write ciphers,macs and kex as comma-separated string (#401)
- Purge and Recurse should be set together (#399)
### Added
- Add support for sshd_config include files (#390)
### Changed
- Set merge behavior of ssh::server_instances to deep (#395)

## [12.1.0]
### Added
- allow puppet/systemd < 8, fixes #382
### Changed
- set sshd config mode to 0644 on AIX, fixes #371 (#383)
- use `contain` instead of `include`, fixes #367 (#387)
### Fixed
- fix tests on OpenBSD (#384)
- drop tag from concat_{file,fragment}, fixes #304 (#385)
- fix subsystem option if use_augeas = true, fixes #376 (#386)

## [12.0.1]
### Fixed
- make ssh::hostkeys::exclude_interfaces_re parameter work properly (#380)

## [12.0.0]
### Added
- add parameter to exclude interfaces with a regex (#378)
- Allow User to add additonal systemd options to instances (#374)
### Changed
- puppet/systemd: Allow 6.x (#364)
### Fixed
- allow ssh::server::ensure = latest, fixes #370 (#377)

## [11.1.0]
### Fixed
- write ciphers,macs and kex as comma-separated string (#362)
- Fix "No ssh_server_version_major created with OpenSSH 9.2" (#359)

## [11.0.0]
### Removed
- BREAKING CHANGE: drop support for puppet 6
### Changed
- puppetlabs/concat: Allow 9.x (#354)
- puppet/systemd: Allow 5.x (#354)
- puppetlabs/stdlib: Require 9.x (#354)
### Added
- add Debian 12 as supported OS

## [10.2.0]
### Changed
- bump puppetlabs/concat to < 9.0.0 (#352)
- Replace deprecated functions (#350)

## [10.1.0]
### Added
- Support assigning multiple tags to a hostkey (#345)
- Add AIX support (#341)
### Changed
- bump puppet/systemd to < 5.0.0 (#344)
### Fixed
- Fix for service name on latest versions of opensuse. (#343)

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
