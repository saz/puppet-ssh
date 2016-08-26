require 'spec_helper'

describe 'ssh::server::config::setting', type: :define do
  let :title do
    'something'
  end

  let :facts do
    {
      osfamily: 'RedHat',
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

  describe 'with key => "AllowGroups", value => "group1 group2"' do
    let :params do
      {
        key: 'AllowGroups',
        value: 'group1 group2'
      }
    end

    it do
      should contain_concat__fragment('ssh_setting_something_AllowGroups').with_content(%r{\nAllowGroups group1 group2\n})
    end
  end

  describe 'with key => "Somesetting", value => true' do
    let :params do
      {
        key: 'Somesetting',
        value: true
      }
    end

    it do
      should contain_concat__fragment('ssh_setting_something_Somesetting').with_content(%r{\nSomesetting yes\n})
    end
  end

  describe 'with key => "Foo", value => [1, 2]' do
    let :params do
      {
        key: 'Foo',
        value: [1, 2]
      }
    end

    it do
      should contain_concat__fragment('ssh_setting_something_Foo').with_content(%r{\nFoo 1 2\n})
    end
  end

  describe 'with key => "Bar", value => {"a" => "b"}' do
    let :params do
      {
        key: 'Bar',
        value: {
          'a' => 'b'
        }
      }
    end

    it 'fails' do
      expect do
        should compile
      end.to raise_error(%r{Hash values are not supported})
    end
  end
end

# vim: tabstop=2 shiftwidth=2 softtabstop=2
