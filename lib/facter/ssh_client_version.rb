Facter.add("ssh_client_version") do
  setcode do
    Facter::Util::Resolution.exec('ssh -V 2>&1')
      .lines
      .to_a
      .select { |line| line.match(/^OpenSSH_/) }
      .first
      .gsub(/^OpenSSH_([^ ]+).*$/, '\1')
  end
end
