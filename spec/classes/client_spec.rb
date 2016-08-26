require 'spec_helper'

describe 'ssh::client', type: 'class' do
  context 'On Debian with no other parameters' do
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
      should contain_package('openssh-client').with(ensure: 'present')
    end
  end
  context 'On Debian with custom ensure' do
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
      should contain_package('openssh-client').with(ensure: 'latest')
    end
  end
end
