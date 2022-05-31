# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::client::match_block' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let :pre_condition do
        'include ssh'
      end

      context 'with !foo' do
        let(:title) { '!foo' }
        let(:params) do
          {
            'type' => 'user',
            'options' => {
              'ProxyCommand' => '/usr/bin/sss_ssh_knownhostsproxy -p %p %h',
            },
            'target' => '/etc/ssh/ssh_config_foo',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_concat__fragment('match_block !foo').with(
            target: '/etc/ssh/ssh_config_foo',
            content: <<~SSH,
              Match user !foo
                  ProxyCommand /usr/bin/sss_ssh_knownhostsproxy -p %p %h
            SSH
            order: 250
          )
        end
      end
    end
  end
end
