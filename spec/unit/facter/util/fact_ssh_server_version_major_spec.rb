require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
    Facter.fact(:kernel).stubs(:value).returns('linux')
  end

  describe 'ssh_server_version_major' do
    context '3 point semver syntax (6.6.1p1)' do
      context 'returns major version when ssh_server_version_full fact present' do
        before do
          Facter.fact(:ssh_server_version_full).stubs(:value).returns('6.6.1p1')
        end
        it do
          expect(Facter.fact(:ssh_server_version_major).value).to eq('6')
        end
      end
    end

    context '2 point semver syntax (7.2p2)' do
      context 'returns major version when ssh_server_version_full fact present' do
        before do
          Facter.fact(:ssh_server_version_full).stubs(:value).returns('7.2p2')
        end
        it do
          expect(Facter.fact(:ssh_server_version_major).value).to eq('7')
        end
      end
    end

    context 'returns nil when ssh_server_version_full fact not present' do
      before do
        Facter.fact(:ssh_server_version_full).stubs(:value).returns(nil)
      end
      it do
        expect(Facter.fact(:ssh_server_version_major).value).to be_nil
      end
    end
  end
end
