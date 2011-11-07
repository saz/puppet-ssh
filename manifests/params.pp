class ssh::params {
    case $operatingsystem {
        /(Ubuntu|Debian)/: {
            $package_name = 'openssh-server'
            $client_package_name = 'openssh-client'
            $service_config = '/etc/ssh/sshd_config'
            $service_name = 'ssh'
        }
    }
}
