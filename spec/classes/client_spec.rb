require 'spec_helper'

describe 'ssh::client', type: 'class' do
  context 'when on Debian with no other parameters' do
    let :facts do
      {
        osfamily: 'Debian',
        interfaces: 'eth0',
        ipaddress_eth0: '192.168.1.1',
        ipaddress6_eth0: '::1',
        concat_basedir: '/tmp',
        puppetversion: '3.7.0'
      }
    end

    it do
      is_expected.to contain_package('openssh-client').with(ensure: 'present')
    end
  end
  context 'when on Debian with custom ensure' do
    let :facts do
      {
        osfamily: 'Debian',
        interfaces: 'eth0',
        ipaddress_eth0: '192.168.1.1',
        ipaddress6_eth0: '::1',
        concat_basedir: '/tmp',
        puppetversion: '3.7.0'
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
