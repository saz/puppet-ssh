Facter.add("ssh_server_version") do
  setcode do
    # sshd doesn't actually have a -V option (hopefully one will be added),
    # by happy coincidence the usage information that is printed includes the
    # version number.
    version = Facter::Util::Resolution.exec('sshd -V 2>&1')
      .lines
      .to_a
      .select { |line| line.match(/^OpenSSH_/) }
      .first
      .rstrip

    {
      'major' => version.gsub(/^OpenSSH_([0-9]+\.[0-9]+).*$/, '\1'),
      'release' => version.gsub(/^OpenSSH_([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1'),
      'portable' => version.gsub(/^OpenSSH_[0-9]+\.[0-9]+(?:\.[0-9]+)?p([0-9]+).*$/, '\1'),
      'full' => version.gsub(/^OpenSSH_([^ ]+).*$/, '\1'),
    }
  end
end
