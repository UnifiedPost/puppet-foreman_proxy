class foreman_proxy::params (
  $dir               = '/usr/share/foreman-proxy',
  $user              = 'foreman-proxy',
  $log               = '/var/log/foreman-proxy/proxy.log',
  $puppetca          = true,
  $autosign_location = '/etc/puppet/autosign.conf',
  $puppetca_cmd      = '/usr/sbin/puppet cert',
  $puppet_group      = 'puppet',
  $puppetrun         = true,
  $puppetrun_cmd     = '/usr/sbin/puppetrun',
  $tftp              = true,
  $syslinux_root     = undef,
  $syslinux_files    = ['pxelinux.0', 'menu.c32', 'chain.c32'],
  $servername        = $ipaddress_eth0,
  $port              = 8443,
  $dhcp              = false,
  $gateway           = '192.168.100.1',
  $range             = '192.168.100.50 192.168.100.200',
  $dhcp_vendor       = undef,
  $dhcp_config       = undef,
  $dhcp_leases       = undef,
  $dns               = false,
  $keyfile           = undef,
  $puppetssldir      = '/var/lib/puppet-server/ssl'
) {

  if $tftp {
  # TFTP settings - requires optional TFTP puppet module
    require tftp::params
    $tftproot       = $tftp::params::root
    $tftp_dir       = ["${tftproot}/pxelinux.cfg","${tftproot}/boot"]
  }

  $syslinux_path = $syslinux_root ? {
    undef   => $::operatingsystem ? {
      /(?i:debian|ubuntu)/ => '/usr/lib/syslinux',
      default              => '/usr/share/syslinux',
    },
    default => $syslinux_root,
  }

  # DHCP settings - requires optional DHCP puppet module
  $dhcpvendor = $dhcp_vendor ? {
    undef   => $::operatingsystem ? {
      /(?i:debian)/ => 'isc',
      /(?i:ubuntu)/ => 'isc',
      default       => 'isc',
    },
    default => $dhcp_vendor,
  }

  $dhcpconfig = $dhcp_config ? {
    undef   => $::operatingsystem ? {
      /(?i:debian)/ => '/etc/dhcp/dhcpd.conf',
      /(?i:ubuntu)/ => '/etc/dhcp3/dhcpd.conf',
      default       => '/etc/dhcpd.conf',
    },
    default => $dhcp_config,
  }

  $dhcpleases= $dhcp_leases ? {
    undef   => $::operatingsystem ? {
      /(?i:debian)/ => '/var/lib/dhcp/dhcpd.leases',
      /(?i:ubuntu)/ => '/var/lib/dhcp3/dhcpd.leases',
      default       => '/var/lib/dhcpd/dhcpd.leases',
    },
    default => $dhcp_leases,
  }


  # DNS settings - requires optional DNS puppet module
  $dnskeyfile = $keyfile ? {
    undef   => $::operatingsystem ? {
      /(?i:debian)/ => '/etc/bind/rndc.key',
      default       => '/etc/rndc.key',
    },
    default => $keyfile,
  }

}
