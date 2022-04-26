# frozen_string_literal: true

require 'spec_helper'

describe 'ssh_server_version_full' do
  before { Facter.clear }

  after { Facter.clear }

  context 'when on a Linux host' do
    before do
      allow(Facter.fact(:kernel)).to receive(:value).and_return('linux')
      allow(Facter::Util::Resolution).to receive(:which).with('sshd').and_return('/usr/bin/sshd')
      allow(Facter::Util::Resolution).to receive(:exec).with('sshd -V 2>&1').and_return('OpenSSH_6.6.1p1 Ubuntu-2ubuntu2.8, OpenSSL 1.0.1f 6 Jan 2014')
    end

    it 'execs sshd -V and returns full version number' do
      expect(Facter.fact(:ssh_server_version_full).value).to eq('6.6.1p1')
    end
  end

  context 'when on a SunOS host' do
    before do
      allow(Facter.fact(:kernel)).to receive(:value).and_return('SunOS')
      allow(Facter::Util::Resolution).to receive(:which).with('sshd').and_return('/usr/bin/sshd')
      allow(Facter::Util::Resolution).to receive(:exec).with('sshd -V 2>&1').and_return('Sun_SSH_2.4, SSH protocols 1.5/2.0, OpenSSL 0x100020bf')
    end

    it 'execs sshd -V and returns full version number' do
      expect(Facter.fact(:ssh_server_version_full).value).to eq('2.4')
    end
  end
end
