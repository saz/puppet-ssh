# frozen_string_literal: true

Facter.add('ssh_server_version_full') do
  confine kernel: %w[Linux SunOS FreeBSD DragonFly Darwin]

  setcode do
    if Facter::Util::Resolution.which('sshd')
      # sshd doesn't actually have a -V option (hopefully one will be added),
      # by happy coincidence the usage information that is printed includes the
      # version number.
      version = Facter::Util::Resolution.exec('sshd -V 2>&1').
                lines.
                to_a.
                select { |line| line.match(%r{^OpenSSH_|^Sun_SSH_}) }.
                first.
                rstrip

      version&.gsub(%r{^(OpenSSH_|Sun_SSH_)([^ ,]+).*$}, '\2')
    end
  end
end

Facter.add('ssh_server_version_major') do
  confine kernel: %w[Linux SunOS FreeBSD DragonFly DragonFly Darwin]
  confine ssh_server_version_full: %r{\d+}
  setcode do
    version = Facter.value('ssh_server_version_full')

    case version
    when %r{([0-9]+)\.([0-9]+)\.([0-9]+p[0-9]+)}
      # 6.6.1p1 style formatting
      version.gsub(%r{([0-9]+)\.([0-9]+)\.([0-9]+p[0-9]+)}, '\1')
    when %r{^([0-9]+)\.([0-9]+p[0-9]+)}
      # 7.2p2 style formatting
      version.gsub(%r{^([0-9]+)\.([0-9]+p[0-9]+)}, '\1')
    end
  end
end

Facter.add('ssh_server_version_release') do
  confine ssh_server_version_full: %r{\d+}
  setcode do
    version = Facter.value('ssh_server_version_full')

    version&.gsub(%r{^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$}, '\1')
  end
end
