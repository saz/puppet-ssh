require 'spec_helper'

describe 'ssh_server_version_full' do
  context 'when on a Linux host' do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns('linux')
      Facter::Util::Resolution.stubs(:which).with('sshd').returns('/usr/sbin/sshd')
      Facter::Util::Resolution.stubs(:exec).with('sshd -V 2>&1').returns('OpenSSH_6.6.1p1 Ubuntu-2ubuntu2.8, OpenSSL 1.0.1f 6 Jan 2014')
    end
    it 'execs sshd -V and returns full version number' do
      expect(Facter.fact(:ssh_server_version_full).value).to eq('6.6.1p1')
    end
  end
  context 'when on a SunOS host' do
    before do
      Facter.clear
      Facter.fact(:kernel).stubs(:value).returns('SunOS')
      Facter::Util::Resolution.stubs(:which).with('sshd').returns('/usr/bin/sshd')
      Facter::Util::Resolution.stubs(:exec).with('sshd -V 2>&1').returns('Sun_SSH_2.4, SSH protocols 1.5/2.0, OpenSSL 0x100020bf')
    end
    it 'execs sshd -V and returns full version number' do
      expect(Facter.fact(:ssh_server_version_full).value).to eq('2.4')
    end
  end
end
