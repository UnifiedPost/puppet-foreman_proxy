class foreman_proxy::config inherits foreman_proxy {

  if $foreman_proxy::puppetca  { include foreman_proxy::puppetca }
  if $foreman_proxy::tftp      { include foreman_proxy::tftp }

  # Somehow, calling these DHCP and DNS seems to conflict. So, they get a prefix...
  if $foreman_proxy::dhcp      { include foreman_proxy::proxydhcp }

  if $foreman_proxy::dns {
    include foreman_proxy::proxydns
    include dns::params
    $groups = [$dns::params::group,$foreman_proxy::puppet_group]
  } else {
    $groups = [$foreman_proxy::puppet_group]
  }

  if $foreman_proxy::ssl {
    ## If we are going to use puppet::server. Make sure we have proper dependencies.
    if defined(Class['puppet::server']) and (
      ($foreman_proxy::ssl_cert == undef) or
      ($foreman_proxy::ssl_ca_cert == undef) or
      ($foreman_proxy::ssl_cert_key == undef)
    ) {
      Class['foreman_proxy::service'] {
        require => Class['puppet::server::config'],
      }
    }
    $ssl_certificate = $foreman_proxy::ssl_cert ? {
      undef   => $puppet::server::ssl_cert,
      default => $foreman_proxy::ssl_cert,
    }

    $ssl_ca_file = $foreman_proxy::ssl_ca_cert ? {
      undef   => $puppet::server::ssl_ca_cert,
      default => $foreman_proxy::ssl_ca_cert,
    }

    $ssl_private_key = $foreman_proxy::ssl_cert_key ? {
      undef   => $puppet::server::ssl_cert_key,
      default => $foreman_proxy::ssl_cert_key,
    }

    if ($ssl_certificate == undef)
        or ($ssl_ca_file == undef)
        or ($ssl_private_key == undef) {
      fail ('I need certificates Bro')
    }

  }


  user { $foreman_proxy::user:
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
    owner   => $foreman_proxy::user,
    group   => $foreman_proxy::user,
    mode    => '0644',
    require => Class['foreman_proxy::install'],
    notify  => Class['foreman_proxy::service'],
  }

  if $foreman_proxy::use_sudoersd {
    file { '/etc/sudoers.d/foreman-proxy':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => 0440,
      content => "foreman-proxy ALL = NOPASSWD : ${foreman_proxy::puppetca_cmd} *, ${foreman_proxy::puppetrun_cmd}
Defaults:foreman-proxy !requiretty\n",
    }
  } else {
    augeas { 'sudo-foreman-proxy':
      context => '/files/etc/sudoers',
      changes => [
        "set spec[user = '${foreman_proxy::user}']/user ${foreman_proxy::user}",
        "set spec[user = '${foreman_proxy::user}']/host_group/host ALL",
        "set spec[user = '${foreman_proxy::user}']/host_group/command[1] '${foreman_proxy::puppetca_cmd}'",
        "set spec[user = '${foreman_proxy::user}']/host_group/command[2] '${foreman_proxy::puppetrun_cmd}'",
        "set spec[user = '${foreman_proxy::user}']/host_group/command[1]/tag NOPASSWD",
        "set Defaults[type = ':${foreman_proxy::user}']/type :${foreman_proxy::user}",
        "set Defaults[type = ':${foreman_proxy::user}']/requiretty/negate ''",
      ],
    }
  }

}
