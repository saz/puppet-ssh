define ssh::server::configline ($value) {
    augeas { "sshd_config_$name":
            context => "/files${ssh::params::sshd_config}",
            changes => "set $name $value",
            onlyif  => "get $name != $value",
    }
}
