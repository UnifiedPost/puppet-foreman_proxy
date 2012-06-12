class foreman_proxy::tftp {

  require foreman_proxy::params

  if $foreman_proxy::params::tftp == false {
    fail ('You included foreman_proxy::tftp but it was not enabled in foreman_proxy::params')
  }
  else {

    include ::tftp
    $tftp_dir       = $foreman_proxy::params::tftp_dir
    $user           = $foreman_proxy::params::user
    $syslinux_files = $foreman_proxy::params::syslinux_files
    $syslinux_root  = $foreman_proxy::params::syslinux_path
    $tftproot       = $foreman_proxy::params::tftproot

    file { $tftp_dir:
      ensure  => 'directory',
      owner   => $user,
      mode    => '0644',
      require => Class['foreman_proxy::install'],
      recurse => true;
    }

    foreman_proxy::tftp::sync_file{ $syslinux_files:
      source_path => $syslinux_root,
      target_path => $tftproot,
      require     => Class['tftp::install'];
    }
  }
}
