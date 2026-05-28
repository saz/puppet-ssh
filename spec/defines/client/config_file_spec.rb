# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::client::config_file' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'work' }

      context 'with include_dir set' do
        let :pre_condition do
          <<~PP
            class { 'ssh::client':
              include_dir          => '/etc/ssh/ssh_config.d',
              storeconfigs_enabled => false,
            }
          PP
        end

        context 'with basic options' do
          let(:params) do
            {
              options: {
                'Host *.work.internal' => {
                  'User' => 'deploy',
                  'IdentityFile' => '~/.ssh/work_key',
                },
              },
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_concat('/etc/ssh/ssh_config.d/work.conf').with(
              ensure: 'present',
              owner: 0,
              group: 0,
              mode: '0644',
            )
          }

          it {
            is_expected.to contain_concat__fragment('ssh_config_file work').with(
              target: '/etc/ssh/ssh_config.d/work.conf',
              order: '00',
            )
          }
        end

        context 'with custom path' do
          let(:params) do
            {
              path: '/etc/ssh/ssh_config.d/custom.conf',
              options: {},
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_concat('/etc/ssh/ssh_config.d/custom.conf') }
        end

        context 'with custom mode' do
          let(:params) do
            {
              mode: '0600',
              options: {},
            }
          end

          it {
            is_expected.to contain_concat('/etc/ssh/ssh_config.d/work.conf').with(
              mode: '0600',
            )
          }
        end

        context 'with include parameter' do
          let(:params) do
            {
              include: '/etc/crypto-policies/back-ends/openssh.config',
              options: {},
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_concat__fragment('ssh_config_file work').with_content(
              %r{Include /etc/crypto-policies/back-ends/openssh\.config},
            )
          }
        end

        context 'with empty options' do
          let(:params) do
            {
              options: {},
            }
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_concat__fragment('ssh_config_file work') }
        end
      end

      context 'without include_dir set' do
        let :pre_condition do
          <<~PP
            class { 'ssh::client':
              storeconfigs_enabled => false,
            }
          PP
        end

        let(:params) do
          {
            options: {},
          }
        end

        it { is_expected.to compile.and_raise_error(%r{ssh::client::config_file\(\) define not supported if ssh::client::include_dir not set}) }
      end
    end
  end
end
