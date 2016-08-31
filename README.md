# Puppet SSH [![Support via Gratipay](https://cdn.rawgit.com/gratipay/gratipay-badge/2.3.0/dist/gratipay.svg)](https://gratipay.com/~saz/)

[![Puppet Forge modules by saz](https://img.shields.io/puppetforge/mc/saz.svg)](https://forge.puppetlabs.com/saz)
[![Puppet Forge](http://img.shields.io/puppetforge/v/saz/ssh.svg)](https://forge.puppetlabs.com/saz/ssh)
[![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/saz/ssh.svg)](https://forge.puppetlabs.com/saz/ssh)
[![Puppet Forge score](https://img.shields.io/puppetforge/f/saz/ssh.svg)](https://forge.puppetlabs.com/saz/ssh)
[![Build Status](https://travis-ci.org/saz/puppet-ssh.png)](https://travis-ci.org/saz/puppet-ssh)

Manage SSH client and server via Puppet.
Source: https://github.com/saz/puppet-ssh

## Requirements
* Exported resources for host keys management
* puppetlabs/stdlib
* puppetlabs/concat

## Usage

Since version 2.0.0 only non-default values are written to both,
client and server, configuration files.

Multiple occurrences of one config key (e.g. sshd should be listening on
port 22 and 2222) should be passed as an array.

```
    options => {
      'Port' => [22, 2222],
    }
```

This is working for both, client and server.

### Both client, server and per user client configuration
Host keys will be collected and distributed unless
 `storeconfigs_enabled` is `false`.

```
    include ssh
```

or

```
    class { 'ssh':
      storeconfigs_enabled => false,
      server_options => {
        'Match User www-data' => {
          'ChrootDirectory' => '%h',
          'ForceCommand' => 'internal-sftp',
          'PasswordAuthentication' => 'yes',
          'AllowTcpForwarding' => 'no',
          'X11Forwarding' => 'no',
        },
        'Port' => [22, 2222, 2288],
      },
      client_options => {
        'Host *.amazonaws.com' => {
          'User' => 'ec2-user',
        },
      },
      users_client_options => {
        'bob' => {
          options => {
            'Host *.alice.fr' => {
              'User' => 'alice',
            },
          },
        },
      },
    }
```

### Hiera example
```
ssh::storeconfigs_enabled: true

ssh::server_options:
    Protocol: '2'
    ListenAddress:
        - '127.0.0.0'
        - '%{::hostname}'
    PasswordAuthentication: 'yes'
    SyslogFacility: 'AUTHPRIV'
    UsePAM: 'yes'
    X11Forwarding: 'yes'

ssh::server_match_block:
  filetransfer:
    type: group
    options:
      ChrootDirectory: /home/sftp
      ForceCommand: internal-sftp

ssh::client_options:
    'Host *':
        SendEnv: 'LANG LC_*'
        ForwardX11Trusted: 'yes'
        ServerAliveInterval: '10'

ssh::users_client_options:
    'bob':
        'options':
            'Host *.alice.fr':
                'User': 'alice'
                'PasswordAuthentication': 'no'
```

### Client only
Collected host keys from servers will be written to `known_hosts` unless
 `storeconfigs_enabled` is `false`

```
    include ssh::client
```

or

```
    class { 'ssh::client':
      storeconfigs_enabled => false,
      options => {
        'Host short' => {
          'User' => 'my-user',
          'HostName' => 'extreme.long.and.complicated.hostname.domain.tld',
        },
        'Host *' => {
          'User' => 'andromeda',
          'UserKnownHostsFile' => '/dev/null',
        },
      },
    }
```

### Per user client configuration

**User's home is expected to be /home/bob**

SSH configuration file will be `/home/bob/.ssh/config`.

```puppet
::ssh::client::config::user { 'bob':
  ensure => present,
  options => {
    'HashKnownHosts' => 'yes'
  }
}
```

**User's home is passed to define type**

SSH configuration file will be `/var/lib/bob/.ssh/config` and puppet will
manage directory `/var/lib/bob/.ssh`.

```puppet
::ssh::client::config::user { 'bob':
  ensure => present,
  user_home_dir => '/var/lib/bob',
  options => {
    'HashKnownHosts' => 'yes'
  }
}
```

**User's ssh directory should not be managed by the define type**

SSH configuration file will be `/var/lib/bob/.ssh/config`.

```puppet
::ssh::client::config::user { 'bob':
  ensure => present,
  user_home_dir => '/var/lib/bob',
  manage_user_ssh_dir => false,
  options => {
    'HashKnownHosts' => 'yes'
  }
}
```

**User's ssh config is specified with an absolute path**

```puppet
::ssh::client::config::user { 'bob':
  ensure => present,
  target => '/var/lib/bob/.ssh/ssh_config',
  options => {
    'HashKnownHosts' => 'yes'
  }
}
```

### Server only
Host keys will be collected for client distribution unless
 `storeconfigs_enabled` is `false`

```
    include ssh::server
```

or

```
    class { 'ssh::server':
      storeconfigs_enabled => false,
      options => {
        'Match User www-data' => {
          'ChrootDirectory' => '%h',
          'ForceCommand' => 'internal-sftp',
          'PasswordAuthentication' => 'yes',
          'AllowTcpForwarding' => 'no',
          'X11Forwarding' => 'no',
        },
        'PasswordAuthentication' => 'no',
        'PermitRootLogin'        => 'no',
        'Port'                   => [22, 2222],
      },
    }
```

### Validate config before replacing it

`validate_sshd_file` allows you to run `/usr/sbin/sshd -tf` against the sshd config file before it gets replaced, and will raise an error if the config is incorrect.

```
class { 'ssh::server':
  validate_sshd_file => true,
}
```


## Default options

### Client

```
    'Host *'                 => {
      'SendEnv'              => 'LANG LC_*',
      'HashKnownHosts'       => 'yes',
      'GSSAPIAuthentication' => 'yes',
    }
```

### Server

```
    'ChallengeResponseAuthentication' => 'no',
    'X11Forwarding'                   => 'yes',
    'PrintMotd'                       => 'no',
    'AcceptEnv'                       => 'LANG LC_*',
    'Subsystem'                       => 'sftp /usr/lib/openssh/sftp-server',
    'UsePAM'                          => 'yes',
```

## Overwriting default options
Default options will be merged with options passed in.
If an option is set both as default and via options parameter, the latter will
will win.

The following example will disable X11Forwarding, which is enabled by default:

```
    class { 'ssh::server':
      options           => {
        'X11Forwarding' => 'no',
      },
    }
```

Which will lead to the following `sshd_config` file:

 ```
# File is managed by Puppet

ChallengeResponseAuthentication no
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
PasswordAuthentication no
```

Values can also be arrays, which will result in the option being specified multiple times

```
    class { 'ssh::server':
      options           => {
        'HostKey' => ['/etc/ssh/ssh_host_ed25519_key', '/etc/ssh/ssh_host_rsa_key'],
      },
    }
```

Which will lead to the following `sshd_config` file:

 ```
# File is managed by Puppet

ChallengeResponseAuthentication no
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
PasswordAuthentication no
```

## Defining host keys for server
You can define host keys your server will use

```
ssh::server::host_key {'ssh_host_rsa_key':
  private_key_content => '<the private key>',
  public_key_content  => '<the public key>',
}
```

Alternately, you could create the host key providing the files, instead
of the content:

```
ssh::server::host_key {'ssh_host_rsa_key':
  private_key_source => 'puppet:///mymodule/ssh_host_rsa_key',
  public_key_source  => 'puppet:///mymodule/ssh_host_rsa_key.pub',
}
```

Both of these definitions will create ```/etc/ssh/ssh_host_rsa_key``` and
```/etc/ssh/ssh_host_rsa_key.pub``` and restart sshd daemon.


## Adding custom match blocks

```
class YOURCUSTOMCLASS {

  include ssh

  ssh::server::match_block { 'sftp_only':
    type    => 'User',
    options => {
      'ChrootDirectory'        => "/sftp/%u",
      'ForceCommand'           => 'internal-sftp',
      'PasswordAuthentication' => 'no',
      'AllowTcpForwarding'     => 'no',
      'X11Forwarding'          => 'no',
    }
  }
}
```

## Facts

This module provides facts detailing the available SSH client and server
versions.

* `ssh_*_version_full` Provides the full version number including the portable
  version number.
* `ssh_*_version_major` Provides the first two numbers in the version number.
* `ssh_*_version_release` Provides the first three number components of the
  version, no portable version is present.

Example facter output for OpenSSH `6.6.1p1`:

```
ssh_client_version_full => 6.6.1p1
ssh_client_version_major => 6.6
ssh_client_version_release => 6.6.1
ssh_server_version_full => 6.6.1p1
ssh_server_version_major => 6.6
ssh_server_version_release => 6.6.1
```
