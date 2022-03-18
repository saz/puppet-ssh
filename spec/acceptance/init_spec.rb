# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh' do
  context 'with defaults' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        'include ssh'
      end

      describe package('openssh-server') do
        it { is_expected.to be_installed }
      end
      describe port(22) do
        it { is_expected.to be_listening }
      end
      describe service('sshd') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end
    end
  end
end
