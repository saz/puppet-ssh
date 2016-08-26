class ssh::knownhosts(
  $collect_enabled = $ssh::params::collect_enabled,
) inherits ssh::params {
  if ($collect_enabled) {
    resources { 'sshkey':
      purge => true,
    }

    Sshkey <<| |>>
  }
}
