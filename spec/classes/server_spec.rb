# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server', type: 'class' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      svc_name = case os_facts[:os]['family']
                 when 'Debian'
                   'ssh'
                 when 'Archlinux'
                   'sshd.service'
                 when 'Darwin'
                   'com.openssh.sshd'
                 when 'Solaris', 'SmartOS'
                   'svc:/network/ssh:default'
                 else
                   'sshd'
                 end

      sshd_config_custom = case os_facts[:os]['family']
                           when 'Solaris'
                             "# File is managed by Puppet\n\nChallengeResponseAuthentication no\nHostKey /etc/ssh/ssh_host_rsa_key\nHostKey /etc/ssh/ssh_host_dsa_key\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp /some/path\nUsePAM no\nX11Forwarding no\n"
                           else
                             "# File is managed by Puppet\n\nAcceptEnv LANG LC_*\nChallengeResponseAuthentication no\nPrintMotd no\nSomeOtherKey someValue\nSubsystem sftp /some/path\nUsePAM no\nX11Forwarding no\n"
                           end

      context 'with no other parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ssh::knownhosts') }
        it { is_expected.to contain_class('ssh::server::config') }
        it { is_expected.to contain_class('ssh::server::install') }
        it { is_expected.to contain_class('ssh::server::service') }
        it { is_expected.to contain_service(svc_name) }
        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil) }
        it { is_expected.to contain_concat__fragment('global config') }
      end

      context 'with custom options' do
        let :params do
          {
            options: {
              Subsystem: 'sftp /some/path',
              X11Forwarding: 'no',
              UsePAM: 'no',
              SomeOtherKey: 'someValue'
            }
          }
        end

        it { is_expected.to contain_concat__fragment('global config').with_content(sshd_config_custom) }
      end

      context 'with a custom service_name' do
        let :params do
          {
            service_name: 'custom_sshd_name'
          }
        end

        it { is_expected.to contain_service('custom_sshd_name') }
      end

      context 'with the validate_sshd_file setting' do
        let :params do
          {
            validate_sshd_file: true
          }
        end

        it { is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd('/usr/sbin/sshd -tf %') }
      end

      context 'with a different sshd_config location' do
        let :params do
          {
            sshd_config: '/etc/ssh/another_sshd_config'
          }
        end

        it { is_expected.to contain_concat('/etc/ssh/another_sshd_config') }
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
