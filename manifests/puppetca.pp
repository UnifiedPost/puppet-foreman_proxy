class foreman_proxy::puppetca (
  $autosign_location = $::foreman_proxy::config::autosign_location,
  $user              = $::foreman_proxy::config::user,
  $puppet_group      = $::foreman_proxy::config::puppet_group
) inherits foreman_proxy::config {

  file { $autosign_location:
    ensure  => present,
    owner   => $user,
    group   => $puppet_group,
    mode    => '0664',
    require => Class['foreman_proxy::install'],
  }

}
