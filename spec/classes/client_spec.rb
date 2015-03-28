require 'spec_helper'

describe 'ssh::client', :type => 'class' do
    context "On Debian with manage_ssh_known_hosts set to true" do
        let :params do
          {
            :manage_ssh_known_hosts => true
          }
        end
        let :facts do
        {
            :osfamily => 'Debian',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '192.168.1.1',
            :concat_basedir => '/tmp'
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
            :ipaddress_eth0 => '192.168.1.1',
            :concat_basedir => '/tmp'
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
