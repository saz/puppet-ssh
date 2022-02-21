require 'spec_helper'

describe 'ssh', type: 'class' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      context 'Server with a seperate sftp_server_init instance on Port 8022' do
        let :params do
          {
            'server_instances' => {
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
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config_sftp_server_init') }
        it { is_expected.to contain_concat__fragment('sshd instance sftp_server_init config') }
        it { is_expected.to contain_systemd__unit_file('sftp_server_init.service') }
        it { is_expected.to contain_service('sftp_server_init.service') }
        it { is_expected.to contain_ssh__server__instances('sftp_server_init') }
        it { is_expected.to contain_class('ssh::client') }
        it { is_expected.to contain_class('ssh::server') }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil) }
        it { is_expected.to contain_resources('sshkey').with_purge(true) }
      end
      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
      end
      context 'with the validate_sshd_file setting' do
        let :params do
          {
            validate_sshd_file: true
          }
        end

        it { is_expected.to contain_class('ssh::client') }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd('/usr/sbin/sshd -tf %') }
      end
      context 'without resource purging' do
        let :params do
          {
            purge_unmanaged_sshkeys: false
          }
        end

        it { is_expected.not_to contain_resources('sshkey') }
      end
      context 'with no other parameters' do
        it { is_expected.to contain_class('ssh::client') }
        it { is_expected.to contain_class('ssh::server') }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil) }
        it { is_expected.to contain_resources('sshkey').with_purge(true) }
      end
    end
  end
end
