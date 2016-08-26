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
        interfaces: 'eth0',
        ipaddress_eth0: '192.168.1.1',
        ipaddress6_eth0: '::1',
        concat_basedir: '/tmp',
        puppetversion: '3.7.0',
        sshdsakey: 'AAAAB3NzaC1kc3MAAACBAODCvvUUnv2imW4cfuLBWVJTLMzds89MtCUXGl3+7Gza5QYJmp7GSkKBnV8+7XI+JAmjv0RKQM1RAn7mV5UplRTtg3CYbeNkX4IakZmNJLTdL4vUyIehhaxBobpOtBaJfFewCJE1plIaWvoWfEDrShcjIUbUbJMfR8YWweIIqp9bAAAAFQCr8+KRfOUZbS9Dz1t15A/Owl61VQAAAIBr/7hNPCvjzAl5+rde6jUR5k20pxAE+z2wsaZxlhrs6ZhhplyCKIXKq4rCx4QuFVPh/c+WJRPO56iH/rSh5Y5cpT1LUk66wNJcOBPprjvDEHfQUHUmfYXzNJ2BHkRL78lfzQr52YyowV6dHfktv0VsIctm13KcMr2KQygZtV6EqgAAAIEAjNC4PRdzYpWfxu268CJDpexlhBwIkIx+ovEibtYeke55qAQcF9UWko4A1c8Wf4nLLxlQYCf501Bt5lb6GmZd0xfpg27fPIfzZPL8o+E756D3ZcNXUaLj4HPRKnwNcdAtChL2jESH3fm8PyNwBI7tV6IOjmOGpyQKtmJq3IyNgms=',
        sshrsakey: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDzA57hAMwz6pywCgxNUcloWeNMvBo2PDPxK2RCegst+9tYaf4S3shnM9a1j2PGBoeRXTuUG6mYB32fJm6/37UUUJA4lT+8CZ3hNnDZU9aitpukkKon7RIlvY1PWO8wT4A5mEa0hfdQg6Um8KZZUs+jrB+8zMJO/X0fmleY54r/JKrP3hNcpaJpTUVQEvMmKacW7nYez/PvWKAz8d02uAOXuauGKhZ9K2AHYKlQFqJ4S1jLiduoGFWxFQ2vQybbN/O0PQQU7EZlHIjSzwoowZLzlxCKCZcKnoDsbGCtYHArbjxTb+m5e7nvsamz7TXLoY90Srmc5QGMxrLUlSvkYsm5',
        sshecdsakey: 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFDrof0LPA0hGuwODy+5uTynV7rgPJspvZo2TzykBu5mSANJvdL1z5/JS3x16/c/cDjx2lfEkRoVDnon4/NjKEM=',
        sshed25519key: '',
        id: 'root',
        is_pe: false,
        path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
      }
    end

    it do
      should contain_concat__fragment('global config').with(
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
            osfamily: osfamily,
            interfaces: 'eth0',
            ipaddress_eth0: '192.168.1.1',
            ipaddress6_eth0: '::1',
            concat_basedir: '/tmp',
            puppetversion: '3.7.0',
            sshdsakey: 'AAAAB3NzaC1kc3MAAACBAODCvvUUnv2imW4cfuLBWVJTLMzds89MtCUXGl3+7Gza5QYJmp7GSkKBnV8+7XI+JAmjv0RKQM1RAn7mV5UplRTtg3CYbeNkX4IakZmNJLTdL4vUyIehhaxBobpOtBaJfFewCJE1plIaWvoWfEDrShcjIUbUbJMfR8YWweIIqp9bAAAAFQCr8+KRfOUZbS9Dz1t15A/Owl61VQAAAIBr/7hNPCvjzAl5+rde6jUR5k20pxAE+z2wsaZxlhrs6ZhhplyCKIXKq4rCx4QuFVPh/c+WJRPO56iH/rSh5Y5cpT1LUk66wNJcOBPprjvDEHfQUHUmfYXzNJ2BHkRL78lfzQr52YyowV6dHfktv0VsIctm13KcMr2KQygZtV6EqgAAAIEAjNC4PRdzYpWfxu268CJDpexlhBwIkIx+ovEibtYeke55qAQcF9UWko4A1c8Wf4nLLxlQYCf501Bt5lb6GmZd0xfpg27fPIfzZPL8o+E756D3ZcNXUaLj4HPRKnwNcdAtChL2jESH3fm8PyNwBI7tV6IOjmOGpyQKtmJq3IyNgms=',
            sshrsakey: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDzA57hAMwz6pywCgxNUcloWeNMvBo2PDPxK2RCegst+9tYaf4S3shnM9a1j2PGBoeRXTuUG6mYB32fJm6/37UUUJA4lT+8CZ3hNnDZU9aitpukkKon7RIlvY1PWO8wT4A5mEa0hfdQg6Um8KZZUs+jrB+8zMJO/X0fmleY54r/JKrP3hNcpaJpTUVQEvMmKacW7nYez/PvWKAz8d02uAOXuauGKhZ9K2AHYKlQFqJ4S1jLiduoGFWxFQ2vQybbN/O0PQQU7EZlHIjSzwoowZLzlxCKCZcKnoDsbGCtYHArbjxTb+m5e7nvsamz7TXLoY90Srmc5QGMxrLUlSvkYsm5',
            sshecdsakey: 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFDrof0LPA0hGuwODy+5uTynV7rgPJspvZo2TzykBu5mSANJvdL1z5/JS3x16/c/cDjx2lfEkRoVDnon4/NjKEM=',
            sshed25519key: '',
            id: 'root',
            is_pe: false,
            path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
          }
        end

        describe "on supported osfamily: #{osfamily}" do
          it { should contain_class('ssh::params') }
          it { should contain_package('openssh-server').with_ensure(param_hash[:ensure]) }

          it do
            should contain_file('/etc/ssh/sshd_config').with(
              'owner' => 0,
              'group' => 0
          )
          end

          it do
            should contain_service('ssh').with(
              'ensure'     => 'running',
              'enable'     => true,
              'hasrestart' => true,
              'hasstatus'  => true
          )
          end

          it { should contain_class('concat::setup') }
          it { should contain_concat('/etc/ssh/sshd_config') }
          it do
            should contain_concat__fragment('global config').with(
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
              lsbdistid: 'Arch',
              interfaces: 'enp4s0',
              ipaddress_enp4s0: '192.168.1.1',
              ipaddress6_enp4s0: '::1',
              concat_basedir: '/tmp',
              puppetversion: '3.7.0',
              sshdsakey: 'AAAAB3NzaC1kc3MAAACBAODCvvUUnv2imW4cfuLBWVJTLMzds89MtCUXGl3+7Gza5QYJmp7GSkKBnV8+7XI+JAmjv0RKQM1RAn7mV5UplRTtg3CYbeNkX4IakZmNJLTdL4vUyIehhaxBobpOtBaJfFewCJE1plIaWvoWfEDrShcjIUbUbJMfR8YWweIIqp9bAAAAFQCr8+KRfOUZbS9Dz1t15A/Owl61VQAAAIBr/7hNPCvjzAl5+rde6jUR5k20pxAE+z2wsaZxlhrs6ZhhplyCKIXKq4rCx4QuFVPh/c+WJRPO56iH/rSh5Y5cpT1LUk66wNJcOBPprjvDEHfQUHUmfYXzNJ2BHkRL78lfzQr52YyowV6dHfktv0VsIctm13KcMr2KQygZtV6EqgAAAIEAjNC4PRdzYpWfxu268CJDpexlhBwIkIx+ovEibtYeke55qAQcF9UWko4A1c8Wf4nLLxlQYCf501Bt5lb6GmZd0xfpg27fPIfzZPL8o+E756D3ZcNXUaLj4HPRKnwNcdAtChL2jESH3fm8PyNwBI7tV6IOjmOGpyQKtmJq3IyNgms=',
              sshrsakey: 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDzA57hAMwz6pywCgxNUcloWeNMvBo2PDPxK2RCegst+9tYaf4S3shnM9a1j2PGBoeRXTuUG6mYB32fJm6/37UUUJA4lT+8CZ3hNnDZU9aitpukkKon7RIlvY1PWO8wT4A5mEa0hfdQg6Um8KZZUs+jrB+8zMJO/X0fmleY54r/JKrP3hNcpaJpTUVQEvMmKacW7nYez/PvWKAz8d02uAOXuauGKhZ9K2AHYKlQFqJ4S1jLiduoGFWxFQ2vQybbN/O0PQQU7EZlHIjSzwoowZLzlxCKCZcKnoDsbGCtYHArbjxTb+m5e7nvsamz7TXLoY90Srmc5QGMxrLUlSvkYsm5',
              sshecdsakey: 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFDrof0LPA0hGuwODy+5uTynV7rgPJspvZo2TzykBu5mSANJvdL1z5/JS3x16/c/cDjx2lfEkRoVDnon4/NjKEM=',
              sshed25519key: '',
              id: 'root',
              is_pe: false,
              path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games'
            }
          end

          it { should contain_class('ssh::params') }
          it do
            should contain_package('openssh').with(
              ensure: param_hash[:ensure],
              name: 'openssh'
          )
          end

          it do
            should contain_file('/etc/ssh/sshd_config').with(
              'owner' => 0,
              'group' => 0
          )
          end

          it do
            should contain_service('sshd.service').with(
              'ensure'     => 'running',
              'enable'     => true,
              'hasrestart' => true,
              'hasstatus'  => true
          )
          end

          it { should contain_class('concat::setup') }
          it { should contain_concat('/etc/ssh/sshd_config') }
          it do
            should contain_concat__fragment('global config').with(
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
