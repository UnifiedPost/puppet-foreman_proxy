class foreman_proxy::config (
  $puppetca      = $::foreman_proxy::puppetca,
  $tftp          = $::foreman_proxy::tftp,
  $dhcp          = $::foreman_proxy::dhcpd,
  $dns           = $::foreman_proxy::dns,
  $ssl           = $::foreman_proxy::ssl,
  $ssl_cert      = $::foreman_proxy::ssl_cert,
  $ssl_ca_cert   = $::foreman_proxy::ssl_ca_cert,
  $ssl_cert_key  = $::foreman_proxy::ssl_cert_key,
  $ssl_dir       = $::foreman_proxy::ssl_dir,
  $user          = $::foreman_proxy::user,
  $dir           = $::foreman_proxy::dir,
  $use_sudoersd  = $::foreman_proxy::use_sudoersd,
  $puppetca_cmd  = $::foreman_proxy::puppetca_cmd,
  $puppetrun_cmd = $::foreman_proxy::puppetrun_cmd,
) inherits foreman_proxy {

  if $puppetca  { include ::foreman_proxy::puppetca }
  if $tftp      { include ::foreman_proxy::tftp }

  # Somehow, calling these DHCP and DNS seems to conflict. So, they get a prefix...
  if $dhcp      { include ::foreman_proxy::proxydhcp }

  if $dns {
    include ::foreman_proxy::proxydns
    include ::dns::params
    $groups = [$::dns::params::group,$::foreman_proxy::puppet_group]
  } else {
    $groups = [$::foreman_proxy::puppet_group]
  }

  if $ssl {
    ## If we are going to use puppet::server. Make sure we have proper dependencies.
    if defined(Class['::puppet::server']) and (
      ($ssl_cert == undef) or
      ($ssl_ca_cert == undef) or
      ($ssl_cert_key == undef)
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
