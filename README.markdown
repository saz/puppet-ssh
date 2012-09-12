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

# Requirements
Requires Exported resources and augeas in order to work

