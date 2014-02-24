# SSH Client and Server Puppet Module

Manage SSH client and server via Puppet

## Client only
Collected host keys from servers will be written to known_hosts

```
    include ssh::client
```

## Server only
Host keys will be collected for client distribution

```
    include ssh::server
```

## Both client and server
Host keys will be collected and distributed

```
    include ssh
```

### Changing options

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

# Requirements
* Exported resources for host keys management
* puppetlabs/stdlib

