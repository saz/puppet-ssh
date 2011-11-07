define ssh::ssh_configline ($value) {
    augeas {
        "ssh_config_$name":
            context => "/files/etc/ssh/ssh_config",
            changes => "set $name $value",
            onlyif  => "get $name != $value",
        }
    }
}
