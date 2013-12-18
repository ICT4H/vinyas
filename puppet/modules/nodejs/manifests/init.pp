class nodejs {
  require yum
  $nodejs_version = "v0.10.4"

  $nodejs_install_script = "/tmp/installnodejs.sh"

  exec { "DevelopmentTools" :
    command => 'yum -y groupinstall "Development Tools" ${log_expression}',
    provider => "shell"
  }

  file { "${nodejs_install_script}" :
    ensure      => present,
    content     => template("nodejs/installnodejs.sh.erb"),
    mode        =>  544,
    owner       => "root",
    require => Exec["DevelopmentTools"]
  }

  exec { "install-nodejs" :
    command => "${nodejs_install_script} ${log_expression}",
    provider => "shell",
    cwd => "/usr/src/",
    require => File["${nodejs_install_script}"]
  }

  exec { "download-nodejs" :
    command => "wget -nc http://nodejs.org/dist/${nodejs_version}/node-${nodejs_version}.tar.gz ${log_expression}",
    provider => "shell",
    cwd => "/usr/src/",
  }
}