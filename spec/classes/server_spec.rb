require 'spec_helper'
describe 'ssh::server' do
    let :default_params do
        {
            :ensure               => 'present',
            :storeconfigs_enabled => true,
        }
    end

    describe "providing options" do
      let :params do
        {
          :options => {
            'TestString' => '/usr/bin',
            'TestBoolean' => true
          }
        }
      end

      let :facts do
        {
          :osfamily => 'RedHat',
          :concat_basedir => '/tmp'
        }
      end

      it do 
        should contain_concat__fragment('global config').with(
              :target  => '/etc/ssh/sshd_config',
              :content => '# File is managed by Puppet

AcceptEnv LANG LC_*
ChallengeResponseAuthentication no
PrintMotd no
Subsystem sftp /usr/libexec/openssh/sftp-server
TestBoolean yes
TestString /usr/bin
UsePAM yes
X11Forwarding yes
'
        )
      end
    end

    [ {},
      {
        :ensure               => 'latest',
        :storeconfigs_enabled => true,
      },
      {
        :ensure               => 'present',
        :storeconfigs_enabled => false,
      }
    ].each do |param_set|
      describe "when #{param_set == {} ? "using default" : "specifying"} class parameters" do
        let :param_hash do
          default_params.merge(param_set)
        end

        let :params do
          param_set
        end

        ['Debian'].each do |osfamily|
          let :facts do
            {
              :osfamily       => osfamily,
              :interfaces     => 'eth0',
              :ipaddress_eth0 => '192.168.1.1',
              :concat_basedir => '/tmp'
            }
          end

          describe "on supported osfamily: #{osfamily}" do
            it { should contain_class('ssh::params') }
            it { should contain_package('openssh-server').with_ensure(param_hash[:ensure]) }

            it { should contain_file('/etc/ssh/sshd_config').with(
              'owner' => 0,
              'group' => 0
            )}

            it { should contain_service('ssh').with(
              'ensure'     => 'running',
              'enable'     => true,
              'hasrestart' => true,
              'hasstatus'  => true
            )}

            it { should contain_class('concat::setup') }
            it { should contain_concat('/etc/ssh/sshd_config') }
            it { should contain_concat__fragment('global config').with(
              :target  => '/etc/ssh/sshd_config',
              :content => '# File is managed by Puppet

AcceptEnv LANG LC_*
ChallengeResponseAuthentication no
PrintMotd no
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
X11Forwarding yes
'
            )}

          end
          describe "on Arch" do
            let :facts do
            {
                :osfamily           => 'Archlinux',
                :lsbdistdescription => 'Arch Linux',
                :lsbdistid          => 'Arch',
                :operatingsystem    => 'Archlinux',
                :interfaces         => 'enp4s0',
                :ipaddress_eth0     => '192.168.1.1',
                :concat_basedir     => '/tmp'
            }
            end

            it { should contain_class('ssh::params') }
            it { should contain_package('openssh').with(
                :ensure => param_hash[:ensure],
                :name   => 'openssh'
            )}

            it { should contain_file('/etc/ssh/sshd_config').with(
              'owner' => 0,
              'group' => 0
            )}

            it { should contain_service('sshd.service').with(
              'ensure'     => 'running',
              'enable'     => true,
              'hasrestart' => true,
              'hasstatus'  => true
            )}

            it { should contain_class('concat::setup') }
            it { should contain_concat('/etc/ssh/sshd_config') }
            it { should contain_concat__fragment('global config').with(
              :target  => '/etc/ssh/sshd_config',
              :content => '# File is managed by Puppet

AcceptEnv LANG LC_*
ChallengeResponseAuthentication no
PrintMotd no
Subsystem sftp /usr/lib/ssh/sftp-server
UsePAM yes
X11Forwarding yes
'
            )}

          end
        end
      end
    end
end
