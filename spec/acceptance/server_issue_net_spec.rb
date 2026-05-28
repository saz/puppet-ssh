# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server use_issue_net' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'with use_issue_net enabled' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh':
            storeconfigs_enabled => false,
            use_issue_net        => true,
          }
        PP
      end
    end

    describe file('/etc/issue.net') do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
    end

    describe file('/etc/ssh/sshd_config') do
      its(:content) { is_expected.to match(%r{Banner /etc/issue\.net}) }
    end

    describe command('sshd -t') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe service(service_name) do
      it { is_expected.to be_running }
    end
  end
end
