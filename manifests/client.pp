class ssh::client {
    package { $ssh::params::client_package_name:
        ensure => latest,
    }

    include ssh::knownhosts

    ssh::ssh_configline { 'UserKnownHostsFile':
        value => '/dev/null',
    }
}
