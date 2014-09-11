#/etc/puppet/modules/ssh/manifests/user_keys.pp

class ssh::user_keys (

  $keycontent  = '',
  $sshkeysdir  = '',
  $user        = '',

) { file {"${sshkeysdir}/${user}.pub":
    content  => $keycontent,
    owner    => $user,
    group    => root,
    mode     => '0640',
    require  => File["$ssh::params::sshd_keysdir"],
  }
}
