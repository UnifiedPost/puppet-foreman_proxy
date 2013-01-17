class foreman_proxy::tftp {
  include ::tftp

  ## Lazy set default tftp_root when nothing is defined.
  case $foreman_proxy::tftp_root {
    undef : {
      require ::tftp::params
      $target_path = $::tftp::params::root
    }
    default: {
      $target_path = $foreman_proxy::tftp_root
    }
  }


  file{ $foreman_proxy::tftp_dirs:
    ensure  => directory,
    owner   => $foreman_proxy::user,
    mode    => '0644',
    require => Class['foreman_proxy::install', 'tftp::install'],
    recurse => true;
  }

  foreman_proxy::tftp::sync_file{$foreman_proxy::tftp_syslinux_files:
    source_path => $foreman_proxy::tftp_syslinux_root,
    target_path => $target_path,
    require     => Class['tftp::install'];
  }

  package { 'wget':
    ensure => installed,
  }
}
