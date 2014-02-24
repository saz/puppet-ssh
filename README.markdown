# SSH Client and Server Puppet Module

Manage SSH client and server via Puppet

### Gittip
[![Support via Gittip](https://rawgithub.com/twolfson/gittip-badge/0.2.0/dist/gittip.png)](https://www.gittip.com/saz/)

## Requirements
* Exported resources for host keys management
* puppetlabs/stdlib

## Usage

### Both client and server
Host keys will be collected and distributed

```
    include ssh
```

or

```
    class { 'ssh':
      server_options => {
        'Match User www-data' => {
          'ChrootDirectory' => '%h',
          'ForceCommand' => 'internal-sftp',
          'PasswordAuthentication' => 'yes',
          'AllowTcpForwarding' => 'no',
          'X11Forwarding' => 'no',
        },
      },
      client_options => {
        'Host *.amazonaws.com' => {
          'User' => 'ec2-user',
        },
      },
    }
```

### Client only
Collected host keys from servers will be written to known_hosts

```
    include ssh::client
```

or

```
    class { 'ssh::client':
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
Host keys will be collected for client distribution

```
    include ssh::server
```

or

```
    class { 'ssh::server':
      options => {
        'Match User www-data' => {
          'ChrootDirectory' => '%h',
          'ForceCommand' => 'internal-sftp',
          'PasswordAuthentication' => 'yes',
          'AllowTcpForwarding' => 'no',
          'X11Forwarding' => 'no',
        },
        'PasswordAuthentication' => 'no',
        'PermitRootLogin' => 'no',
      },
    }
```
