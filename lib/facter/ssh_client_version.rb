Facter.add("ssh_client_version") do
  setcode do
    version = Facter::Util::Resolution.exec('ssh -V 2>&1')
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
