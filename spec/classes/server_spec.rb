require 'spec_helper'
describe 'ssh::server' do
    let :default_params do
        {
            :ensure => 'present',
            :storeconfigs_enabled => true,
            :options => {}
        }
    end

    [ {},
      {
        :ensure => 'latest',
        :storeconfigs_enabled => true,
        :options => {}
      },
      {
        :ensure => 'present',
        :storeconfigs_enabled => false,
        :options => {}
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
              :osfamily => osfamily,
              :interfaces => 'eth0',
              :ipaddress_eth0 => '192.168.1.1'
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
              'ensure' => 'running',
              'enable' => true,
              'hasrestart' => true,
              'hasstatus' => true
            )}

            it 'should compile the template based on the class parameters' do
              content = param_value(
                subject,
                'file',
                '/etc/ssh/sshd_config',
                'content'
              )
              expected_lines = [
                'ChallengeResponseAuthentication no',
                'X11Forwarding yes',
                'PrintMotd no',
                'AcceptEnv LANG LC_*',
                'Subsystem sftp /usr/lib/openssh/sftp-server',
                'UsePAM yes'
              ]
              (content.split("\n") & expected_lines).should =~ expected_lines
            end
          end
        end
      end
    end
end
