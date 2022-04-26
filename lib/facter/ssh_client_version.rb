# frozen_string_literal: true

Facter.add('ssh_client_version_full') do
  confine kernel: %w[Linux SunOS FreeBSD DragonFly Darwin]

  setcode do
    if Facter::Util::Resolution.which('ssh')
      version = Facter::Util::Resolution.exec('ssh -V 2>&1').
                lines.
                to_a.
                select { |line| line.match(%r{^OpenSSH_|^Sun_SSH_}) }.
                first.
                rstrip

      version&.gsub(%r{^(OpenSSH_|Sun_SSH_)([^ ,]+).*$}, '\2')
    end
  end
end

Facter.add('ssh_client_version_major') do
  confine kernel: %w[Linux SunOS FreeBSD DragonFly Darwin]
  confine ssh_client_version_full: true
  setcode do
    version = Facter.value('ssh_client_version_full')

    version&.gsub(%r{^([0-9]+\.[0-9]+).*$}, '\1')
  end
end

Facter.add('ssh_client_version_release') do
  confine kernel: %w[Linux SunOS FreeBSD DragonFly Darwin]
  confine ssh_client_version_full: true
  setcode do
    version = Facter.value('ssh_client_version_full')

    version&.gsub(%r{^([0-9]+\.[0-9]+(?:\.[0-9]+)?).*$}, '\1')
  end
end
