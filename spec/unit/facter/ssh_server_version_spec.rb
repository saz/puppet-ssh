require 'spec_helper'

describe 'ssh_server_version_full' do
  before do
    Facter.fact(:kernel).stubs(:value).returns('linux')
  end
  context 'on a Linux host' do
    before do
      Facter::Util::Resolution.stubs(:exec).with('sshd -V 2>&1').returns('OpenSSH_6.6.1p1 Ubuntu-2ubuntu2.8, OpenSSL 1.0.1f 6 Jan 2014')
    end
    it 'execs sshd -V' do
      expect(Facter.fact(:ssh_server_version_full).value).to eq('6.6.1p1')
    end
  end
end
