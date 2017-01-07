module Puppet::Parser::Functions
  newfunction(:sshclient_options_to_augeas_ssh_config, :type => :rvalue, :doc => <<-'ENDHEREDOC') do |args|
  This function will convert a key-value hash to a format understandable by the augeas sshd_config provider
  It will also optionally deal with keys that should be absent, and inject static parameters if supplied.

  Usage: sshclient_options_to_augeas_ssh_config($options_present, $options_absent, $other_parameters)
  -  $options_hash is mandatory and must be a hash.
  -  $options_absent is optional and can be either a single value or an array.
  -  $other_parameters is optional and must be a hash.

  Example:
  $options = {
                'Host *.example.com' => {
                   'ForwardAgent' => 'yes',
                   'BatchMode'    => 'yes',
                },
                'ForwardAgent'           => 'no',
                'BatchMode'              => 'no',
                'StrictHostKeyChecking'  => 'no',
             }
  $options_absent = ['StrictHostKeyChecking','NoneField']
  $other_parameters = { 'target' => '/etc/ssh/ssh_config' }

  $options_final_augeas = sshclient_options_to_augeas_ssh_config($options, $options_absent, $other_parameters)

  In this case, the value of $options_final_augeas would be:

  'ForwardAgent *.example.com' => {
      'ensure'    => 'present',
      'host'      => '*.example.com',
      'key'       => 'ForwardAgent',
      'value'     => 'yes',
      'target'    => '/etc/ssh/ssh_config',
   }
  'BatchMode *.example.com' => {
      'ensure'    => 'present',
      'host'      => '*.example.com',
      'key'       => 'BatchMode',
      'value'     => 'yes',
      'target'    => '/etc/ssh/ssh_config',
   }
  'ForwardAgent' => {
      'ensure'    => 'present',
      'key'       => 'ForwardAgent',
      'value'     => 'yes',
      'target'    => '/etc/ssh/ssh_config',
   }
  'BatchMode' => {
      'ensure'    => 'present',
      'key'       => 'BatchMode',
      'value'     => 'yes',
      'target'    => '/etc/ssh/ssh_config',
   }
  'StrictHostKeyChecking' => {
      'ensure'    => 'absent',
      'key'       => 'StrictHostKeyChecking',
      'target'    => '/etc/ssh/ssh_config',
   }
   'NoneField' => {
      'ensure'    => 'absent',
      'key'       => 'NoneField',
      'target'    => '/etc/ssh/ssh_config',
   }

  Note how the word "Host" is stripped away.

  ENDHEREDOC

    if args.empty?
      raise Puppet::ParseError, 'sshclient_options_to_augeas_ssh_config: expects at least one argument'
    end

    options = args[0]
    unless options.is_a?(Hash)
      raise Puppet::ParseError, 'sshclient_options_to_augeas_ssh_config: first argument must be a hash'
    end

    options_absent = args[1] if args[1]
    other_parameters = args[2] if args[2]
    if options_absent
      unless options_absent.is_a?(Array) || options_absent.is_a?(String)
        raise Puppet::ParseError, 'sshclient_options_to_augeas_ssh_config: second argument, if supplied, must be an array or a string'
      end
    end
    if other_parameters
      unless other_parameters.is_a?(Hash)
        raise Puppet::ParseError, 'sshclient_options_to_augeas_ssh_config: third argument, if supplied, must be a hash'
      end
    end

    options_final_augeas = {}
    options.each do |key1, value1|
      if value1.is_a?(Hash)
        value1.each do |key2, value2|
          v = { 'ensure' => 'present' }.merge('host' => key1.gsub('Host ', '')).merge('key' => key2, 'value' => value2)
          options_final_augeas["#{key2} #{key1.gsub('Host ', '')}"] = v.merge(other_parameters)
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
