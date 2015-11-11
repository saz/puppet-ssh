Facter.add("ssh_server_version_full") do
  confine :kernel => :linux
  setcode do
    # sshd doesn't actually have a -V option (hopefully one will be added),
    # by happy coincidence the usage information that is printed includes the
    # version number.
    version = Facter::Util::Resolution.exec('sshd -V 2>&1').
      lines.
      to_a.
      select { |line| line.match(/^OpenSSH_/) }.
      first.
      rstrip

    version.gsub(/^OpenSSH_([^ ]+).*$/, '\1')
  end
end

Facter.add("ssh_server_version_major") do
  confine :kernel => :linux
  setcode do
    version = Facter.value('ssh_server_version_full')

    version.gsub(/^([0-9]+\.[0-9]+).*$/, '\1')
  end
end

Facter.add("ssh_server_version_release") do
  confine :kernel => :linux
  setcode do
    version = Facter.value('ssh_server_version_full')

    version.gsub(/^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1')
  end
end
