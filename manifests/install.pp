class foreman_proxy::install {
  if $foreman_proxy::repo {
    foreman::install::repos { 'foreman_proxy':
      repo   => $foreman_proxy::repo,
      before => Package['foreman-proxy'],
    }
  }

  package {'foreman-proxy':
    ensure  => present,
  }
}
