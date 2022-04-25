# OpenSSH client `Match` criteria. See `ssh_config(5)`
type Ssh::ClientMatch = Enum[
  'all',
  'canonical',
  'exec',
  'final',
  'host',
  'localuser',
  'originalhost',
  'user',
]
