# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server host key management' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'manage a custom RSA host key' do
    # Generate a fresh RSA keypair in a pre-test step
    before(:context) do
      on(default, 'ssh-keygen -t rsa -b 2048 -f /tmp/test_host_rsa_key -N "" -q')
    end

    after(:context) do
      on(default, 'rm -f /tmp/test_host_rsa_key /tmp/test_host_rsa_key.pub')
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
          }

          ssh::server::host_key { 'ssh_host_rsa_custom_key':
            public_key_source  => '/tmp/test_host_rsa_key.pub',
            private_key_source => '/tmp/test_host_rsa_key',
          }
        PP
      end
    end

    describe file('/etc/ssh/ssh_host_rsa_custom_key.pub') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '644' }
    end

    describe file('/etc/ssh/ssh_host_rsa_custom_key') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '600' }
    end

    describe command('ssh-keygen -l -f /etc/ssh/ssh_host_rsa_custom_key.pub') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{2048}) }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end

  context 'manage a host key with inline content' do
    # Generate a fresh Ed25519 keypair in a pre-test step
    before(:context) do
      on(default, 'ssh-keygen -t ed25519 -f /tmp/test_host_ed25519_key -N "" -q')
      @priv_key = on(default, 'cat /tmp/test_host_ed25519_key').stdout
      @pub_key = on(default, 'cat /tmp/test_host_ed25519_key.pub').stdout
    end

    after(:context) do
      on(default, 'rm -f /tmp/test_host_ed25519_key /tmp/test_host_ed25519_key.pub')
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
          }

          ssh::server::host_key { 'ssh_host_ed25519_custom_key':
            public_key_content  => file('/tmp/test_host_ed25519_key.pub'),
            private_key_content => file('/tmp/test_host_ed25519_key'),
          }
        PP
      end
    end

    describe file('/etc/ssh/ssh_host_ed25519_custom_key.pub') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '644' }
    end

    describe file('/etc/ssh/ssh_host_ed25519_custom_key') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '600' }
    end

    describe command('ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_custom_key.pub') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{ED25519}) }
    end
  end

  context 'remove a host key with ensure absent' do
    before(:context) do
      on(default, 'ssh-keygen -t ed25519 -f /tmp/test_host_absent_key -N "" -q')
      # Pre-place the key files so there is something to remove
      on(default, 'cp /tmp/test_host_absent_key /etc/ssh/ssh_host_absent_key')
      on(default, 'cp /tmp/test_host_absent_key.pub /etc/ssh/ssh_host_absent_key.pub')
    end

    after(:context) do
      on(default, 'rm -f /tmp/test_host_absent_key /tmp/test_host_absent_key.pub')
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
          }

          ssh::server::host_key { 'ssh_host_absent_key':
            ensure => 'absent',
          }
        PP
      end
    end

    %w[/etc/ssh/ssh_host_absent_key /etc/ssh/ssh_host_absent_key.pub].each do |key_file|
      describe file(key_file) do
        it { is_expected.not_to exist }
      end
    end
  end
end
