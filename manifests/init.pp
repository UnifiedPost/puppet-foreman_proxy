# == Class: foreman_proxy
#
# Installs and configures the foreman smart-proxy.
#
#
# === Parameters:
#
# $repo::                 Use a custom repo. This actually uses
#                         foreman::install::repos and defaults to 'stable'.
#
# $port::                 Port used by the proxy. Defaults to +8443+.
#
# $dir::                  Override the directory where foreman-proxy was
#                         installed to. Defaults to '/usr/share/foreman-proxy'.
#
# $user::                 User to run foreman-proxy as.
#                         Defaults to 'foreman-proxy'.
#
# $log::                  Path to file where foreman-proxy will output his logs
#                         to. Defaults to `/var/log/foreman-proxy/proxy.log`.
#
# $use_sudoersd::         Flag to indicate the sudoers rules should be created
#                         in /etc/sudoers.d/ folder. The default value depends
#                         on the operatingsystem and version in use.
#                         (Currently defaults to +true+ on all operatingsystems
#                         except CentOS 5.)
#
# $puppetca::             Enable Puppet CA management. Defaults to +true+.
#
# $autosign_location::    Location of puppet's autosign.conf file.
#                         Defaults to '/etc/puppet/autosign.conf'.
#
# $puppetca_cmd::         Command to manage puppet ca. Defaults to puppet
#                         version specific.
#
# $puppet_group::         Group puppet is running as. Defaults to '+puppet+'.
#
# $puppetrun::            Enables puppet management. Defaults to '+true+'.
#
# $puppetrun_cmd::        The command that is used for the puppet runs.
#                         Defaults to '/usr/sbin/puppetrun'.
#
# $tftp::                 Enables tftp management. Defaults to '+true+'.
#
# $tftp_syslinux_root::   Defaults to distro specific: ('/usr/lib/syslinux' for
#                         debian flavors, '/usr/share/syslinux' for anything
#                         else).
#
# $tftp_syslinux_files::  Defaults to ['pxelinux.0','menu.c32','chain.c32'].
#
# $tftp_root::            Defaults to the value of tftp::params::root.
#
# $tftp_dirs::            Defaults to 'pxelinux.cfg' and 'boot' in the
#                         'tftp_root' folder.
#
# $tftp_servername::      Defaults to the ipaddress of the '+eth0+' interface.
#
# $dhcp::                 Enable dhcp management. Defaults to '+false+'.
#
# $dhcp_interface::       Interface to enable dhcpd on. Defaults to '+eth0+'.
#
# $dhcp_gateway::         Gateway to use for the pool created by foreman.
#                         Defaults to '192.168.100.1'.
#
# $dhcp_range::           Range to use for the pool.
#                         Defaults to '192.168.100.50 192.168.100.200'.
#
# $dhcp_nameservers::     The nameservers to advertise. If set to 'default',
#                         it will be translated into the ip of the
#                         dhcp_interface that was selected.
#
# $dhcp_vendor::          The vendor of the dhcpd server. Can be either isc or
#                         native_ms. Defaults to isc.
#
# $dhcp_config::          Location of the config file of the dhcp daemon.
#                         Defaults to distro specific.
#
# $dhcp_leases::          Location of the leases file of the dhcp daemon.
#                         Defaults to distro specific.
#
# $dns::                  Enabled dns management. Defaults to '+false+'.
#
# $dns_interface::        Network interfaces to listen on. Used to determine
#                         the IP to bind to. Defaults to '+eth0+'.
#
# $dns_reverse::          Reverse lookup zone.
#                         Defaults to '100.168.192.in-addr.arpa'
#
# $dns_server::           IP of the dns server to manage.
#                         Defaults to '127.0.0.1'.
#
# $dns_forwarders::       DNS forwarders to use.
#                         Defaults to an empty array (no forwarders).
#
# $dns_keyfile::          Location of the rndc keyfile to manage.
#                         Defaults to distro specific.
#
#
# === Requirements:
#
# * Puppet modules:
#   * ::puppet
#   * ::foreman
#
# * Augeas: Only required when +use_sudoersd+ is false.
#
# Depending on what features you have enabled, the following puppet
# modules might be required:
#
# * ::tftp
# * ::dhcp
# * ::dns
#
#
class foreman_proxy (
  $repo                = $foreman_proxy::params::repo,
  $port                = $foreman_proxy::params::port,
  $dir                 = $foreman_proxy::params::dir,
  $user                = $foreman_proxy::params::user,
  $log                 = $foreman_proxy::params::log,
  $use_sudoersd        = $foreman_proxy::params::use_sudoersd,
  $puppetca            = $foreman_proxy::params::puppetca,
  $autosign_location   = $foreman_proxy::params::autosign_location,
  $puppetca_cmd        = $foreman_proxy::params::puppetca_cmd,
  $puppet_group        = $foreman_proxy::params::puppet_group,
  $puppetrun           = $foreman_proxy::params::puppetrun,
  $puppetrun_cmd       = $foreman_proxy::params::puppetrun_cmd,
  $tftp                = $foreman_proxy::params::tftp,
  $tftp_syslinux_root  = $foreman_proxy::params::tftp_syslinux_root,
  $tftp_syslinux_files = $foreman_proxy::params::tftp_syslinux_files,
  $tftp_root           = $foreman_proxy::params::tftp_root,
  $tftp_dirs           = $foreman_proxy::params::tftp_dirs,
  $tftp_servername     = $foreman_proxy::params::tftp_servername,
  $dhcp                = $foreman_proxy::params::dhcp,
  $dhcp_interface      = $foreman_proxy::params::dhcp_interface,
  $dhcp_gateway        = $foreman_proxy::params::dhcp_gateway,
  $dhcp_range          = $foreman_proxy::params::dhcp_range,
  $dhcp_nameservers    = $foreman_proxy::params::dhcp_nameservers,
  $dhcp_vendor         = $foreman_proxy::params::dhcp_vendor,
  $dhcp_config         = $foreman_proxy::params::dhcp_config,
  $dhcp_leases         = $foreman_proxy::params::dhcp_leases,
  $dns                 = $foreman_proxy::params::dns,
  $dns_interface       = $foreman_proxy::params::dns_interface,
  $dns_reverse         = $foreman_proxy::params::dns_reverse,
  $dns_server          = $foreman_proxy::params::dns_server,
  $dns_forwarders      = $foreman_proxy::params::dns_forwarders,
  $dns_keyfile         = $foreman_proxy::params::dns_keyfile,
) inherits foreman_proxy::params {
  class { 'foreman_proxy::install': } ~>
  class { 'foreman_proxy::config': } ~>
  class { 'foreman_proxy::service': }
}
