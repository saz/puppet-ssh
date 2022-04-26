# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server::match_block' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let :pre_condition do
        'include ssh'
      end

      context 'with *,!ssh_exempt_ldap_authkey,!sshlokey present' do
        let(:title) { '*,!ssh_exempt_ldap_authkey,!sshlokey' }
        let(:params) do
          {
            'type' => 'group',
            'options' => {
              'AuthorizedKeysCommand' => '/usr/local/bin/getauthkey',
              'AuthorizedKeysCommandUser' => 'nobody',
              'AuthorizedKeysFile' => '/dev/null',
            },
            'target' => '/etc/ssh/sshd_config_sftp_server',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('match_block *,!ssh_exempt_ldap_authkey,!sshlokey') }
      end

      context 'with ssh_deny_pw_auth,sshdnypw' do
        let(:title) { 'ssh_deny_pw_auth,sshdnypw' }
        let(:params) do
          {
            'type' => 'group',
            'options' => {
              'KbdInteractiveAuthentication' => 'no',
              'PasswordAuthentication' => 'no',
            },
            'target' => '/etc/ssh/sshd_config_sftp_server',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('match_block ssh_deny_pw_auth,sshdnypw') }
      end
    end
  end
end
