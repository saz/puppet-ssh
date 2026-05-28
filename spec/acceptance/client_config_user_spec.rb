# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh::client::config::user' do
  context 'with per-user ssh config' do
    before(:context) do
      on(default, 'useradd -m testuser || true')
    end

    after(:context) do
      on(default, 'userdel -r testuser || true')
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled  => false,
            users_client_options  => {
              'testuser' => {
                'options' => {
                  'Host *.example.com' => {
                    'User'         => 'deploy',
                    'IdentityFile' => '~/.ssh/deploy_key',
                  },
                  'ServerAliveInterval' => '60',
                },
              },
            },
          }
        PP
      end
    end

    describe file('/home/testuser/.ssh') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'testuser' }
      it { is_expected.to be_mode '700' }
    end

    describe file('/home/testuser/.ssh/config') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'testuser' }
      it { is_expected.to be_mode '600' }
      its(:content) { is_expected.to match(%r{Host \*\.example\.com}) }
      its(:content) { is_expected.to match(%r{User deploy}) }
      its(:content) { is_expected.to match(%r{IdentityFile ~/.ssh/deploy_key}) }
      its(:content) { is_expected.to match(%r{ServerAliveInterval\s+60}) }
    end

    # Verify OpenSSH can parse the per-user config
    describe command('ssh -G -F /home/testuser/.ssh/config example.org') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'with manage_user_ssh_dir set to false' do
    before(:context) do
      on(default, 'useradd -m testuser2 || true')
      on(default, 'mkdir -p /home/testuser2/.ssh && chown testuser2 /home/testuser2/.ssh')
    end

    after(:context) do
      on(default, 'userdel -r testuser2 || true')
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled  => false,
            users_client_options  => {
              'testuser2' => {
                'manage_user_ssh_dir' => false,
                'options'             => {
                  'ServerAliveInterval' => '30',
                },
              },
            },
          }
        PP
      end
    end

    describe file('/home/testuser2/.ssh/config') do
      it { is_expected.to be_file }
      its(:content) { is_expected.to match(%r{ServerAliveInterval\s+30}) }
    end
  end
end
