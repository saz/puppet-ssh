require 'spec_helper'

describe 'ssh::server::config::setting', :type => :define do

  let :title do
    'something'
  end

  let :facts do {
    :osfamily       => 'RedHat',
    :concat_basedir => '/tmp'
  } end

  describe 'with key => "AllowGroups", value => "group1 group2"' do
    let :params do {
      :key   => 'AllowGroups',
      :value => 'group1 group2'
    } end

    it {
      should contain_concat__fragment('ssh_setting_something_AllowGroups').with_content(/\nAllowGroups group1 group2\n/)
    }
  end

  describe 'with key => "Somesetting", value => true' do
    let :params do {
      :key   => 'Somesetting',
      :value => true
    } end

    it {
      should contain_concat__fragment('ssh_setting_something_Somesetting').with_content(/\nSomesetting yes\n/)
    }
  end

  describe 'with key => "Foo", value => [1, 2]' do
    let :params do {
      :key   => 'Foo',
      :value => [1, 2]
    } end

    it {
      should contain_concat__fragment('ssh_setting_something_Foo').with_content(/\nFoo 1 2\n/)
    }
  end

  describe 'with key => "Bar", value => {"a" => "b"}' do
    let :params do {
      :key   => 'Bar',
      :value => {
        'a' => 'b'
      }
    } end

    it 'should fail' do
      expect {
        should compile
      }.to raise_error(/Hash values are not supported/)
    end
  end
end

# vim: tabstop=2 shiftwidth=2 softtabstop=2
