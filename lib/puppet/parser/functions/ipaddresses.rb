module Puppet::Parser::Functions
  newfunction(:ipaddresses, type: :rvalue, doc: <<-EOS
  Returns all ip addresses of network interfaces (except lo) found by facter.
  Special network interfaces (e.g. docker0) can be excluded by an exclude list as
  first argument for this function.
EOS
             ) do |args|
    networking = lookupvar('networking')

    # always exclude loopback interface
    interfaces_exclude = ['lo']
    if args.size == 1
      unless args[0].is_a?(Array)
        raise(Puppet::ParseError, 'ipaddresses(): Requires first argument to be an Array')
      end
      interfaces_exclude << args[0]
    end

    return false unless networking.include?('interfaces')

    result = []
    networking['interfaces'].each do |iface, data|
      # skip excluded interfaces
      next if interfaces_exclude.include?(iface)

      %w[bindings bindings6].each do |binding_type|
        next unless data.key?(binding_type)
        data[binding_type].each do |binding|
          next unless binding.key?('address')
          result << binding['address']
        end
      end
    end

    # Throw away any v6 link-local addresses
    fe8064 = IPAddr.new('fe80::/64')
    result.delete_if { |ip| fe8064.include? IPAddr.new(ip) }

    return result.uniq
  end
end
