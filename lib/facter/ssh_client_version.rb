Facter.add("ssh_client_version_full") do
  if File.exists?('/usr/sbin/sshd')
    version = Facter::Util::Resolution.exec('sshd -V 2>&1').
      lines.
      to_a.
      select { |line| line.match(/^OpenSSH_/) }.
      first.
      rstrip
  end

  setcode do
    if not version.nil?
      version.gsub(/^OpenSSH_([^ ]+).*$/, '\1')
    end
  end
end

Facter.add("ssh_client_version_major") do
  confine :ssh_client_version_full => true
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+).*$/, '\1')
  end
end

Facter.add("ssh_client_version_release") do
  confine :ssh_client_version_full => true
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1')
  end
end
