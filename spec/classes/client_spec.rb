require 'spec_helper'

describe 'ssh::client', type: 'class' do
  context 'when on Debian with no other parameters' do
    let :facts do
      {
        :os => {
          'family' => 'Debian'
        },
        'networking' => {
          'interfaces' => {
            'eth0' => {
              'ip' => '10.0.0.1'
            },
            'eth1' => {
              'ip' => '10.0.1.1'
            },
          }
        }
      }
    end

    it { is_expected.to contain_package('openssh-client').with_ensure('installed') }
  end
  context 'when on Debian with custom ensure' do
    let :facts do
      {
        :os => {
          'family' => 'Debian'
        },
        'networking' => {
          'interfaces' => {
            'eth0' => {
              'ip' => '10.0.0.1'
            },
            'eth1' => {
              'ip' => '10.0.1.1'
            },
          }
        }
      }
    end
    let :params do
      {
        ensure: 'latest'
      }
    end

    it { is_expected.to contain_package('openssh-client').with_ensure('latest') }
  end
end
