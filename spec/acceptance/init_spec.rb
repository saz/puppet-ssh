# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh' do
  package_name = case fact('os.family')
                 when 'Archlinux'
                   'openssh'
                 else
                   'openssh-server'
                 end
  context 'with defaults' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        'include ssh'
      end

      describe package(package_name) do
        it { is_expected.to be_installed }
      end

      describe port(22) do
        it { is_expected.to be_listening }
      end

      describe service('sshd') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  end

  context 'Server with a seperate sftp_server_init instance on Port 8022' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'ssh':
          server_instances => {
            'sftp_server_init' => {
              'ensure' => 'present',
              'options' => {
                'sshd_config' => {
                  'Port' => 8022,
                  'Protocol' => 2,
                  'AddressFamily' => 'any',
                  'HostKey' => '/etc/ssh/ssh_host_rsa_key',
                  'SyslogFacility' => 'AUTH',
                  'LogLevel' => 'INFO',
                  'PermitRootLogin' => 'no',
                },
                'sshd_service_options' => '',
                'match_blocks' => {},
              },
            },
          },
        }
        PUPPET
      end

      describe package(package_name) do
        it { is_expected.to be_installed }
      end

      describe port(8022) do
        it { is_expected.to be_listening }
      end

      describe service('sftp_server_init') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  end
end
