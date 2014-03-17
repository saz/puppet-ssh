require 'spec_helper'

describe 'ssh::client', :type => 'class' do
    context "On Debian with no other parameters" do
        let :facts do
        {
            :osfamily => 'Debian',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '192.168.1.1'
        }
        end
        it {
            should contain_package('openssh-client').with(:ensure => 'present')
        }
    end
    context "On Debian with custom ensure" do
        let :facts do
        {
            :osfamily => 'Debian',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '192.168.1.1'
        }
        end
        let :params do
        {
            :ensure => 'latest'
        }
        end
        it {
            should contain_package('openssh-client').with(:ensure => 'latest')
        }
    end
end
