# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server config_file and include_dir' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'with include_dir and a config_file' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh::server':
            storeconfigs_enabled => false,
            include_dir          => '/etc/ssh/sshd_config.d',
            options              => {
              'PermitRootLogin' => 'yes',
            },
            config_files         => {
              'hardening' => {
                'options' => {
                  'MaxAuthTries'  => '3',
                  'MaxSessions'   => '5',
                },
              },
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config.d') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '700' }
    end

    describe file('/etc/ssh/sshd_config.d/hardening.conf') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      its(:content) { is_expected.to match(%r{MaxAuthTries 3}) }
      its(:content) { is_expected.to match(%r{MaxSessions 5}) }
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{Include /etc/ssh/sshd_config\.d/\*\.conf}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end
end
