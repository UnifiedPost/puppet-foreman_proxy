class foreman_proxy::proxydns (
  $dns_interface  = $::foreman_proxy::dns_interface,
  $dns_forwarders = $::foreman_proxy::dns_forwarders,
  $dns_reverse    = $::foreman_proxy::dns_reverse,
  $dns_nsupdate   = $::foreman_proxy::dns_nsupdate
) inherits foreman_proxy {

  class { 'dns':
    forwarders => $dns_forwarders,
  }

  package { $dns_nsupdate:
    ensure => 'present',
  }

  # This will look up the fact ::ipaddress_<INTERFACE> to determine the ip.
  $ip_temp = "::ipaddress_${dns_interface}"
  $ip      = inline_template('<%= scope.lookupvar(ip_temp) %>')

  dns::zone { $::domain:
    soa     => $::fqdn,
    reverse => false,
    soaip   => $ip,
  }

  dns::zone { $dns_reverse:
    soa     => $::fqdn,
    reverse => true,
    soaip   => $ip,
  }
}
