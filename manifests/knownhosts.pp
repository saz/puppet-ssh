# @summary
#   This class manages knownhosts if collection is enabled.
#
class ssh::knownhosts (
) {
  if ($ssh::client::collect_enabled) {
    if $ssh::client::storeconfigs_group {
      Sshkey <<| tag == "hostkey_${ssh::client::storeconfigs_group}" |>>
    } else {
      Sshkey <<| |>>
    }
  }
}
