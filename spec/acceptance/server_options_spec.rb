# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh::server::options' do
  context 'with additional options appended to sshd_config' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
          }

          ssh::server::options { 'extra_hardening':
            options => {
              'ClientAliveInterval' => '300',
              'ClientAliveCountMax' => '2',
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{ClientAliveInterval 300}) }
      its(:content) { is_expected.to match(%r{ClientAliveCountMax 2}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end

  context 'with boolean options' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
          }

          ssh::server::options { 'boolean_opts':
            options => {
              'PrintLastLog'           => true,
              'PermitEmptyPasswords'   => false,
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{PrintLastLog yes}) }
      its(:content) { is_expected.to match(%r{PermitEmptyPasswords no}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
