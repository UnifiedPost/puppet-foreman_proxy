class foreman_proxy::proxydhcp (
  $dhcp_interface   = $::foreman_proxy::config::dhcp_interface,
  $dhcp_nameservers = $::foreman_proxy::config::dhcp_nameservers,
  $dhcp_range       = $::foreman_proxy::config::dhcp_range,
  $dhcp_gateway     = $::foreman_proxy::config::dhcp_gateway
) inherits foreman_proxy::config {

  $ip_temp   = "ipaddress_${dhcp_interface}"
  $ip        = inline_template('<%= scope.lookupvar(ip_temp) %>')

  $net_temp  = "::network_${dhcp_interface}"
  $net       = inline_template('<%= scope.lookupvar(net_temp) %>')

  $mask_temp = "::netmask_${dhcp_interface}"
  $mask      = inline_template('<%= scope.lookupvar(mask_temp) %>')

  if $dhcp_nameservers == 'default' {
    $nameservers = [$ip]
  } else {
    $nameservers = split($dhcp_nameservers,',')
  }

  class { 'dhcp':
    dnsdomain    => [$::domain],
    nameservers  => $nameservers,
    interfaces   => [$dhcp_interface],
    #dnsupdatekey => /etc/bind/keys.d/foreman,
    #require      => Bind::Key[ 'foreman' ],
    pxeserver    => $ip,
    pxefilename  => 'pxelinux.0',
  }

  dhcp::pool{ $::domain:
    network => $net,
    mask    => $mask,
    range   => $dhcp_range,
    gateway => $dhcp_gateway,
  }
}
