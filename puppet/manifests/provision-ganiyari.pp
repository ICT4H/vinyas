import "configurations/host-configuration.pp"
import "configurations/httpd-default-configuration.pp"

node default {
  include yum
  include tools
  include httpd
  include nodejs
}