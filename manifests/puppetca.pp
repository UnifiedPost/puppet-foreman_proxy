class foreman_proxy::puppetca (
  $autosign_location = $::foreman_proxy::autosign_location,
  $user              = $::foreman_proxy::user,
  $puppet_group      = $::foreman_proxy::puppet_group
) inherits foreman_proxy {

  file { $autosign_location:
    ensure  => present,
    owner   => $user,
    group   => $puppet_group,
    mode    => '0664',
    require => Class['foreman_proxy::install'],
  }

}
