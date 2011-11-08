class ssh::params {
    case $operatingsystem {
        /(Ubuntu|Debian)/: {
            $server_package_name = 'openssh-server'
            $client_package_name = 'openssh-client'
            $sshd_config = '/etc/ssh/sshd_config'
            $ssh_config = '/etc/ssh/ssh_config'
            $service_name = 'ssh'
        }
    }
}
