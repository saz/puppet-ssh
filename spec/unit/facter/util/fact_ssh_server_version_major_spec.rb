# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
    allow(Facter.fact(:kernel)).to receive(:value).and_return('linux')
  end

  describe 'ssh_server_version_major' do
    context 'with 3 point semver syntax (6.6.1p1)' do
      context 'with ssh_server_version_full fact present returns major version' do
        before do
          allow(Facter.fact(:ssh_server_version_full)).to receive(:value).and_return('6.6.1p1')
        end

        it do
          expect(Facter.fact(:ssh_server_version_major).value).to eq('6')
        end
      end
    end

    context 'with 2 point semver syntax (7.2p2)' do
      context 'with ssh_server_version_full fact present returns major version' do
        before do
          allow(Facter.fact(:ssh_server_version_full)).to receive(:value).and_return('7.2p2')
        end

        it do
          expect(Facter.fact(:ssh_server_version_major).value).to eq('7')
        end
      end
    end

    context 'without ssh_server_version_full fact present returns nil' do
      before do
        allow(Facter.fact(:ssh_server_version_full)).to receive(:value).and_return(nil)
      end

      it do
        expect(Facter.fact(:ssh_server_version_major).value).to be_nil
      end
    end
  end
end
