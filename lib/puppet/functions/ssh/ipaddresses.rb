# @summary Returns ip addresses of network interfaces (except lo) found by facter.
# @api private
#
# Returns all ip addresses of network interfaces (except lo) found by facter.
# Special network interfaces (e.g. docker0) can be excluded by an exclude list.
Puppet::Functions.create_function(:'ssh::ipaddresses') do
  dispatch :ipaddresses do
    # @param excluded_interfaces An array of interface names to be excluded.
    # @return The IP addresses found.
    optional_param 'Array[Variant[Regexp, String[1]]]', :excluded_interfaces
    return_type 'Array[Stdlib::IP::Address]'
  end

  def ipaddresses(excluded_interfaces = [])
    facts = closure_scope['facts']

    (excluded_interfaces_str, excluded_interfaces_re) = excluded_interfaces.partition do |iface|
      iface.is_a? String
    end

    # always exclude loopback interface
    excluded_interfaces_str += ['lo']
    excluded_interfaces_str.uniq

    result = []
    facts['networking']['interfaces'].each do |iface, data|
      # skip excluded interfaces
      next if excluded_interfaces_str.include?(iface)
      next if excluded_interfaces_re.find do |iface_re|
        iface_re.match(iface)
      end

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

    result.uniq.sort
  end
end
