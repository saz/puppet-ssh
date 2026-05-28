# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh::server::config::setting' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'with a string value' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          include ssh

          ssh::server::config::setting { 'allow_groups':
            key   => 'AllowGroups',
            value => 'root sshusers',
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{AllowGroups root sshusers}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end

  context 'with a boolean value' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          include ssh

          ssh::server::config::setting { 'permit_empty_passwords':
            key   => 'PermitEmptyPasswords',
            value => false,
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{PermitEmptyPasswords no}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
