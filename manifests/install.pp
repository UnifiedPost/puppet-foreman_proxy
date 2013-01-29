class foreman_proxy::install (
  $repo = $::foreman_proxy::repo
) inherits foreman_proxy {

  if $repo {
    foreman::install::repos { 'foreman_proxy':
      repo   => $repo,
      before => Package['foreman-proxy'],
    }
  }

  package {'foreman-proxy':
    ensure  => present,
  }
}
