require 'spec_helper'

describe 'ssh', type: 'class' do
  context 'when on Debian with no other parameters' do
    let :facts do
      {
        osfamily: 'Debian'
      }
    end

    it do
      is_expected.to contain_class('ssh::client')
    end
    it do
      is_expected.to contain_class('ssh::server')
    end
    it do
      is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd(nil)
    end

    it do
      is_expected.to contain_resources('sshkey').with_purge(true)
    end

    context 'when on Debian with the validate_sshd_file setting' do
      let :facts do
        {
          osfamily: 'Debian'
        }
      end
      let :params do
        {
          validate_sshd_file: true
        }
      end

      it do
        is_expected.to contain_class('ssh::client')
      end
      it do
        is_expected.to contain_concat('/etc/ssh/sshd_config').with_validate_cmd('/usr/sbin/sshd -tf %')
      end
    end
  end

  standard_facts = {
    osfamily: 'Debian'
  }

  context 'When on Debian without resource purging' do
    let :facts do
      standard_facts
    end
    let :params do
      { 'purge_unmanaged_sshkeys' => false }
    end

    it do
      is_expected.not_to contain_resources('sshkey')
    end
  end
end
