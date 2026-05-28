# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server match blocks' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'with a User match block' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            server_match_block   => {
              'sftpusers' => {
                'type'    => 'group',
                'options' => {
                  'ChrootDirectory'        => '/home/sftp',
                  'ForceCommand'           => 'internal-sftp',
                  'AllowTcpForwarding'     => 'no',
                  'X11Forwarding'          => 'no',
                },
              },
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{Match group sftpusers}) }
      its(:content) { is_expected.to match(%r{ChrootDirectory /home/sftp}) }
      its(:content) { is_expected.to match(%r{ForceCommand internal-sftp}) }
      its(:content) { is_expected.to match(%r{AllowTcpForwarding no}) }
      its(:content) { is_expected.to match(%r{X11Forwarding no}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end

  context 'with multiple match blocks' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            server_match_block   => {
              'admins' => {
                'type'    => 'group',
                'options' => {
                  'AllowTcpForwarding' => 'yes',
                  'X11Forwarding'      => 'yes',
                },
              },
              '10.0.0.0/8' => {
                'type'    => 'address',
                'options' => {
                  'PasswordAuthentication' => 'yes',
                },
              },
            },
          }
        PP
      end
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{Match group admins}) }
      its(:content) { is_expected.to match(%r{AllowTcpForwarding yes}) }
      its(:content) { is_expected.to match(%r{Match address 10\.0\.0\.0/8}) }
      its(:content) { is_expected.to match(%r{PasswordAuthentication yes}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
