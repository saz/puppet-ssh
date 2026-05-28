# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server::options' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'test_options' }
      let :pre_condition do
        'include ssh'
      end

      context 'with simple key-value options' do
        let(:params) do
          {
            options: {
              'PermitRootLogin' => 'no',
              'MaxAuthTries' => '3',
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_concat__fragment('options test_options').with(
            target: '/etc/ssh/sshd_config',
            order: '150',
          )
        }

        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{PermitRootLogin no}) }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{MaxAuthTries 3}) }
      end

      context 'with boolean values' do
        let(:params) do
          {
            options: {
              'X11Forwarding' => true,
              'PasswordAuthentication' => false,
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{X11Forwarding yes}) }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{PasswordAuthentication no}) }
      end

      context 'with array values' do
        let(:params) do
          {
            options: {
              'AcceptEnv' => %w[LANG LC_CTYPE LC_ALL],
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{AcceptEnv LANG}) }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{AcceptEnv LC_CTYPE}) }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{AcceptEnv LC_ALL}) }
      end

      context 'with hash values (subsection)' do
        let(:params) do
          {
            options: {
              'Match User deploy' => {
                'ChrootDirectory' => '/home/deploy',
                'ForceCommand' => 'internal-sftp',
              },
            },
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{Match User deploy}) }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{ChrootDirectory /home/deploy}) }
        it { is_expected.to contain_concat__fragment('options test_options').with_content(%r{ForceCommand internal-sftp}) }
      end

      context 'with custom order' do
        let(:params) do
          {
            options: {
              'LogLevel' => 'VERBOSE',
            },
            order: 10,
          }
        end

        it {
          is_expected.to contain_concat__fragment('options test_options').with(
            order: '110',
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
        it { is_expected.to contain_concat__fragment('options test_options') }
      end
    end
  end
end
