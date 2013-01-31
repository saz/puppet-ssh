class ssh::client {
case $::operatingsystem {
        Archlinux:{
          include ssh::params
          include ssh::client::config
          include ssh::knownhosts
        }
        default: {
          include ssh::params
          include ssh::client::install
          include ssh::client::config
          include ssh::knownhosts
        }
      }

}
