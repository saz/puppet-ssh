# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server service management' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  # Do not stop the main sshd here: it carries the Beaker connection, and
  # Debian's ssh.service uses KillMode=process. That leaves the connection's
  # sshd-session processes in the unit cgroup, and a subsequent start can
  # collide with a leftover listener on port 22 (see #465). Stop/start
  # coverage lives in server_purge_spec.rb, which uses a disposable instance
  # on port 9022 instead.
  context 'with service running and enabled' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh::server':
            storeconfigs_enabled => false,
            service_ensure       => 'running',
            service_enable       => true,
          }
        PP
      end
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(22) do
      it { is_expected.to be_listening }
    end
  end
end
