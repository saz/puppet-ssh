if fact('os.name') == 'Debian' and !fact('aio_agent_version') {
  package { ['puppet-module-puppetlabs-sshkeys-core']:
    ensure => present,
  }
}
