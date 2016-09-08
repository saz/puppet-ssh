Facter.add('ssh_server_version_full') do
  confine :kernel => %w(Linux SunOS FreeBSD Darwin)

  setcode do
    # sshd doesn't actually have a -V option (hopefully one will be added),
    # by happy coincidence the usage information that is printed includes the
    # version number.
    version = Facter::Util::Resolution.exec('sshd -V 2>&1').
              lines.
              to_a.
              select { |line| line.match(%r{^OpenSSH_}) }.
              first.
              rstrip

    version.gsub(%r{^OpenSSH_([^ ]+).*$}, '\1') unless version.nil?
  end
end

Facter.add('ssh_server_version_major') do
  confine :kernel => %w(Linux SunOS FreeBSD Darwin)
  confine :ssh_server_version_full => true
  setcode do
    version = Facter.value('ssh_server_version_full')

    version.gsub(%r{^([0-9]+\.[0-9]+).*$}, '\1')
  end
end

Facter.add('ssh_server_version_release') do
  confine :kernel => %w(Linux SunOS FreeBSD Darwin)
  confine :ssh_server_version_full => true
  setcode do
    version = Facter.value('ssh_server_version_full')

    version.gsub(%r{^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$}, '\1')
  end
end
