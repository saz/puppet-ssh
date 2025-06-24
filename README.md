# Puppet SSH

[![Puppet Forge modules by saz](https://img.shields.io/puppetforge/mc/saz.svg)](https://forge.puppetlabs.com/saz)
[![Puppet Forge](http://img.shields.io/puppetforge/v/saz/ssh.svg)](https://forge.puppetlabs.com/saz/ssh)
[![Puppet Forge downloads](https://img.shields.io/puppetforge/dt/saz/ssh.svg)](https://forge.puppetlabs.com/saz/ssh)
[![Puppet Forge score](https://img.shields.io/puppetforge/f/saz/ssh.svg)](https://forge.puppetlabs.com/saz/ssh)
[![Build Status](https://github.com/saz/puppet-ssh/workflows/CI/badge.svg)](https://github.com/saz/puppet-ssh/actions?query=workflow%3ACI)

Manage SSH client and server via Puppet.

## Requirements

* Exported resources for host keys management
* puppetlabs/stdlib
* puppetlabs/concat

## Usage

Since version 2.0.0 only non-default values are written to both,
client and server, configuration files.

Multiple occurrences of one config key (e.g. sshd should be listening on
port 22 and 2222) should be passed as an array.

```puppet
options => {
  'Port' => [22, 2222],
}
```

This is working for both, client and server.

### Both client, server and per user client configuration

Host keys will be collected and distributed unless
 `storeconfigs_enabled` is `false`.

```puppet
include ssh
```

or

```puppet
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

```yaml
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

ssh::server::match_block:
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

```puppet
include ssh::client
```

or

```puppet
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

```puppet
include ssh::server
```

or

```puppet
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

```puppet
class { 'ssh::server':
  validate_sshd_file => true,
}
```

## Default options

### Client

```puppet
'Host *'                 => {
  'SendEnv'              => 'LANG LC_*',
  'HashKnownHosts'       => 'yes',
  'GSSAPIAuthentication' => 'yes',
}
```

### Server

```puppet
'ChallengeResponseAuthentication' => 'no',
'X11Forwarding'                   => 'yes',
'PrintMotd'                       => 'no',
'AcceptEnv'                       => 'LANG LC_*',
'Subsystem'                       => 'sftp /usr/lib/openssh/sftp-server',
'UsePAM'                          => 'yes',
```

## Overwriting default options

Default options will be merged with options passed in.
If an option is set both as default and via options parameter, the latter
will win.

The following example will disable X11Forwarding, which is enabled by default:

```puppet
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
AcceptEnv LANG LC\_\*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
PasswordAuthentication no
```

Values can also be arrays, which will result in the option being specified multiple times

```puppet
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
AcceptEnv LANG LC_\*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
PasswordAuthentication no
```

## Defining host keys for server

You can define host keys your server will use

```puppet
ssh::server::host_key {'ssh_host_rsa_key':
  private_key_content => '<the private key>',
  public_key_content  => '<the public key>',
}
```

Alternately, you could create the host key providing the files, instead
of the content:

```puppet
ssh::server::host_key {'ssh_host_rsa_key':
  private_key_source => 'puppet:///mymodule/ssh_host_rsa_key',
  public_key_source  => 'puppet:///mymodule/ssh_host_rsa_key.pub',
}
```

Both of these definitions will create ```/etc/ssh/ssh_host_rsa_key``` and
```/etc/ssh/ssh_host_rsa_key.pub``` and restart sshd daemon.

## Adding custom match blocks

```puppet
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

## Tag hostkey

Assign tags to exported `sshkey` resources (when `ssh::storeconfigs_enabled` is set to `true`).

```yaml
ssh::hostkeys::tags:
  - hostkey_group1
  - hostkey_group2
```

Host keys then can be imported using:

```puppet
Sshkey <<| tag == "hostkey_group1" |>>
```

## Excluding network interfaces or ipaddresses

Use hiera to exclude interfaces or ipaddresses from hostkey inclusion

```yaml
ssh::hostkeys::exclude_interfaces:
  - eth0
  - eth3
ssh::hostkeys::exclude_ipaddresses:
  - 192.168.0.1
  - 10.42.24.242
```

## Windows

This module also has support for the Windows Capability ("Optional Feature") `OpenSSH.Server`. Other ways regarding the installation and configuration of sshd on windows might just work (e.g. chocholatey), but have not been tested so far and could thus require modifications.

`data/osfamily/windows.yaml` could look like follows:

```yaml
---
ssh::server::server_package_name: null
ssh::client::client_package_name: null
ssh::server::sshd_dir: 'C:\ProgramData\ssh'
ssh::server::sshd_binary: 'C:\Windows\System32\OpenSSH\sshd.exe'
ssh::server::sshd_config: 'C:\ProgramData\ssh\sshd_config'
ssh::server::sshd_config_mode: '0700'
ssh::server::sshd_environments_file: null
ssh::client::ssh_config: 'C:\ProgramData\ssh\ssh_config'
ssh::server::service_name: 'sshd'
ssh::sftp_server_path: 'C:\Windows\System32\OpenSSH\sftp-server.exe'
ssh::client::config_user: 'BUILTIN\Administrators'
ssh::client::config_group: 'Administrator'
ssh::server::config_user: null
ssh::server::config_group: null
ssh::server::host_priv_key_user: 'BUILTIN\Administrators'
ssh::server::host_priv_key_group: 'NT AUTHORITY\SYSTEM'
```

To correctly set the file permissions, the [`puppetlabs-acl`-puppet module](https://forge.puppetlabs.com/modules/puppetlabs/acl) is required. Remove the unsupported `UsePAM`-sshd config option.

One can optionally set the default shell when connecting through ssh, e.g. to powershell. For this, the [`puppetlabs-registry`-puppet module](https://forge.puppet.com/modules/puppetlabs/registry) is required.

```puppet
$sshd_dir = lookup('ssh::server::sshd_dir')
$sshd_config = lookup('ssh::server::sshd_config')
$config_user = lookup('ssh::server::config_user')
$config_group = lookup('ssh::server::config_group')

$os_family = $facts['os']['family']

$os_specific_path_separator = $os_family ? {
  'windows' => '\\',
  default   => '/',
}

$host_key_paths = [
  "${sshd_dir}${os_specific_path_separator}ssh_host_ed25519_key",
  "${sshd_dir}${os_specific_path_separator}ssh_host_rsa_key",
  "${sshd_dir}${os_specific_path_separator}ssh_host_ecdsa_key",
]

if $os_family == 'windows' {
  exec { 'install_openssh_server':
    command   => 'Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0',
    provider  => powershell,
    unless    => 'if ((Get-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0).State -eq "Installed") { echo 0 } else { exit 1 }',
    logoutput => true,
    before    => Class['ssh::server'],
  }

  $initialize_sshd_command = @(EOT)
Write-Output "Initializing SSHD service..."
Start-Service -Name 'sshd'
Start-Sleep -Seconds 5
$status = Get-Service -Name 'sshd'
Write-Output "Service status: $($status.Status)"
Stop-Service -Name 'sshd'
Write-Output "SSHD service initialization completed"
| EOT

  # this is required, so that sshd creates all directories and files by itself and sets the appropriate permissions
  exec { 'initialize_sshd':
    command   => $initialize_sshd_command,
    provider  => powershell,
    creates   => $host_key_paths,
    logoutput => true,
    require   => Exec['install_openssh_server'],
    before    => Class['ssh::server'],
  }

  acl { $sshd_config:
    permissions => [
      {
        identity  => $config_group,
        rights    => ['full'],
        perm_type => 'allow',
      },
      {
        identity  => $config_user,
        rights    => ['full'],
        perm_type => 'allow',
      },
    ],
    inherit_parent_permissions => false,
    purge   => true,
    require => Class['ssh::server::config'],
    before  => Class['ssh::server::service'],
  }

  registry::value { 'set_powershell_as_default_ssh_shell':
    key     => 'HKLM:\SOFTWARE\OpenSSH',
    name    => 'DefaultShell',
    type    => 'string',
    data    => 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
    require => Exec['install_openssh_server'],
  }
}

$os_specific_ssh_options = $os_family ? {
  'windows' => {
    'UsePAM' => undef,
  },
  default => {},
}

class { 'ssh::server':
  storeconfigs_enabled => false,
  validate_sshd_file   => true,
  options              => {
    # ...
  } + $os_specific_ssh_options,
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
