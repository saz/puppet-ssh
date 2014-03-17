source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.1.0', :require => false
gem 'puppet-lint', '>= 0.3.2'
gem 'facter', '>= 1.7.0', "< 1.8.0"

# vim:ft=ruby
