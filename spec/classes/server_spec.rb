# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server', type: 'class' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      case os_facts[:os]['name']
      when 'Debian'
        context 'with ssh_server_version_release set to 10.0', if: os_facts[:os]['release']['major'] == '12' do
          let(:facts) { os_facts.merge(ssh_server_version_release: '10.0') }

          sshd_config = "# File is managed by Puppet\n\nAcceptEnv LANG LC_*\nKbdInteractiveAuthentication no\nPrintMotd no\nSubsystem sftp /usr/lib/openssh/sftp-server\nUsePAM yes\nX11Forwarding yes\n"
          it { is_expected.to contain_concat__fragment('global config').with_content(sshd_config) }
        end
      end

      svc_name = case os_facts[:os]['family']
                 when 'Debian'
                   'ssh'
                 when 'Archlinux'
                   'sshd.service'
                 when 'Darwin'
                   'com.openssh.sshd'
                 when 'Solaris', 'SmartOS'
                   'svc:/network/ssh:default'
                 else
                   'sshd'
                 end

      sshd_config_custom = case os_facts[:os]['family']
                           when 'Solaris'
                             "# File is managed by Puppet\n\nChallengeResponseAuthentication no\nHostKey /etc/ssh/ssh_host_rsa_key\nHostKey /etc/ssh/ssh_host_dsa_key\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp /some/path\nUsePAM no\nX11Forwarding no\n"
                           when 'RedHat'
                             if os_facts[:os]['release']['major'] == '8'
                               "# File is managed by Puppet\n\nAcceptEnv LANG LC_*\nChallengeResponseAuthentication no\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp /some/path\nUsePAM no\nX11Forwarding no\n"
                             else
                               "# File is managed by Puppet\nInclude /etc/ssh/sshd_config.d/*.conf\n\nAcceptEnv LANG LC_*\nChallengeResponseAuthentication no\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp /some/path\nUsePAM no\nX11Forwarding no\n"
                             end
                           else
                             "# File is managed by Puppet\n\nAcceptEnv LANG LC_*\nChallengeResponseAuthentication no\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp /some/path\nUsePAM no\nX11Forwarding no\n"
                           end

      context 'with no other parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ssh::server::config') }
        it { is_expected.to contain_class('ssh::server::install') }
        it { is_expected.to contain_class('ssh::server::service') }
        it { is_expected.to contain_service(svc_name) }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil) }
        it { is_expected.to contain_concat__fragment('global config') }
      end

      context 'with custom options' do
        let :params do
          {
            options: {
              Subsystem: 'sftp /some/path',
              X11Forwarding: 'no',
              UsePAM: 'no',
              SomeOtherKey: 'someValue',
            },
          }
        end

        it { is_expected.to contain_concat__fragment('global config').with_content(sshd_config_custom) }
      end

      context 'with a custom service_name' do
        let :params do
          {
            service_name: 'custom_sshd_name',
          }
        end

        it { is_expected.to contain_service('custom_sshd_name') }
      end

      context 'with the validate_sshd_file setting' do
        let :params do
          {
            validate_sshd_file: true,
          }
        end

        sshd_binary = case os_facts[:os]['family']
                      when 'FreeBSD'
                        '/usr/local/sbin/sshd'
                      when 'Archlinux'
                        '/usr/bin/sshd'
                      else
                        '/usr/sbin/sshd'
                      end
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd("#{sshd_binary} -tf %") }
      end

      context 'with a different sshd_binary location' do
        let :params do
          {
            validate_sshd_file: true,
            sshd_binary: '/usr/another_bin/sshd',
          }
        end

        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd('/usr/another_bin/sshd -tf %') }
      end

      context 'with a different sshd_config location' do
        let :params do
          {
            sshd_config: '/etc/ssh/another_sshd_config',
          }
        end

        it { is_expected.to contain_concat('/etc/ssh/another_sshd_config') }
      end

      context 'with storeconfigs_enabled set to false' do
        let :params do
          {
            storeconfigs_enabled: false,
          }
        end

        it { is_expected.not_to contain_class('ssh::knownhosts') }
      end

      context 'with tags' do
        let(:params) do
          {
            tags: %w[group1 group2],
          }
        end

        %w[rsa].each do |key_type|
          it {
            expect(exported_resources).to contain_sshkey("foo.example.com_#{key_type}").with(
              ensure: 'present',
              type: %r{^ssh-#{key_type}},
              tag: %w[group1 group2],
            )
          }
        end
      end

      context 'with storeconfigs_group' do
        let(:params) do
          {
            storeconfigs_group: 'server_group',
          }
        end

        %w[rsa].each do |key_type|
          it {
            expect(exported_resources).to contain_sshkey("foo.example.com_#{key_type}").with(
              ensure: 'present',
              type: %r{^ssh-#{key_type}},
              tag: %w[hostkey_all hostkey_server_group],
            )
          }
        end
      end

      context 'with storeconfigs_group and tags' do
        let(:params) do
          {
            storeconfigs_group: 'server_group',
            tags: %w[group1 group2],
          }
        end

        %w[rsa].each do |key_type|
          it {
            expect(exported_resources).to contain_sshkey("foo.example.com_#{key_type}").with(
              ensure: 'present',
              type: %r{^ssh-#{key_type}},
              tag: %w[hostkey_all hostkey_server_group group1 group2],
            )
          }
        end
      end

      context 'when filtering a key type' do
        let(:params) do
          {
            exclude_key_types: ['ed25519'],
          }
        end

        it do
          expect(exported_resources).not_to contain_sshkey('foo.example.com_ed25519')
        end
      end

      context 'with use_augeas enabled' do
        let :pre_condition do
          <<~PP
            define sshd_config ($ensure = present, $key = undef, $value = undef, $target = undef, $condition = undef) {}
            define sshd_config_subsystem ($command = undef) {}
          PP
        end

        let :params do
          {
            use_augeas: true,
            options: {
              'X11Forwarding' => 'no',
              'PermitRootLogin' => 'no',
            },
            options_absent: ['GSSAPIAuthentication'],
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_concat('/etc/ssh/sshd_config') }

        it {
          is_expected.to contain_sshd_config('X11Forwarding').with(
            ensure: 'present',
            key: 'X11Forwarding',
            value: 'no',
            target: '/etc/ssh/sshd_config',
          )
        }

        it {
          is_expected.to contain_sshd_config('PermitRootLogin').with(
            ensure: 'present',
            key: 'PermitRootLogin',
            value: 'no',
          )
        }

        it {
          is_expected.to contain_sshd_config('GSSAPIAuthentication').with(
            ensure: 'absent',
            key: 'GSSAPIAuthentication',
          )
        }
      end

      context 'with use_augeas and match block options' do
        let :pre_condition do
          <<~PP
            define sshd_config ($ensure = present, $key = undef, $value = undef, $target = undef, $condition = undef) {}
            define sshd_config_subsystem ($command = undef) {}
          PP
        end

        let :params do
          {
            use_augeas: true,
            options: {
              'Match User www-data' => {
                'ChrootDirectory' => '%h',
                'ForceCommand' => 'internal-sftp',
              },
            },
            options_absent: [],
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_sshd_config('ChrootDirectory User www-data').with(
            ensure: 'present',
            condition: 'User www-data',
            key: 'ChrootDirectory',
            value: '%h',
          )
        }

        it {
          is_expected.to contain_sshd_config('ForceCommand User www-data').with(
            ensure: 'present',
            condition: 'User www-data',
            key: 'ForceCommand',
            value: 'internal-sftp',
          )
        }
      end

      context 'with use_issue_net enabled' do
        let :params do
          {
            use_issue_net: true,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/issue.net').with(
            ensure: 'file',
            owner: 0,
            group: 0,
          )
        }

        it { is_expected.to contain_file('/etc/issue.net').that_notifies("Service[#{svc_name}]") }

        it {
          is_expected.to contain_concat__fragment('banner file').with(
            target: '/etc/ssh/sshd_config',
            content: "Banner /etc/issue.net\n",
            order: '01',
          )
        }
      end

      context 'with include_dir set' do
        let :params do
          {
            include_dir: '/etc/ssh/sshd_config.d',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config.d').with(
            ensure: 'directory',
            owner: 0,
            group: 0,
            mode: '0700',
            purge: true,
            recurse: true,
          )
        }
      end

      context 'with include_dir and include_dir_purge false' do
        let :params do
          {
            include_dir: '/etc/ssh/sshd_config.d',
            include_dir_purge: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config.d').with(
            ensure: 'directory',
            purge: false,
            recurse: false,
          )
        }
      end

      context 'with include_dir and custom mode' do
        let :params do
          {
            include_dir: '/etc/ssh/sshd_config.d',
            include_dir_mode: '0755',
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/sshd_config.d').with(
            mode: '0755',
          )
        }
      end

      context 'with config_files' do
        let :params do
          {
            include_dir: '/etc/ssh/sshd_config.d',
            config_files: {
              'hardening' => {
                'options' => {
                  'PermitRootLogin' => 'no',
                },
              },
              'logging' => {
                'options' => {
                  'LogLevel' => 'VERBOSE',
                },
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_ssh__server__config_file('hardening') }
        it { is_expected.to contain_ssh__server__config_file('logging') }

        it {
          is_expected.to contain_concat('/etc/ssh/sshd_config.d/hardening.conf').with(
            ensure: 'present',
            owner: 0,
            group: 0,
          )
        }

        it {
          is_expected.to contain_concat('/etc/ssh/sshd_config.d/logging.conf').with(
            ensure: 'present',
            owner: 0,
            group: 0,
          )
        }
      end

      # Skip OSes where hiera sets include_dir by default (e.g. RedHat 9)
      context 'without include_dir but with config_files', unless: os_facts.dig(:os, 'family') == 'RedHat' && os_facts.dig(:os, 'release', 'major') == '9' do
        let :params do
          {
            config_files: {
              'hardening' => {
                'options' => {},
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_ssh__server__config_file('hardening') }
      end
    end
  end
end
