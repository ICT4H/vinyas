class yum {
  package { "yum" :
    ensure => present;
  }

  exec { "yum-uptodate" :
    command  => "yum -y update",
    provider => "shell",
    require => Exec["yum"]
  }
}