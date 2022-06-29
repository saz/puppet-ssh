# frozen_string_literal: true

require 'spec_helper'

describe 'ssh', type: 'class' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      case os_facts[:os]['family']
      when 'Debian'
        client_package = 'openssh-client'
        server_package = 'openssh-server'
        sftp_server_path = '/usr/lib/openssh/sftp-server'
      when 'Archlinux'
        client_package = 'openssh'
        server_package = 'openssh'
        sftp_server_path = '/usr/lib/ssh/sftp-server'
      when 'Amazon', 'RedHat'
        client_package = 'openssh-clients'
        server_package = 'openssh-server'
        sftp_server_path = '/usr/libexec/openssh/sftp-server'
      when 'Gentoo'
        client_package = 'openssh'
        server_package = 'openssh'
        sftp_server_path = '/usr/lib64/misc/sftp-server'
      when 'Solaris'
        case os_facts[:os]['release']['major']
        when 10
          client_package = 'SUNWsshu'
          server_package = 'SUNWsshdu'
        else
          client_package = '/network/ssh'
          server_package = '/service/network/ssh'
        end
        sftp_server_path = 'internal-sftp'
      when 'SmartOS'
        sftp_server_path = 'internal-sftp'
      when 'Suse'
        client_package = 'openssh'
        server_package = 'openssh'
        case os_facts[:os]['name']
        when 'OpenSuSE'
          sftp_server_path = '/usr/lib/ssh/sftp-server'
        when 'SLES'
          sftp_server_path = case os_facts[:os]['release']['major']
                             when 10, 11
                               '/usr/lib64/ssh/sftp-server'
                             else
                               '/usr/lib/ssh/sftp-server'
                             end
        end
      else
        client_package = nil
        server_package = nil
        sftp_server_path = '/usr/libexec/sftp-server'
      end

      case os_facts[:os]['family']
      when 'Solaris'
        ssh_config_expected_default = "# File managed by Puppet\n\n"
        ssh_config_expected_custom = "# File managed by Puppet\n\nHostFoo\n    HostName bar\nSomeOtherKey someValue\n"
        sshd_config_default = "# File is managed by Puppet\n\nChallengeResponseAuthentication no\nHostKey /etc/ssh/ssh_host_rsa_key\nHostKey /etc/ssh/ssh_host_dsa_key\nPrintMotd no\nSubsystem sftp #{sftp_server_path}\nX11Forwarding yes\n"
        sshd_config_custom = "# File is managed by Puppet\n\nChallengeResponseAuthentication no\nHostKey /etc/ssh/ssh_host_rsa_key\nHostKey /etc/ssh/ssh_host_dsa_key\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp #{sftp_server_path}\nUsePAM no\nX11Forwarding no\n"
      else
        ssh_config_expected_default = "# File managed by Puppet\n\nHost *\n    HashKnownHosts yes\n    SendEnv LANG LC_*\n"
        ssh_config_expected_custom = "# File managed by Puppet\n\nHostFoo\n    HostName bar\nSomeOtherKey someValue\nHost *\n    HashKnownHosts yes\n    SendEnv LANG LC_*\n"
        sshd_config_default = "# File is managed by Puppet\n\nAcceptEnv LANG LC_*\nChallengeResponseAuthentication no\nPrintMotd no\nSubsystem sftp #{sftp_server_path}\nUsePAM yes\nX11Forwarding yes\n"
        sshd_config_custom = "# File is managed by Puppet\n\nAcceptEnv LANG LC_*\nChallengeResponseAuthentication no\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp #{sftp_server_path}\nUsePAM no\nX11Forwarding no\n"
      end

      if os_facts[:kernel] == 'Linux'
        context 'Server with a separate sftp_server_init instance on Port 8022' do
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
          it { is_expected.to contain_concat('/etc/ssh/sshd_config.sftp_server_init') }
          it { is_expected.to contain_concat__fragment('sshd instance sftp_server_init config').with_content("# File is managed by Puppet\nAddressFamily any\nPort 8022\n\nHostKey /etc/ssh/ssh_host_rsa_key\nLogLevel INFO\nPermitRootLogin no\nProtocol 2\nSyslogFacility AUTH\n") }
          it { is_expected.to contain_systemd__unit_file('sftp_server_init.service') }
          it { is_expected.to contain_service('sftp_server_init.service') }
          it { is_expected.to contain_ssh__server__instances('sftp_server_init') }
          it { is_expected.to contain_class('ssh::client') }
          it { is_expected.to contain_class('ssh::server') }
          it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil) }
          it { is_expected.to contain_resources('sshkey').with_purge(true) }
        end
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
        it { is_expected.to contain_concat('/etc/ssh/ssh_config') }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil) }
        it { is_expected.to contain_resources('sshkey').with_purge(true) }
        it { is_expected.to contain_concat__fragment('global config').with_content(sshd_config_default) }
        it { is_expected.to contain_concat__fragment('ssh_config global config').with_content(ssh_config_expected_default) }

        it { is_expected.to contain_package(client_package).with_ensure('installed') } if client_package
        it { is_expected.to contain_package(server_package).with_ensure('installed') } if server_package
      end

      context 'with custom server options' do
        let :params do
          {
            server_options: {
              X11Forwarding: 'no',
              UsePAM: 'no',
              SomeOtherKey: 'someValue'
            }
          }
        end

        it { is_expected.to contain_concat__fragment('global config').with_content(sshd_config_custom) }
      end

      context 'with custom client options' do
        let :params do
          {
            client_options: {
              HostFoo: {
                HostName: 'bar'
              },
              SomeOtherKey: 'someValue'
            }
          }
        end

        it { is_expected.to contain_concat__fragment('ssh_config global config').with_content(ssh_config_expected_custom) }
      end

      context 'with storeconfigs_enabled set to false' do
        let :params do
          {
            storeconfigs_enabled: false
          }
        end

        it { is_expected.not_to contain_class('ssh::knownhosts') }
      end

      context 'with client_match_block' do
        let :params do
          {
            client_match_block: {
              'foo' => {
                'type' => '!localuser',
                'options' => {
                  'ProxyCommand' => '/usr/bin/sss_ssh_knownhostsproxy -p %p %h',
                },
              },
              'bar' => {
                'type' => 'host',
                'options' => {
                  'ForwardX11' => 'no',
                  'PasswordAuthentication' => 'yes',
                },
              },
            },
          }
        end

        it do
          is_expected.not_to contain_ssh__client__matchblock('foo').with(
            type: '!localuser',
            options: {
              'ProxyCommand' => '/usr/bin/sss_ssh_knownhostsproxy -p %p %h',
            },
            target: '/etc/ssh/ssh_config_foo'
          )
        end

        it do
          is_expected.not_to contain_ssh__client__matchblock('bar').with(
            type: 'host',
            options: {
              'FowardX11' => 'no',
              'PasswordAuthentication' => 'yes',
            },
            target: '/etc/ssh/ssh_config_foo'
          )
        end

        it { is_expected.not_to have_ssh__client__matchblock_resource_count(2) }
      end
    end
  end
end
