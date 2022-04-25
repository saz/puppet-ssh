# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh' do
  context 'with client_match_block' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
        class { 'ssh':
          client_options => {
            'GlobalKnownHostsFile'      => "/var/lib/sss/pubconf/known_hosts",
            'PubkeyAuthentication'      => "yes",
            'GSSAPIAuthentication'      => "yes",
            'GSSAPIDelegateCredentials' => "yes",
          },
          client_match_block => {
            '!foo' => {
              'type'    => 'user',
              'options' => {
                'ProxyCommand' => '/usr/bin/sss_ssh_knownhostsproxy -p %p %h',
              },
            },
          },
        }
        PP
      end

      describe file('/etc/ssh/ssh_config') do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'root' }
        it { is_expected.to be_grouped_into 'root' }
        it { is_expected.to be_mode '644' } # serverspec does not like a leading 0
        its(:content) do
          is_expected.to match <<~SSH
            # File managed by Puppet

            GlobalKnownHostsFile /var/lib/sss/pubconf/known_hosts
            PubkeyAuthentication yes
            GSSAPIAuthentication yes
            GSSAPIDelegateCredentials yes
            Match user !foo
                ProxyCommand /usr/bin/sss_ssh_knownhostsproxy -p %p %h
            SSH
        end
      end
    end
  end
end
