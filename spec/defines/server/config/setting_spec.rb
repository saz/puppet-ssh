require 'spec_helper'

describe 'ssh::server::config::setting', type: :define do
  let :title do
    'something'
  end

  let :facts do
    {
      osfamily: 'RedHat',
      operatingsystemmajrelease: '6'
    }
  end

  describe 'with key => "AllowGroups", value => "group1 group2"' do
    let :params do
      {
        key: 'AllowGroups',
        value: 'group1 group2'
      }
    end

    it do
      is_expected.to contain_concat__fragment('ssh_setting_something_AllowGroups').with_content(%r{\nAllowGroups group1 group2\n})
    end
  end

  describe 'with key => "Somesetting", value => true' do
    let :params do
      {
        key: 'Somesetting',
        value: true
      }
    end

    it do
      is_expected.to contain_concat__fragment('ssh_setting_something_Somesetting').with_content(%r{\nSomesetting yes\n})
    end
  end

  describe 'with key => "Foo", value => [1, 2]' do
    let :params do
      {
        key: 'Foo',
        value: [1, 2]
      }
    end

    it do
      is_expected.to contain_concat__fragment('ssh_setting_something_Foo').with_content(%r{\nFoo 1 2\n})
    end
  end

  describe 'with key => "Bar", value => {"a" => "b"}' do
    let :params do
      {
        key: 'Bar',
        value: {
          'a' => 'b'
        }
      }
    end

    it 'fails' do
      expect do
        is_expected.to compile
      end.to raise_error(%r{Hash values are not supported})
    end
  end
end

# vim: tabstop=2 shiftwidth=2 softtabstop=2
