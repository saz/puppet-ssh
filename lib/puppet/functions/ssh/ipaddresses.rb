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

    if !facts['networking'].nil? && !facts['networking'].empty?
      interfaces = facts['networking']['interfaces']
    else
      interfaces = {}
      facts['interfaces'].split(',').each do |iface|
        next if facts["ipaddress_#{iface}"].nil? && facts["ipaddress6_#{iface}"].nil?
        interfaces[iface] = {}
        if !facts["ipaddress_#{iface}"].nil? && !facts["ipaddress_#{iface}"].empty?
          interfaces[iface]['bindings'] = [{ 'address' => facts["ipaddress_#{iface}"] }]
        end
        if !facts["ipaddress6_#{iface}"].nil? && !facts["ipaddress6_#{iface}"].empty?
          interfaces[iface]['bindings6'] = [{ 'address' => facts["ipaddress6_#{iface}"] }]
        end
      end
    end

    result = []
    interfaces.each do |iface, data|
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
