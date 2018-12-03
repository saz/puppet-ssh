module Puppet::Parser::Functions
  newfunction(:ipaddresses, type: :rvalue, doc: <<-EOS
  Returns all ip addresses of network interfaces (except lo) found by facter.
  Special network interfaces (e.g. docker0) can be excluded by an exclude list as
  first argument for this function.
EOS
             ) do |args|
    interfaces = lookupvar('interfaces')

    if args.size == 1
      unless args[0].is_a?(Array)
        raise(Puppet::ParseError, 'ipaddresses(): Requires first argument to be a Array')
      end
      interfaces_exclude = args[0]
    else
      interfaces_exclude = []
    end

    # In Puppet v2.7, lookupvar returns :undefined if the variable does
    # not exist.  In Puppet 3.x, it returns nil.
    # See http://docs.puppetlabs.com/guides/custom_functions.html
    return false if interfaces.nil? || interfaces == :undefined

    result = []
    if interfaces.count(',') > 0
      interfaces = interfaces.split(',')
      interfaces.each do |iface|
        next if iface.include?('lo')
        skip_iface = false
        interfaces_exclude.each do |iface_exclude|
          skip_iface = true if iface.include?(iface_exclude)
        end
        next if skip_iface == true
        ipaddr = lookupvar("ipaddress_#{iface}") rescue nil
        ipaddr6 = lookupvar("ipaddress6_#{iface}") rescue nil
        result << ipaddr if ipaddr && (ipaddr != :undefined)
        result << ipaddr6 if ipaddr6 && (ipaddr6 != :undefined)
      end
    else
      unless interfaces.include?('lo')
        ipaddr = lookupvar("ipaddress_#{interfaces}") rescue nil
        ipaddr6 = lookupvar("ipaddress6_#{interfaces}") rescue nil
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
