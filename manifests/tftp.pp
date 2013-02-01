class foreman_proxy::tftp (
  $tftp_root           = $::foreman_proxy::config::tftp_root,
  $tftp_dirs           = $::foreman_proxy::config::tftp_dirs,
  $tftp_syslinux_files = $::foreman_proxy::config::tftp_syslinux_files,
  $tftp_syslinux_root  = $::foreman_proxy::config::tftp_syslinux_root,
  $user                = $::foreman_proxy::config::user,
) inherits foreman_proxy::config {
  require ::tftp

  ## Lazy set default tftp_root when nothing is defined.
  case $tftp_root {
    undef : {
      require ::tftp::params
      $target_path = $::tftp::params::root
    }
    default: {
      $target_path = $tftp_root
    }
  }


  file{ $tftp_dirs:
    ensure  => directory,
    owner   => $user,
    mode    => '0644',
    require => Class['foreman_proxy::install', 'tftp::install'],
    recurse => true;
  }

  foreman_proxy::tftp::sync_file{$tftp_syslinux_files:
    source_path => $tftp_syslinux_root,
    target_path => $target_path,
    require     => Class['tftp::install'];
  }

  if ! defined(Package['wget']) {
    package { 'wget':
      ensure => installed,
    }
  }
}
