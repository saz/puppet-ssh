# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::hostkeys', type: 'class' do
  _, os_facts = on_supported_os.first

  let(:facts) { os_facts }

  context 'with tags' do
    let(:params) do
      {
        tags: %w[group1 group2]
      }
    end

    %w[rsa].each do |key_type|
      it {
        expect(exported_resources).to contain_sshkey("foo.example.com_#{key_type}").
          with(
            ensure: 'present',
            type: %r{^ssh-#{key_type}},
            tag: %w[group1 group2]
          )
      }
    end
  end

  context 'with storeconfigs_group' do
    let(:params) do
      {
        storeconfigs_group: 'server_group',
      }
    end

    %w[rsa].each do |key_type|
      it {
        expect(exported_resources).to contain_sshkey("foo.example.com_#{key_type}").
          with(
            ensure: 'present',
            type: %r{^ssh-#{key_type}},
            tag: %w[hostkey_all hostkey_server_group]
          )
      }
    end
  end

  context 'with storeconfigs_group and tags' do
    let(:params) do
      {
        storeconfigs_group: 'server_group',
        tags: %w[group1 group2],
      }
    end

    %w[rsa].each do |key_type|
      it {
        expect(exported_resources).to contain_sshkey("foo.example.com_#{key_type}").
          with(
            ensure: 'present',
            type: %r{^ssh-#{key_type}},
            tag: %w[hostkey_all hostkey_server_group group1 group2]
          )
      }
    end
  end

  context 'when filtering a key type' do
    let(:params) do
      {
        exclude_key_types: ['ed25519'],
      }
    end

    it do
      expect(exported_resources).not_to contain_sshkey('foo.example.com_ed25519')
    end
  end
end
