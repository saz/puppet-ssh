# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh client config validation' do
  context 'with custom client_options' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            client_options       => {
              'ServerAliveInterval'   => '60',
              'ServerAliveCountMax'   => '3',
              'StrictHostKeyChecking' => 'ask',
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/ssh_config') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_mode '644' }
      its(:content) { is_expected.to match(%r{ServerAliveInterval 60}) }
      its(:content) { is_expected.to match(%r{ServerAliveCountMax 3}) }
      its(:content) { is_expected.to match(%r{StrictHostKeyChecking ask}) }
    end

    # Verify OpenSSH can parse the generated config
    describe command('ssh -G -F /etc/ssh/ssh_config example.org') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{serveraliveinterval 60}) }
      its(:stdout) { is_expected.to match(%r{serveralivecountmax 3}) }
    end
  end

  context 'with client_options and client_match_block combined' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            client_options       => {
              'ForwardAgent' => 'no',
            },
            client_match_block   => {
              'bastion.example.com' => {
                'type'    => 'host',
                'options' => {
                  'ForwardAgent'   => 'yes',
                  'ProxyJump'      => 'none',
                },
              },
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/ssh_config') do
      its(:content) { is_expected.to match(%r{ForwardAgent no}) }
      its(:content) { is_expected.to match(%r{Match host bastion\.example\.com}) }
      its(:content) { is_expected.to match(%r{ForwardAgent yes}) }
      its(:content) { is_expected.to match(%r{ProxyJump none}) }
    end

    # Verify the generated config is parseable for both regular and matched hosts
    %w[example.org bastion.example.com].each do |host|
      describe command("ssh -G -F /etc/ssh/ssh_config #{host}") do
        its(:exit_status) { is_expected.to eq 0 }
      end
    end
  end

  context 'with Host wildcard blocks in default options' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            client_options       => {
              'Host *.internal.example.com' => {
                'User'                   => 'deploy',
                'IdentityFile'           => '~/.ssh/deploy_key',
                'StrictHostKeyChecking'  => 'no',
              },
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/ssh_config') do
      its(:content) { is_expected.to match(%r{Host \*\.internal\.example\.com}) }
      its(:content) { is_expected.to match(%r{User deploy}) }
      its(:content) { is_expected.to match(%r{IdentityFile ~/.ssh/deploy_key}) }
    end

    describe command('ssh -G -F /etc/ssh/ssh_config example.org') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
