module Puppet::Parser::Functions
  newfunction(:sshserver_options_to_augeas_sshd_config, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
  This function will convert a key-value hash to a format understandable by the augeas sshd_config provider
  It will also optionally deal with keys that should be absent, and inject static parameters if supplied.

  Usage: sshserver_options_to_augeas_sshd_config($options_present, $options_absent, $other_parameters)
  -  $options_hash is mandatory and must be a hash.
  -  $options_absent is optional and can be either a single value or an array.
  -  $other_parameters is optional and must be a hash.

  Example:
  $options = {
                'Match User www-data' => {
                   'PasswordAuthentication' => 'yes',
                   'X11Forwarding' => 'no',
                },
                'Match Group bamboo' => {
                   'ForcedCommand'  => '/bin/echo hello world',
                },
                'X11Forwarding'          => 'yes',
                'DebianBanner'           => '/etc/banner.net',
                'AllowGroups'            => ["sshgroups", "admins"],
             }
  $options_absent = ['DebianBanner','NoneField']
  $other_parameters = { 'target' => '/etc/ssh/sshd_config' }

  $options_final_augeas = sshserver_options_to_augeas_sshd_config($options, $options_absent, $other_parameters)

  In this case, the value of $options_final_augeas would be:

  'PasswordAuthentication User www-data' => {
      'ensure'    => 'present',
      'condition' => 'User www-data',
      'key'       => 'PasswordAuthentication',
      'value'     => 'yes',
      'target'    => '/etc/ssh/sshd_config',
   }
   'X11Forwarding User www-data' => {
      'ensure'    => 'present',
      'condition' => 'User www-data',
      'key'       => 'X11Forwarding',
      'value'     => 'no',
      'target'    => '/etc/ssh/sshd_config',
   }
   'ForcedCommand Group bamboo' => {
      'ensure'    => 'present',
      'condition' => 'Group bamboo',
      'key'       => 'ForcedCommand',
      'value'     => '/bin/echo hello world',
      'target'    => '/etc/ssh/sshd_config',
   }
   'X11Forwarding' => {
      'ensure'    => 'present',
      'key'       => 'X11Forwarding',
      'value'     => 'yes',
      'target'    => '/etc/ssh/sshd_config',
   }
   'DebianBanner' => {
      'ensure'    => 'absent',
      'key'       => 'DebianBanner',
      'target'    => '/etc/ssh/sshd_config',
   }
   'AllowGroups' => {
      'ensure'    => 'present',
      'key'       => 'AllowGroups',
      'value'     => ['sshgroups','admins'],
      'target'    => '/etc/ssh/sshd_config',
   }
   'NoneField' => {
      'ensure'    => 'absent',
      'key'       => 'NoneField',
      'target'    => '/etc/ssh/sshd_config',
   }

  Note how the word "Match" is stripped away.

  ENDHEREDOC

    if args.empty?
      raise Puppet::ParseError, 'sshserver_options_to_augeas_sshd_config: expects at least one argument'
    end

    options = args[0]
    unless options.is_a?(Hash)
      raise Puppet::ParseError, 'sshserver_options_to_augeas_sshd_config: first argument must be a hash'
    end

    options_absent = args[1] if args[1]
    other_parameters = args[2] if args[2]
    if options_absent
      unless options_absent.is_a?(Array) || options_absent.is_a?(String)
        raise Puppet::ParseError, 'sshserver_options_to_augeas_sshd_config: second argument, if supplied, must be an array or a string'
      end
    end
    if other_parameters
      unless other_parameters.is_a?(Hash)
        raise Puppet::ParseError, 'sshserver_options_to_augeas_sshd_config: third argument, if supplied, must be a hash'
      end
    end

    options_final_augeas = {}
    options.each do |key1, value1|
      if value1.is_a?(Hash)
        value1.each do |key2, value2|
          v = { 'ensure' => 'present' }.merge('condition' => key1.gsub('Match ', '')).merge('key' => key2, 'value' => value2)
          options_final_augeas["#{key2} #{key1.gsub('Match ', '')}"] = v.merge(other_parameters)
        end
      else
        options_final_augeas[key1] = { 'ensure' => 'present' }.merge('key' => key1, 'value' => value1).merge(other_parameters)
      end
    end
    options_absent.each do |value|
      options_final_augeas[value] = { 'ensure' => 'absent' }.merge('key' => value).merge(other_parameters)
    end
    return options_final_augeas
  end # newfunction
end # module
