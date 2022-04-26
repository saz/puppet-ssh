# @summary
#   This class manages knownhosts if collection is enabled.
#
# @param collect_enabled
#   Enable collection
#
# @param storeconfigs_group
#   Define the hostkeys group storage
#
class ssh::knownhosts (
  Boolean             $collect_enabled    = $ssh::knownhosts::collect_enabled,
  Optional[String[1]] $storeconfigs_group = undef,
) {
  if ($collect_enabled) {
    if $storeconfigs_group {
      Sshkey <<| tag == "hostkey_${storeconfigs_group}" |>>
    } else {
      Sshkey <<| |>>
    }
  }
}
