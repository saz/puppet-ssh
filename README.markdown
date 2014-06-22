# puppet-ssh [![Build Status](https://secure.travis-ci.org/saz/puppet-ssh.png)](http://travis-ci.org/saz/puppet-ssh)

Manage SSH client and server via Puppet

### Gittip
[![Support via Gittip](https://rawgithub.com/twolfson/gittip-badge/0.2.0/dist/gittip.png)](https://www.gittip.com/saz/)

## Requirements
* Exported resources for host keys management
* puppetlabs/stdlib

## Usage

Since version 2.0.0 only non-default values are written to both,
client and server, configuration files.

Multiple occurances of one config key (e.g. sshd should be listening on
port 22 and 2222) should be passed as an array.

```
    options => {
      'Port' => [22, 2222],
    }
```

This is working for both, client and server

### Both client and server
Host keys will be collected and distributed unless
 storeconfigs_enabled => false

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
    }
```

### Hiera example
```
ssh::storeconfigs_enabled: true,

ssh::server_options:
    Protocol: '2'
    ListenAddress:
        - '127.0.0.0'
        - '%{::hostname}'
    PasswordAuthentication: 'yes'
    SyslogFacility: 'AUTHPRIV'
    UsePAM: 'yes'
    X11Forwarding: 'yes'

ssh::client_options:
    'Host *':
        SendEnv: 'LANG LC_*'
        ForwardX11Trusted: 'yes'
        ServerAliveInterval: '10'
```
 
### Client only
Collected host keys from servers will be written to known_hosts unless
 storeconfigs_enabled => false

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

### Server only
Host keys will be collected for client distribution unless
 storeconfigs_enabled => false

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

Which will lead to the following sshd_config file:

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

