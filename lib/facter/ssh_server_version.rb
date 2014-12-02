Facter.add("ssh_server_version") do
  setcode do
    # sshd doesn't actually have a -V option (hopefully one will be added),
    # by happy coincidence the usage information that is printed includes the
    # version number.
    Facter::Util::Resolution.exec('sshd -V 2>&1')
      .lines
      .to_a
      .select { |line| line.match(/^OpenSSH_/) }
      .first
      .gsub(/^OpenSSH_([^ ]+).*$/, '\1')
  end
end
