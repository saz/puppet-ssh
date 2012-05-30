class ssh::params {
    case $operatingsystem {
        /(Ubuntu|Debian)/: {
            $server_package_name = 'openssh-server'
            $client_package_name = 'openssh-client'
            $sshd_config = '/etc/ssh/sshd_config'
            $ssh_config = '/etc/ssh/ssh_config'
            $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
            $service_name = 'ssh'
        }
        /(CentOS|Fedora|RedHat)/: {
            $server_package_name = 'openssh-server'
            $client_package_name = 'openssh-clients'
            $sshd_config = '/etc/ssh/sshd_config'
            $ssh_config = '/etc/ssh/ssh_config'
            $ssh_known_hosts = '/etc/ssh/ssh_known_hosts'
            $service_name = 'sshd'
        }
        default: {
            fail("Unsupported platform: $operatingsystem")
        }
    }
}
