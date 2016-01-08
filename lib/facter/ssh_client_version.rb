Facter.add("ssh_client_version_full") do
  confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]

  version = Facter::Util::Resolution.exec('ssh -V 2>&1').
    lines.
    to_a.
    select { |line| line.match(/^OpenSSH_/) }.
    first.
    rstrip

  setcode do
    if not version.nil?
      version.gsub(/^OpenSSH_([^ ]+).*$/, '\1')
    end
  end
end

Facter.add("ssh_client_version_major") do
  confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]
  confine :ssh_client_version_full => true
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+).*$/, '\1')
  end
end

Facter.add("ssh_client_version_release") do
  confine :kernel => [ 'Linux' , 'SunOS' , 'FreeBSD' , 'Darwin' ]
  confine :ssh_client_version_full => true
  setcode do
    version = Facter.value('ssh_client_version_full')

    version.gsub(/^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$/, '\1')
  end
end
