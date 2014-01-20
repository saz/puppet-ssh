class ssh (
  $disable_user_known_hosts = true
) {
  include ssh::server
  include ssh::client
}
