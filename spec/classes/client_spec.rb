require 'spec_helper'

describe 'ssh::client', type: 'class' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
      end
      context 'when on Debian with no other parameters', if: %w[Debian].include?(os_facts[:os]['Family']) do
        it { is_expected.to contain_package('openssh-client').with_ensure('installed') }
      end
      context 'when on Debian with no other parameters', if: %w[RedHat].include?(os_facts[:os]['Family']) do
        it { is_expected.to contain_package('openssh-clients').with_ensure('installed') }
      end
      context 'when on Debian with custom ensure', if: %w[Debian].include?(os_facts[:os]['Family']) do
        let :params do
          {
            ensure: 'latest'
          }
        end

        it { is_expected.to contain_package('openssh-client').with_ensure('latest') }
      end
    end
  end
end
