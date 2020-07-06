require 'spec_helper'

describe 'ssh::client', type: 'class' do
  context 'when on Debian with no other parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      is_expected.to contain_package('openssh-client').with(ensure: 'present')
    end
  end
  context 'when on Debian with custom ensure' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end
    let :params do
      {
        ensure: 'latest'
      }
    end

    it do
      is_expected.to contain_package('openssh-client').with(ensure: 'latest')
    end
  end
end
