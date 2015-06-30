class ssh::knownhosts {
# remove ssh keys not managed by puppet
  resources  { 'sshkey':
    purge => true,
  }

  Sshkey <<| |>>
}
