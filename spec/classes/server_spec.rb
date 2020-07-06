require 'spec_helper'
describe 'ssh::server' do
  let :default_params do
    {
      ensure: 'present',
      storeconfigs_enabled: true
    }
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

    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '6'
      }
    end

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
        let :facts do
          {
            osfamily: osfamily
          }
        end

        describe "on supported osfamily: #{osfamily}" do
          it { is_expected.to contain_class('ssh::params') }
          it { is_expected.to contain_package('openssh-server').with_ensure(param_hash[:ensure]) }

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
        describe 'on Arch' do
          let :facts do
            {
              osfamily: 'Archlinux',
              lsbdistdescription: 'Arch Linux',
              lsbdistid: 'Arch'
            }
          end

          it { is_expected.to contain_class('ssh::params') }
          it do
            is_expected.to contain_package('openssh').with(
              ensure: param_hash[:ensure],
              name: 'openssh'
            )
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
