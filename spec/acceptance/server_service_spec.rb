# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ssh server service management' do
  service_name = case fact('os.family')
                 when 'Debian'
                   'ssh'
                 else
                   'sshd'
                 end

  context 'with service stopped and disabled' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh::server':
            storeconfigs_enabled => false,
            service_ensure       => 'stopped',
            service_enable       => false,
          }
        PP
      end
    end

    describe service(service_name) do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end
  end

  context 'restore service to running and enabled' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PP
          class { 'ssh::server':
            storeconfigs_enabled => false,
            service_ensure       => 'running',
            service_enable       => true,
          }
        PP
      end
    end

    describe service(service_name) do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(22) do
      it { is_expected.to be_listening }
    end
  end
end
