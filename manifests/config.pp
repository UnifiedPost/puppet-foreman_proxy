# == Class: foreman_proxy::config
#
# Configures foreman_proxy and calls serveral subclasses to configure
# certain services this proxy manages.
#
# === Parameters:
#
# See ::foreman_proxy for a description of the parameters
#
#
class foreman_proxy::config (
  $port                = $::foreman_proxy::port,
  $dir                 = $::foreman_proxy::dir,
  $user                = $::foreman_proxy::user,
  $log                 = $::foreman_proxy::log,

  $ssl                 = $::foreman_proxy::ssl,
  $ssl_cert            = $::foreman_proxy::ssl_cert,
  $ssl_ca_cert         = $::foreman_proxy::ssl_ca_cert,
  $ssl_cert_key        = $::foreman_proxy::ssl_cert_key,
  $ssl_dir             = $::foreman_proxy::ssl_dir,
  $trusted_hosts       = $::foreman_proxy::trusted_hosts,

  $use_sudoersd        = $::foreman_proxy::use_sudoersd,
  $puppetca            = $::foreman_proxy::puppetca,
  $puppetca_cmd        = $::foreman_proxy::puppetca_cmd,
  $puppet_group        = $::foreman_proxy::puppet_group,
  $puppetrun           = $::foreman_proxy::puppetrun,
  $puppetrun_cmd       = $::foreman_proxy::puppetrun_cmd,
  $autosign_location   = $::foreman_proxy::autosign_location,

  $tftp                = $::foreman_proxy::tftp,
  $tftp_syslinux_root  = $::foreman_proxy::tftp_syslinux_root,
  $tftp_syslinux_files = $::foreman_proxy::tftp_syslinux_files,
  $tftp_root           = $::foreman_proxy::tftp_root,
  $tftp_dirs           = $::foreman_proxy::tftp_dirs,
  $tftp_servername     = $::foreman_proxy::tftp_servername,

  $dhcp                = $::foreman_proxy::dhcpd,
  $dhcp_interface      = $::foreman_proxy::dhcp_interface,
  $dhcp_gateway        = $::foreman_proxy::dhcp_gateway,
  $dhcp_range          = $::foreman_proxy::dhcp_range,
  $dhcp_nameservers    = $::foreman_proxy::dhcp_nameservers,
  $dhcp_vendor         = $::foreman_proxy::dhcp_vendor,
  $dhcp_config         = $::foreman_proxy::dhcp_config,
  $dhcp_leases         = $::foreman_proxy::dhcp_leases,

  $dns                 = $::foreman_proxy::dns,
  $dns_interface       = $::foreman_proxy::dns_interface,
  $dns_reverse         = $::foreman_proxy::dns_reverse,
  $dns_server          = $::foreman_proxy::dns_server,
  $dns_forwarders      = $::foreman_proxy::dns_forwarders,
  $dns_keyfile         = $::foreman_proxy::dns_keyfile,
  $dns_nsupdate        = $::foreman_proxy::dns_nsupdate
) inherits foreman_proxy {

  if $puppetca  { include ::foreman_proxy::puppetca }
  if $tftp      { include ::foreman_proxy::tftp }

  # Somehow, calling these DHCP and DNS seems to conflict. So, they get a prefix...
  if $dhcp      { include ::foreman_proxy::proxydhcp }

  if $dns {
    include ::foreman_proxy::proxydns
    require ::dns::params
    $groups = [$::dns::params::group,$puppet_group]
  } else {
    $groups = [$puppet_group]
  }

  if $ssl {
    ## If we are going to use puppet::server. Make sure we have proper dependencies.
    if defined(Class['::puppet::server']) and (
      ($ssl_cert == undef) or
      ($ssl_ca_cert == undef) or
      ($ssl_cert_key == undef) or
      ($ssl_dir == undef)
    ) {
      Class['::foreman_proxy::service'] {
        require => Class['::puppet::server::config'],
      }
    }
    $ssl_certificate = $ssl_cert ? {
      undef   => $::puppet::server::ssl_cert,
      default => $ssl_cert,
    }

    $ssl_ca_file = $ssl_ca_cert ? {
      undef   => $::puppet::server::ssl_ca_cert,
      default => $ssl_ca_cert,
    }

    $ssl_private_key = $ssl_cert_key ? {
      undef   => $::puppet::server::ssl_cert_key,
      default => $ssl_cert_key,
    }

    $ssl_dir = $ssl_dir ? {
      undef   => $::puppet::server::ssl_dir,
      default => $ssl_dir,
    }

    if ($ssl_certificate == undef)
        or ($ssl_ca_file == undef)
        or ($ssl_private_key == undef) {
      fail ('SSL is enabled but certain ssl parameters are undefined and could not get defaults from puppet::server')
    }

  }


  user { $user:
    ensure  => 'present',
    shell   => '/sbin/nologin',
    comment => 'Foreman Proxy account',
    groups  => $groups,
    home    => $foreman_proxy::dir,
    require => Class['foreman_proxy::install'],
    notify  => Class['foreman_proxy::service'],
  }

  file{'/etc/foreman-proxy/settings.yml':
    content => template('foreman_proxy/settings.yml.erb'),
    owner   => $user,
    group   => $user,
    mode    => '0644',
    require => Class['foreman_proxy::install'],
    notify  => Class['foreman_proxy::service'],
  }

  if $use_sudoersd {
    file { '/etc/sudoers.d/foreman-proxy':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0440,
      content => "foreman-proxy ALL = NOPASSWD : ${puppetca_cmd} *, ${puppetrun_cmd}
Defaults:foreman-proxy !requiretty\n",
    }
  } else {
    augeas { 'sudo-foreman-proxy':
      context => '/files/etc/sudoers',
      changes => [
        "set spec[user = '${user}']/user ${user}",
        "set spec[user = '${user}']/host_group/host ALL",
        "set spec[user = '${user}']/host_group/command[1] '${puppetca_cmd}'",
        "set spec[user = '${user}']/host_group/command[2] '${puppetrun_cmd}'",
        "set spec[user = '${user}']/host_group/command[1]/tag NOPASSWD",
        "set Defaults[type = ':${user}']/type :${user}",
        "set Defaults[type = ':${user}']/requiretty/negate ''",
      ],
    }
  }

}
