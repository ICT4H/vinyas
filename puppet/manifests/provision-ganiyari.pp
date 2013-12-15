import "configurations/host-configuration.pp"

node default {
  include yum
  include tools
	include httpd
	include nodejs
}