Facter.add("ssh_client_version_full") do
  setcode do
    version = Facter::Util::Resolution.exec('sshd -V 2>&1 || true').
      lines.
      to_a.
      select { |line| line.match(/^OpenSSH_/) }.
      first.
      rstrip

    version.gsub(/^OpenSSH_([^ ]+).*$/, '\1')
  end
end

Facter.add("ssh_client_version_major") do
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+).*$/, '\1')
  end
end

Facter.add("ssh_client_version_release") do
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1')
  end
end
