# frozen_string_literal: true

require 'spec_helper'

describe 'ssh::client::config::user' do
  on_supported_os.each do |os, os_facts|
    let(:facts) { os_facts }

    context "on #{os}" do
      let(:title) { 'riton' }

      let :ssh_options do
        {
          'HashKnownHosts' => 'yes',
          'Host *.in2p3.fr' => {
            'User' => 'riton',
            'GSSAPIAuthentication' => 'no'
          }
        }
      end

      context 'with all defaults' do
        it { is_expected.to compile.with_all_deps }
      end

      describe 'with invalid parameters' do
        params = {
          ensure: ['somestate', 'expects a match for Enum'],
          target: ['./somedir', 'Pattern'],
          user_home_dir: ['./somedir', 'Pattern'],
          manage_user_ssh_dir: ['maybe', 'expects a Boolean'],
          options: ['the_options', 'Hash value']
        }

        params.each do |param, value|
          context "with invalid value for #{param}" do
            let :params do
              {
                param => value[0]
              }
            end

            it { is_expected.not_to compile }
          end
        end
      end
      # describe 'with invalid parameters'

      describe 'with correct values' do
        describe 'with a user provided target' do
          let(:target) { '/root/.ssh/config' }

          let :params do
            {
              target: target
            }
          end

          it {
            is_expected.to contain_concat_file(target).with(ensure: 'present', tag: title)
            is_expected.to contain_concat_fragment(title).with(tag: title, target: target)
          }
        end
        # describe 'with a user provided target'

        describe 'user_home_dir behavior' do
          context 'with a user provided user_home_dir' do
            let(:user_home_dir) { '/path/to/home' }

            context 'with manage_user_ssh_dir default value' do
              let :params do
                {
                  user_home_dir: user_home_dir
                }
              end

              it 'contains ssh directory and ssh config' do
                is_expected.to contain_file("#{user_home_dir}/.ssh").with(
                  ensure: 'directory',
                  owner: title,
                  mode: '0700'
                ).that_comes_before("Concat_file[#{user_home_dir}/.ssh/config]")

                is_expected.to contain_concat_file("#{user_home_dir}/.ssh/config").with(
                  ensure: 'present',
                  owner: title,
                  mode: '0600'
                )
              end
            end
            # context 'with manage_user_ssh_dir default value'

            context 'with manage_user_ssh_dir set to false' do
              let :params do
                {
                  user_home_dir: user_home_dir,
                  manage_user_ssh_dir: false
                }
              end

              it do
                is_expected.not_to contain_file("#{user_home_dir}/.ssh")
              end
            end
            # context 'with manage_user_ssh_dir set to false'
          end
          # context 'with a user provided user_home_dir'

          context 'with no user provided user_home_dir' do
            it 'with manage_user_ssh_dir default value' do
              is_expected.to contain_file("/home/#{title}/.ssh").that_comes_before("Concat_file[/home/#{title}/.ssh/config]")
              is_expected.to contain_concat_file("/home/#{title}/.ssh/config")
            end

            context 'with manage_user_ssh_dir set to false' do
              let :params do
                {
                  manage_user_ssh_dir: false
                }
              end

              it do
                is_expected.not_to contain_file("/home/#{title}/.ssh")
              end

              it do
                is_expected.to contain_concat_file("/home/#{title}/.ssh/config")
              end
            end
            # context 'with manage_user_ssh_dir set to false'
          end
          # context 'with no user provided user_home_dir'
        end
        # describe 'user_home_dir behavior'

        describe 'ssh configuration content' do
          let :params do
            {
              options: ssh_options
            }
          end

          it 'has single value' do
            is_expected.to contain_concat_fragment(title).with(
              content: %r{HashKnownHosts\s+yes},
              target: "/home/#{title}/.ssh/config"
            )
          end

          it 'has Hash value' do
            is_expected.to contain_concat_fragment(title).with(
              content: %r{Host \*\.in2p3\.fr\s*\n\s+GSSAPIAuthentication\s+no\s*\n\s+User\s+riton},
              target: "/home/#{title}/.ssh/config"
            )
          end
        end
      end
    end
  end
end
# vim: tabstop=2 shiftwidth=2 softtabstop=2
