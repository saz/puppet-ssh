# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::ipaddresses', type: :puppet_function do
  it 'exists' do
    is_expected.not_to be_nil
  end

  context 'with dummy structured fact data' do
    let(:facts) do
      JSON.parse File.read(File.join(File.dirname(__FILE__), '../../fixtures/mock-interface-fact.json'))
    end

    describe 'without parameters' do
      it 'returns all IPs other than localhost' do
        is_expected.to run.and_return(['172.17.0.1', '10.13.42.61', '10.0.0.110', '10.0.0.104', '10.0.0.109'])
      end
    end

    describe 'with excluded interface' do
      it 'doesn\'t return the IPs of excluded interface' do
        is_expected.to run.with_params(['docker0']).and_return(['10.13.42.61', '10.0.0.110', '10.0.0.104', '10.0.0.109'])
      end
    end

    describe 'with excluded interfaces' do
      it 'doesn\'t return the IPs of those interfaces' do
        is_expected.to run.with_params(%w[docker0 eno1]).and_return([])
      end
    end
  end

  context 'with dummy legacy fact data' do
    let(:facts) do
      {
        networking: {},
        interfaces: 'lo,docker0,eno1',
        ipaddress_lo: '127.0.0.1',
        ipaddress_eno1: '10.13.42.61',
        ipaddress_docker0: '172.17.0.1'
      }
    end

    describe 'without parameters' do
      it 'returns all IPs other than localhost' do
        is_expected.to run.and_return(['172.17.0.1', '10.13.42.61'])
      end
    end

    describe 'with excluded interface' do
      it 'doesn\'t return the IPs of excluded interface' do
        is_expected.to run.with_params(['docker0']).and_return(['10.13.42.61'])
      end
    end

    describe 'with excluded interfaces' do
      it 'doesn\'t return the IPs of those interfaces' do
        is_expected.to run.with_params(%w[docker0 eno1]).and_return([])
      end
    end
  end
end
