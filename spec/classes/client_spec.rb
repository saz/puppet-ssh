# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::client', type: 'class' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no other parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('ssh::client::config') }
        it { is_expected.to contain_class('ssh::client::install') }
        it { is_expected.to contain_concat('/etc/ssh/ssh_config') }
      end

      context 'with a different ssh_config location' do
        let :params do
          {
            ssh_config: '/etc/ssh/another_ssh_config',
          }
        end

        it { is_expected.to contain_concat('/etc/ssh/another_ssh_config') }
      end

      context 'with include_dir set' do
        let :params do
          {
            include_dir: '/etc/ssh/ssh_config.d',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/ssh/ssh_config.d').with(
            ensure: 'directory',
            owner: 0,
            group: 0,
            mode: '0700',
            purge: true,
            recurse: true,
          )
        }
      end

      context 'with include_dir and include_dir_purge false' do
        let :params do
          {
            include_dir: '/etc/ssh/ssh_config.d',
            include_dir_purge: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('/etc/ssh/ssh_config.d').with(
            ensure: 'directory',
            purge: false,
            recurse: false,
          )
        }
      end

      context 'with include_dir and custom mode' do
        let :params do
          {
            include_dir: '/etc/ssh/ssh_config.d',
            include_dir_mode: '0755',
          }
        end

        it {
          is_expected.to contain_file('/etc/ssh/ssh_config.d').with(
            mode: '0755',
          )
        }
      end

      context 'with config_files' do
        let :params do
          {
            include_dir: '/etc/ssh/ssh_config.d',
            config_files: {
              'custom' => {
                'options' => {
                  'Host *.example.com' => {
                    'ProxyJump' => 'bastion.example.com',
                  },
                },
              },
              'work' => {
                'options' => {
                  'Host *.work.internal' => {
                    'User' => 'deploy',
                    'IdentityFile' => '~/.ssh/work_key',
                  },
                },
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_ssh__client__config_file('custom') }
        it { is_expected.to contain_ssh__client__config_file('work') }

        it {
          is_expected.to contain_concat('/etc/ssh/ssh_config.d/custom.conf').with(
            ensure: 'present',
            owner: 0,
            group: 0,
            mode: '0644',
          )
        }

        it {
          is_expected.to contain_concat('/etc/ssh/ssh_config.d/work.conf').with(
            ensure: 'present',
            owner: 0,
            group: 0,
            mode: '0644',
          )
        }
      end

      context 'without include_dir but with config_files' do
        let :params do
          {
            config_files: {
              'custom' => {
                'options' => {},
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_ssh__client__config_file('custom') }
      end
    end
  end
end
