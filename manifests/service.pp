class foreman_proxy::service {

  service { 'foreman-proxy':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Class['foreman_proxy::config'],
  }

}
