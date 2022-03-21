require 'spec_helper'
describe 'ssh::server' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      let :default_params do
        {
          ensure: 'present',
          storeconfigs_enabled: true
        }
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
      end
      describe 'providing options' do
        let :params do
          {
            options: {
              'TestString' => '/usr/bin',
              'TestBoolean' => true
            }
          }
        end

        context 'Debian sshd_config', if: %w[Debian].include?(os_facts[:os]['Family']) do
          it do
            is_expected.to contain_concat__fragment('global config').with(
              target: '/etc/ssh/sshd_config',
              content: '# File is managed by Puppet

    AcceptEnv LANG LC_*
    ChallengeResponseAuthentication no
    PrintMotd no
    Subsystem sftp /usr/libexec/openssh/sftp-server
    TestBoolean yes
    TestString /usr/bin
    UsePAM yes
    X11Forwarding yes
    '
              # rubocop:enable EmptyLinesAroundArguments
            )
          end
        end
      end
      [{},
       {
         ensure: 'latest',
         storeconfigs_enabled: true
       },
       {
         ensure: 'present',
         storeconfigs_enabled: false
       }].each do |param_set|
        describe "when #{param_set == {} ? 'using default' : 'specifying'} class parameters" do
          let :param_hash do
            default_params.merge(param_set)
          end

          let :params do
            param_set
          end

          ['Debian'].each do |osfamily|
            describe "on supported osfamily: #{osfamily}", if: %w[Debian].include?(os_facts[:os]['Family']) do
              it { is_expected.to contain_class('ssh::params') }
              it do
                if param_hash[:ensure] == 'present'
                  is_expected.to contain_package('openssh-server').with_ensure('installed')
                else
                  is_expected.to contain_package('openssh-server').with_ensure(param_hash[:ensure])
                end
              end

              it do
                is_expected.to contain_service('ssh').with(
                  'ensure'     => 'running',
                  'enable'     => true,
                  'hasrestart' => true,
                  'hasstatus'  => true
                )
              end

              it { is_expected.to contain_concat('/etc/ssh/sshd_config') }
              it do
                is_expected.to contain_concat__fragment('global config').with(
                  target: '/etc/ssh/sshd_config',
                  content: '# File is managed by Puppet

AcceptEnv LANG LC_*
ChallengeResponseAuthentication no
PrintMotd no
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
X11Forwarding yes
'
                )
              end
            end
            describe 'on Arch', if: %w[Archlinux].include?(os_facts[:os]['Family']) do
              it { is_expected.to contain_class('ssh::params') }
              it do
                if param_hash[:ensure] == 'present'
                  is_expected.to contain_package('openssh').with_ensure('installed').with(name: 'openssh')
                else
                  is_expected.to contain_package('openssh').with_ensure(param_hash[:ensure]).with(name: 'openssh')
                end
              end

              it do
                is_expected.to contain_service('sshd.service').with(
                  'ensure'     => 'running',
                  'enable'     => true,
                  'hasrestart' => true,
                  'hasstatus'  => true
                )
              end

              it { is_expected.to contain_concat('/etc/ssh/sshd_config') }
              it do
                is_expected.to contain_concat__fragment('global config').with(
                  target: '/etc/ssh/sshd_config',
                  content: '# File is managed by Puppet

AcceptEnv LANG LC_*
ChallengeResponseAuthentication no
PrintMotd no
Subsystem sftp /usr/lib/ssh/sftp-server
UsePAM yes
X11Forwarding yes
'
                )
              end
            end
          end
        end
      end
    end
  end
end
