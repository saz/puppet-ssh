define ssh::server::configline ($ensure = present, $value = false) {
    include ssh::server

    Augeas { 
        context => "/files${ssh::params::sshd_config}",
        notify  => Class['ssh::server::service'],
        require => Class['ssh::server::config'],
    }

    case $ensure {
        present: {
            augeas { "sshd_config_${name}":
                    changes => "set ${name} ${value}",
                    onlyif  => "get ${name} != ${value}",
            }
        }
        add: {
        	augeas {
        		"sshd_config_${name}":
        			changes => ["ins ${name} after ${name}[last()]",
        			"set ${name}[last()] ${value}"],
        			onlyif => "get ${name}[. = '${value}'] != ${value}",
        	}
        }
        absent: {
            augeas { "sshd_config_${name}":
                changes => "rm ${name}",
                onlyif  => "get ${name}",
            }
        }
    }
}
