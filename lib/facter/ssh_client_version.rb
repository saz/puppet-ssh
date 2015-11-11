Facter.add("ssh_client_version_full") do
  confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]
  setcode do
    version = Facter::Util::Resolution.exec('sshd -V 2>&1').
      lines.
      to_a.
      select { |line| line.match(/^OpenSSH_/) }.
      first.
      rstrip

    version.gsub(/^OpenSSH_([^ ]+).*$/, '\1')
  end
end

Facter.add("ssh_client_version_major") do
  confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+).*$/, '\1')
  end
end

Facter.add("ssh_client_version_release") do
  confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1')
  end
end
