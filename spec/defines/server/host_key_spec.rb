# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::server::host_key', type: :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'something' }
      let(:pre_condition) { 'include ssh' }

      context 'with all defaults' do
        it { is_expected.to compile.and_raise_error(%r{You must provide either public_key_source or public_key_content parameter}) }
      end

      describe 'with public_key_content, private_key_content and certificate_content' do
        let :params do
          {
            public_key_content: 'abc',
            private_key_content: 'bcd',
            certificate_content: 'cde'
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file('something_pub').
            with_content('abc').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0644').
            with_path('/etc/ssh/something.pub')
          is_expected.to contain_file('something_priv').
            with_content('bcd').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0600').
            with_path('/etc/ssh/something')
          is_expected.to contain_file('something_cert').
            with_content('cde').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0644').
            with_path('/etc/ssh/something-cert.pub')
        }
      end

      describe 'with public_key_content and private_key_content' do
        let :params do
          {
            public_key_content: 'abc',
            private_key_content: 'bcd'
          }
        end

        it {
          is_expected.to contain_file('something_pub').
            with_content('abc').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0644').
            with_path('/etc/ssh/something.pub')
          is_expected.to contain_file('something_priv').
            with_content('bcd').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0600').
            with_path('/etc/ssh/something')
          is_expected.not_to contain_file('something_cert')
        }
      end

      describe 'with *_key_content and *_key_source, *_key_source takes precedence' do
        let :params do
          {
            public_key_content: 'abc',
            public_key_source: 'a',
            private_key_content: 'bcd',
            private_key_source: 'b'
          }
        end

        it {
          is_expected.to contain_file('something_pub').
            without_content.
            with_source('a').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0644').
            with_path('/etc/ssh/something.pub')
          is_expected.to contain_file('something_priv').
            without_content.
            with_source('b').
            with_ensure('present').
            with_owner(0).
            with_group(0).
            with_mode('0600').
            with_path('/etc/ssh/something')
          is_expected.not_to contain_file('something_cert')
        }
      end

      describe 'with private_key_content and no public_key_content' do
        let :params do
          {
            private_key_content: 'bcd'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{You must provide either public_key_source or public_key_content parameter}) }
      end

      describe 'with public_key_content and no private_key_content' do
        let :params do
          {
            public_key_content: 'abc'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{You must provide either private_key_source or private_key_content parameter}) }
      end

      describe 'with private_key_source and no public_key_source' do
        let :params do
          {
            private_key_source: 'bcd'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{You must provide either public_key_source or public_key_content parameter}) }
      end

      describe 'with public_key_source and no private_key_source' do
        let :params do
          {
            public_key_source: 'abc'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{You must provide either private_key_source or private_key_content parameter}) }
      end
    end
  end
end
# vim: tabstop=2 shiftwidth=2 softtabstop=2
