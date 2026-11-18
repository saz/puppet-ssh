# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server instance lifecycle' do
  # The instance uses its own unit and port, so stopping and starting it does
  # not touch the sshd that carries the Beaker connection.
  def instance_manifest(ensure_state, service_ensure, service_enable)
    <<~PP
      class { 'ssh':
        storeconfigs_enabled => false,
        server_instances     => {
          'test_cleanup' => {
            'ensure'         => '#{ensure_state}',
            'service_ensure' => '#{service_ensure}',
            'service_enable' => #{service_enable},
            'options'        => {
              'sshd_config' => {
                'Port'            => 9022,
                'AddressFamily'   => 'any',
                'HostKey'         => '/etc/ssh/ssh_host_rsa_key',
                'PermitRootLogin' => 'no',
              },
              'sshd_service_options' => '',
              'match_blocks'         => {},
            },
          },
        },
      }
    PP
  end

  context 'create, stop, start and remove a server instance' do
    # Step 1: Create the instance so there is something to stop and purge
    context 'provision instance on port 9022' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) { instance_manifest('present', 'running', true) }
      end

      describe port(9022) do
        it { is_expected.to be_listening }
      end

      describe service('test_cleanup') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe file('/etc/ssh/sshd_config.test_cleanup') do
        it { is_expected.to be_file }
      end
    end

    # Step 2: Stop and disable it. This must not affect the main sshd.
    context 'stop and disable the instance' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) { instance_manifest('present', 'stopped', false) }
      end

      describe port(9022) do
        it { is_expected.not_to be_listening }
      end

      describe service('test_cleanup') do
        it { is_expected.not_to be_enabled }
        it { is_expected.not_to be_running }
      end

      describe file('/etc/ssh/sshd_config.test_cleanup') do
        it { is_expected.to be_file }
      end
    end

    # Step 3: Bring it back up again
    context 'start and enable the instance again' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) { instance_manifest('present', 'running', true) }
      end

      describe port(9022) do
        it { is_expected.to be_listening }
      end

      describe service('test_cleanup') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end

    # Step 4: Remove the instance
    context 'remove the instance' do
      it_behaves_like 'an idempotent resource' do
        let(:manifest) { instance_manifest('absent', 'stopped', false) }
      end

      describe port(9022) do
        it { is_expected.not_to be_listening }
      end

      describe service('test_cleanup') do
        it { is_expected.not_to be_enabled }
        it { is_expected.not_to be_running }
      end

      describe file('/etc/ssh/sshd_config.test_cleanup') do
        it { is_expected.not_to exist }
      end
    end
  end

  context 'primary sshd still healthy after instance removal' do
    service_name = case fact('os.family')
                   when 'Debian'
                     'ssh'
                   else
                     'sshd'
                   end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(22) do
      it { is_expected.to be_listening }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
