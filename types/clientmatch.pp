# OpenSSH client `Match` criteria. See `ssh_config(5)`
type Ssh::ClientMatch = Enum[
  '!all',
  'all',
  '!canonical',
  'canonical',
  '!exec',
  'exec',
  '!final',
  'final',
  '!host',
  'host',
  '!localuser',
  'localuser',
  '!originalhost',
  'originalhost',
  '!user',
  'user',
]
