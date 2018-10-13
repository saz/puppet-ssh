module Puppet::Parser::Functions
  newfunction(:ipaddresses, type: :rvalue, doc: <<-EOS
  Returns all ip addresses of network interfaces (except lo) found by facter.
EOS
             ) do |_args|
    interfaces = lookupvar('interfaces')

    # In Puppet v2.7, lookupvar returns :undefined if the variable does
    # not exist.  In Puppet 3.x, it returns nil.
    # See http://docs.puppetlabs.com/guides/custom_functions.html
    return false if interfaces.nil? || interfaces == :undefined

    result = []
    if interfaces.count(',') > 0
      interfaces = interfaces.split(',')
      interfaces.each do |iface|
        next if iface.include?('lo')
        next if iface.include?('docker')
        next if iface.include?('veth')
        ipaddr = lookupvar("ipaddress_#{iface}")
        ipaddr6 = lookupvar("ipaddress6_#{iface}")
        result << ipaddr if ipaddr && (ipaddr != :undefined)
        result << ipaddr6 if ipaddr6 && (ipaddr6 != :undefined)
      end
    else
      unless interfaces.include?('lo') || interfaces.include?('docker') || interfaces.include?('veth')
        ipaddr = lookupvar("ipaddress_#{interfaces}")
        ipaddr6 = lookupvar("ipaddress6_#{interfaces}")
        result << ipaddr if ipaddr && (ipaddr != :undefined)
        result << ipaddr6 if ipaddr6 && (ipaddr6 != :undefined)
      end
    end

    # Throw away any v6 link-local addresses
    fe8064 = IPAddr.new('fe80::/64')
    result.delete_if { |ip| fe8064.include? IPAddr.new(ip) }

    return result
  end
end
