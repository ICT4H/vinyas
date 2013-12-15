class nodejs {
  require yum

  nodejs-install-script = "/tmp/installnodejs.sh"

  exec { "DevelopmentTools" :
    command => 'yum -y groupinstall "Development Tools" ${log_expression}',
    provider => "shell"
  }

  file { "${nodejs-install-script}" :
    ensure      => present,
    content     => template("nodejs/installnodejs.sh.erb"),
    mode        =>  544,
    owner       => "root",
    require => File["DevelopmentTools"]
  }

  exec { "install-nodejs" :
    command => "${nodejs-install-script}",
    provider => "shell"
    cwd => "/usr/src/",
    require => File["${nodejs-install-script}"]
  }
}