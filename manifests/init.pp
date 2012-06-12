class foreman_proxy {

  include foreman_proxy::install
  include foreman_proxy::config
  include foreman_proxy::service
}
