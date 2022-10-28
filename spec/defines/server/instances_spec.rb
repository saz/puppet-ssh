# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server::instances' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}", if: os_facts[:kernel] == 'Linux' do
      let(:facts) { os_facts }
      let(:title) { 'sftp_server' }
      let :pre_condition do
        'include ssh'
      end

      context 'with sftp_server present' do
        let(:params) do
          {
            'ensure' => 'present',
            'options' => {
              'sshd_config' => {
                'Port' => 8022,
                'Protocol' => 2,
                'AddressFamily' => 'any',
                'HostKey' => '/etc/ssh/ssh_host_rsa_key',
                'SyslogFacility' => 'AUTH',
                'LogLevel' => 'INFO',
                'LoginGraceTime' => 120,
                'PermitRootLogin' => 'no',
                'StrictModes' => 'yes',
                'PubkeyAuthentication' => 'yes',
                'HostbasedAuthentication' => 'no',
                'IgnoreUserKnownHosts' => 'no',
                'IgnoreRhosts' => 'yes',
                'PasswordAuthentication' => 'yes',
                'ChallengeResponseAuthentication' => 'no',
                'GSSAPIAuthentication' => 'no',
                'GSSAPIKeyExchange' => 'no',
                'GSSAPICleanupCredentials' => 'yes',
                'UsePAM' => 'yes',
                'AcceptEnv' => %w[LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION LC_ALL],
                'AllowTcpForwarding' => 'no',
                'X11Forwarding' => 'no',
                'X11UseLocalhost' => 'yes',
                'PrintMotd' => 'yes',
                'TCPKeepAlive' => 'yes',
                'ClientAliveInterval' => 0,
                'ClientAliveCountMax' => 0,
                'UseDNS' => 'no',
                'PermitTunnel' => 'no',
                'Banner' => '/etc/ssh/sshd_banner.txt',
                'XAuthLocation' => '/usr/bin/xauth',
                'Subsystem' => 'sftp /usr/libexec/openssh/sftp-server',
                'Ciphers' => %w[aes128-ctr aes192-ctr aes256-ctr aes128-cbc 3des-cbc aes192-cbc aes256-cbc],
                'AllowGroups' => 'root lclssh ssh_all_systems VmAdmins',
              },
              'sshd_service_options' => '',
              'match_blocks' => {
                '*,!ssh_exempt_ldap_authkey,!sshlokey' => {
                  'type' => 'group',
                  'options' => {
                    'AuthorizedKeysCommand' => '/usr/local/bin/getauthkey',
                    'AuthorizedKeysCommandUser' => 'nobody',
                    'AuthorizedKeysFile' => '/dev/null',
                  },
                },
                'ssh_deny_pw_auth,sshdnypw' => {
                  'type' => 'group',
                  'options' => {
                    'KbdInteractiveAuthentication' => 'no',
                    'PasswordAuthentication' => 'no',
                  },
                },
              },
            },
            'service_ensure' => 'running',
            'service_enable' => true,
            'validate_config_file' => true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config.sftp_server') }
        it { is_expected.to contain_concat__fragment('sshd instance sftp_server config') }
        it { is_expected.to contain_ssh__server__match_block('ssh_deny_pw_auth,sshdnypw') }
        it { is_expected.to contain_ssh__server__match_block('*,!ssh_exempt_ldap_authkey,!sshlokey') }
        it { is_expected.to contain_systemd__unit_file('sftp_server.service') }
        it { is_expected.to contain_service('sftp_server.service') }
      end

      context 'with minimal params' do
        let(:params) do
          {
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
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('sshd instance sftp_server config') }
        it { is_expected.to contain_systemd__unit_file('sftp_server.service').with_enable(true).with_active(true) }
        it { is_expected.to contain_service('sftp_server.service').with_ensure(true).with_enable(true) }
      end

      context 'with minimal example and ensure stopped' do
        let(:params) do
          {
            'ensure' => 'absent',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('sshd instance sftp_server config') }
        it { is_expected.to contain_systemd__unit_file('sftp_server.service').with_enable(false).with_active(false) }
        it { is_expected.to contain_service('sftp_server.service').with_enable(false).with_ensure(false) }
      end

      context 'with minimal example and service stopped' do
        let(:params) do
          {
            'service_ensure' => 'stopped',
            'service_enable' => true,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('sshd instance sftp_server config') }
        it { is_expected.to contain_systemd__unit_file('sftp_server.service').with_enable(true).with_active(false) }
        it { is_expected.to contain_service('sftp_server.service').with_enable(true).with_ensure(false) }
      end

      context 'with minimal example and service running but not in autostart' do
        let(:params) do
          {
            'ensure' => 'present',
            'service_enable' => false,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('sshd instance sftp_server config') }
        it { is_expected.to contain_systemd__unit_file('sftp_server.service').with_enable(false).with_active(true) }
        it { is_expected.to contain_service('sftp_server.service').with_enable(false).with_ensure(true) }
      end
    end
  end
end
