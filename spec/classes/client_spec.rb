# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::client', type: 'class' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no other parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ssh::knownhosts') }
        it { is_expected.to contain_class('ssh::client::config') }
        it { is_expected.to contain_class('ssh::client::install') }
        it { is_expected.to contain_concat('/etc/ssh/ssh_config') }
      end

      context 'with a different ssh_config location' do
        let :params do
          {
            ssh_config: '/etc/ssh/another_ssh_config'
          }
        end

        it { is_expected.to contain_concat('/etc/ssh/another_ssh_config') }
      end

      context 'with storeconfigs_enabled set to false' do
        let :params do
          {
            storeconfigs_enabled: false
          }
        end

        it { is_expected.not_to contain_class('ssh::knownhosts') }
      end
    end
  end
end
