require 'spec_helper'

describe 'ssh::client::config::user', type: :define do
  let :title do
    'riton'
  end

  let :ssh_options do
    {
      'HashKnownHosts' => 'yes',
      'Host *.in2p3.fr' => {
        'User' => 'riton',
        'GSSAPIAuthentication' => 'no'
      }
    }
  end

  let :facts do
    {
      osfamily: 'RedHat',
      concat_basedir: '/tmp'
    }
  end

  describe 'with invalid parameters' do
    params = {
      ensure: ['somestate', 'does not'],
      target: ['./somedir', 'is not an absolute path'],
      user_home_dir: ['./somedir', 'is not an absolute path'],
      manage_user_ssh_dir: ['maybe', 'is not a boolean'],
      options: ['the_options', 'is not a Hash']
    }

    params.each do |param, value|
      context "with invalid value for #{param}" do
        let :params do
          {
            param => value[0]
          }
        end

        it 'fails' do
          expect do
            should compile
          end.to raise_error(%r{#{value[1]}})
        end
      end
    end # params.each
  end # describe 'with invalid parameters'

  describe 'with correct values' do
    describe 'with a user provided target' do
      let :target do
        '/root/.ssh/config'
      end

      let :params do
        {
          target: target
        }
      end

      it do
        should contain_file(target).with(ensure: 'file',
                                         owner: title,
                                         mode: '0600')
      end
    end # describe 'with a user provided target'

    describe 'user_home_dir behavior' do
      context 'with a user provided user_home_dir' do
        let :user_home_dir do
          '/path/to/home'
        end

        context 'with manage_user_ssh_dir default value' do
          let :params do
            {
              user_home_dir: user_home_dir
            }
          end

          it 'contains ssh directory and ssh config' do
            should contain_file("#{user_home_dir}/.ssh").with(ensure: 'directory',
                                                              owner: title,
                                                              mode: '0700').that_comes_before("File[#{user_home_dir}/.ssh/config]")

            should contain_file("#{user_home_dir}/.ssh/config").with(ensure: 'file',
                                                                     owner: title,
                                                                     mode: '0600')
          end
        end # context 'with manage_user_ssh_dir default value'

        context 'with manage_user_ssh_dir set to false' do
          let :params do
            {
              user_home_dir: user_home_dir,
              manage_user_ssh_dir: false
            }
          end

          it do
            should_not contain_file("#{user_home_dir}/.ssh")
          end
        end # context 'with manage_user_ssh_dir set to false'
      end # context 'with a user provided user_home_dir'

      context 'with no user provided user_home_dir' do
        it 'with manage_user_ssh_dir default value' do
          should contain_file("/home/#{title}/.ssh").that_comes_before("File[/home/#{title}/.ssh/config]")
          should contain_file("/home/#{title}/.ssh/config")
        end

        context 'with manage_user_ssh_dir set to false' do
          let :params do
            {
              manage_user_ssh_dir: false
            }
          end

          it do
            should_not contain_file("/home/#{title}/.ssh")
          end

          it do
            should contain_file("/home/#{title}/.ssh/config")
          end
        end # context 'with manage_user_ssh_dir set to false'
      end # context 'with no user provided user_home_dir'
    end # describe 'user_home_dir behavior'

    describe 'ssh configuration content' do
      let :params do
        {
          options: ssh_options
        }
      end

      it 'has single value' do
        should contain_file("/home/#{title}/.ssh/config").with(content: %r{HashKnownHosts\s+yes})
      end

      it 'has Hash value' do
        should contain_file("/home/#{title}/.ssh/config").with(content: %r{Host \*\.in2p3\.fr\s*\n\s+GSSAPIAuthentication\s+no\s*\n\s+User\s+riton})
      end
    end
  end # describe 'with correct values'
end

# vim: tabstop=2 shiftwidth=2 softtabstop=2
