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
    context "On Arch" do
        let :facts do
        {
            :osfamily => 'Archlinux',
            :lsbdistdescription => 'Arch Linux',
            :lsbdistid => 'Arch',
            :operatingsystem => 'Archlinux',
            :interfaces => 'enp4s0',
            :ipaddress_eth0 => '192.168.1.1'
        }
        end

        describe "with no other parameters" do
            it {
                should contain_package('openssh').only_with(:ensure => 'present', :name => 'openssh')
            }
        end

        describe "with custom ensure" do
            let :params do
            {
                :ensure => 'latest'
            }
            end
            it {
                should contain_package('openssh').only_with(:ensure => 'latest', :name => 'openssh')
            }
        end
    end
end
