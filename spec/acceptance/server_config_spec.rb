# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server config' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'with custom server_options' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            server_options       => {
              'PermitRootLogin'        => 'no',
              'X11Forwarding'          => 'no',
              'MaxAuthTries'           => '3',
              'PasswordAuthentication' => 'no',
              'LogLevel'               => 'VERBOSE',
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '600' }
      its(:content) { is_expected.to match(%r{PermitRootLogin no}) }
      its(:content) { is_expected.to match(%r{X11Forwarding no}) }
      its(:content) { is_expected.to match(%r{MaxAuthTries 3}) }
      its(:content) { is_expected.to match(%r{PasswordAuthentication no}) }
      its(:content) { is_expected.to match(%r{LogLevel VERBOSE}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end

  context 'with validate_sshd_file enabled' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            validate_sshd_file   => true,
            server_options       => {
              'PermitRootLogin' => 'yes',
              'X11Forwarding'   => 'yes',
            },
          }
        PP
      end
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'with multi-value options (Port list)' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            server_options       => {
              'Port' => [22, 2222],
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{Port 22}) }
      its(:content) { is_expected.to match(%r{Port 2222}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe port(22) do
      it { is_expected.to be_listening }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end
end
