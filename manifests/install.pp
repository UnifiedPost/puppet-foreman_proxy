class foreman_proxy::install {
  require foreman::params
  package {'foreman-proxy':
    ensure  => present,
  }
}
