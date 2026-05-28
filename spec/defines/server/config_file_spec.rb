# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server::config_file' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'hardening' }

      context 'with include_dir set' do
        let :pre_condition do
          <<~PP
            class { 'ssh::server':
              include_dir        => '/etc/ssh/sshd_config.d',
              storeconfigs_enabled => false,
            }
          PP
        end

        context 'with basic options' do
          let(:params) do
            {
              options: {
                'PermitRootLogin' => 'no',
                'PasswordAuthentication' => 'no',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_concat('/etc/ssh/sshd_config.d/hardening.conf').with(
              ensure: 'present',
              owner: 0,
              group: 0,
              mode: '0600',
            )
          }

          it {
            svc = catalogue.resource('Class', 'ssh::server')[:service_name]
            is_expected.to contain_concat('/etc/ssh/sshd_config.d/hardening.conf').that_notifies("Service[#{svc}]")
          }

          it {
            is_expected.to contain_concat__fragment('sshd_config_file hardening').with(
              target: '/etc/ssh/sshd_config.d/hardening.conf',
              order: '00',
            )
          }
        end

        context 'with custom path' do
          let(:params) do
            {
              path: '/etc/ssh/sshd_config.d/custom.conf',
              options: {
                'LogLevel' => 'VERBOSE',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_concat('/etc/ssh/sshd_config.d/custom.conf') }
        end

        context 'with custom mode' do
          let(:params) do
            {
              mode: '0644',
              options: {},
            }
          end

          it {
            is_expected.to contain_concat('/etc/ssh/sshd_config.d/hardening.conf').with(
              mode: '0644',
            )
          }
        end

        context 'with include parameter' do
          let(:params) do
            {
              include: '/etc/crypto-policies/back-ends/opensshserver.config',
              options: {
                'PermitRootLogin' => 'no',
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_concat__fragment('sshd_config_file hardening').with_content(
              %r{Include /etc/crypto-policies/back-ends/opensshserver\.config},
            )
          }
        end

        context 'with validate_sshd_file enabled' do
          let :pre_condition do
            <<~PP
              class { 'ssh::server':
                include_dir        => '/etc/ssh/sshd_config.d',
                storeconfigs_enabled => false,
                validate_sshd_file => true,
              }
            PP
          end

          let(:params) do
            {
              options: {},
            }
          end

          it {
            binary = catalogue.resource('Class', 'ssh::server')[:sshd_binary]
            is_expected.to contain_concat('/etc/ssh/sshd_config.d/hardening.conf').with(
              validate_cmd: "#{binary} -tf %",
            )
          }
        end
      end

      # Skip OSes where hiera sets include_dir by default (e.g. RedHat 9)
      context 'without include_dir set', unless: os_facts.dig(:os, 'family') == 'RedHat' && os_facts.dig(:os, 'release', 'major') == '9' do
        let :pre_condition do
          <<~PP
            class { 'ssh::server':
              storeconfigs_enabled => false,
            }
          PP
        end

        let(:params) do
          {
            options: {},
          }
        end

        it { is_expected.to compile.and_raise_error(%r{ssh::server::config_file\(\) define not supported if ssh::server::include_dir not set}) }
      end
    end
  end
end
