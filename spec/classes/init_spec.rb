require 'spec_helper'

describe 'ssh', :type => 'class' do
    context "On Debian with no other parameters" do
        let :facts do
        {
            :osfamily => 'Debian',
            :interfaces => 'eth0',
            :ipaddress_eth0 => '192.168.1.1',
            :concat_basedir => '/tmp'
        }
        end
        it {
            should contain_class('ssh::client')
        }
        it {
            should contain_class('ssh::server')
        }
    end
end
