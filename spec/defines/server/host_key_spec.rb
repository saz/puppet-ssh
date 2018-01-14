require 'spec_helper'

describe 'ssh::server::host_key', type: :define do
  let :title do
    'something'
  end

  let(:pre_condition) { 'class {"::ssh::params": }' }

  let :facts do
    {
      osfamily: 'RedHat',
      operatingsystemmajrelease: '6',
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

  describe 'with public_key_content, private_key_content and certificate_content' do
    let :params do
      {
        public_key_content: 'abc',
        private_key_content: 'bcd',
        certificate_content: 'cde'
      }
    end

    it do
      is_expected.to contain_file('something_pub').
        with_content('abc').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0644').
        with_path('/etc/ssh/something.pub')
      is_expected.to contain_file('something_priv').
        with_content('bcd').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0600').
        with_path('/etc/ssh/something')
      is_expected.to contain_file('something_cert').
        with_content('cde').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0644').
        with_path('/etc/ssh/something-cert.pub')
    end
  end

  describe 'with public_key_content and private_key_content' do
    let :params do
      {
        public_key_content: 'abc',
        private_key_content: 'bcd'
      }
    end

    it do
      is_expected.to contain_file('something_pub').
        with_content('abc').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0644').
        with_path('/etc/ssh/something.pub')
      is_expected.to contain_file('something_priv').
        with_content('bcd').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0600').
        with_path('/etc/ssh/something')
      is_expected.not_to contain_file('something_cert')
    end
  end

  describe 'with *_key_content and *_key_source, *_key_source takes precedence' do
    let :params do
      {
        public_key_content: 'abc',
        public_key_source: 'a',
        private_key_content: 'bcd',
        private_key_source: 'b'
      }
    end

    it do
      is_expected.to contain_file('something_pub').
        without_content.
        with_source('a').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0644').
        with_path('/etc/ssh/something.pub')
      is_expected.to contain_file('something_priv').
        without_content.
        with_source('b').
        with_ensure('present').
        with_owner('root').
        with_group('root').
        with_mode('0600').
        with_path('/etc/ssh/something')
      is_expected.not_to contain_file('something_cert')
    end
  end

  describe 'with private_key_content and no public_key_content' do
    let :params do
      {
        private_key_content: 'bcd'
      }
    end

    it 'fails' do
      expect do
        is_expected.to compile
      end.to raise_error(%r{You must provide either public_key_source or public_key_content parameter})
    end
  end

  describe 'with public_key_content and no private_key_content' do
    let :params do
      {
        public_key_content: 'abc'
      }
    end

    it 'fails' do
      expect do
        is_expected.to compile
      end.to raise_error(%r{You must provide either private_key_source or private_key_content parameter})
    end
  end

  describe 'with private_key_source and no public_key_source' do
    let :params do
      {
        private_key_source: 'bcd'
      }
    end

    it 'fails' do
      expect do
        is_expected.to compile
      end.to raise_error(%r{You must provide either public_key_source or public_key_content parameter})
    end
  end

  describe 'with public_key_source and no private_key_source' do
    let :params do
      {
        public_key_source: 'abc'
      }
    end

    it 'fails' do
      expect do
        is_expected.to compile
      end.to raise_error(%r{You must provide either private_key_source or private_key_content parameter})
    end
  end
end

# vim: tabstop=2 shiftwidth=2 softtabstop=2
