class tomcat {
  require host
  require java

  exec { "tomcat_untar" :
    command   => "tar -zxf ${packages_servers_dir}/apache-tomcat-${tomcat_version}.tar.gz ${deployment_log_expression} -C ${tomcatParentDirectory}",
    user      => "${bahmni_user}",
    creates   => "${tomcatInstallationDirectory}",
    provider  => shell
  }

  file { "CATALINA_OPTS" :
    path    => "${tomcatInstallationDirectory}/bin/setenv.sh",
    ensure  => present,
    content => template ("tomcat/setenv.sh"),
    owner   => "${bahmni_user}",
    mode    => 664,
    require => Exec["tomcat_untar"]
  }

  file { "/etc/init.d/tomcat" :
      ensure      => present,
      content     => template("tomcat/tomcat.initd.erb"),
      mode        => 777,
      group       => "root",
      owner       => "root",
      require     => Exec["tomcat_untar"],
  }

  file { "${tomcatInstallationDirectory}/conf/server.xml" :
    ensure    => present,
    content   => template("tomcat/server.xml.erb"),
    owner     => "${bahmni_user}",
    replace   => true,
    mode      => 664,
    require   => Exec["tomcat_untar"]
  }

  file { "${tomcatInstallationDirectory}/conf/web.xml" :
    ensure      => present,
    content     => template("tomcat/web.xml.erb"),
    group       => "${bahmni_user}",
    owner       => "${bahmni_user}",
    replace     => true,
    require     => Exec["tomcat_untar"],
  }

  file { "${tomcatInstallationDirectory}/conf/tomcat-users.xml" :
    ensure    => present,
    content   => template("tomcat/tomcat-users.xml.erb"),
    owner     => "${bahmni_user}",
    mode      => 664,
    require   => Exec["tomcat_untar"]
  }

  # Mujir - recursively doing this through file resource eats up time. Hence the exec below.
  file { "${tomcatInstallationDirectory}" :
    ensure => directory,
    mode   => 776,
    owner  => "${bahmni_user}",
    group  => "${bahmni_user}",
    require => Exec["tomcat_untar"]
  }
  exec { "change_group_rights_for_tomcatInstallationDirectory" :
    provider => "shell",
    command => "chown -R ${bahmni_user}:${bahmni_user} ${tomcatInstallationDirectory}; chmod -R 776 ${tomcatInstallationDirectory}; ",
    path => "${os_path}",
    require => File["${tomcatInstallationDirectory}"],
  }

  service { "tomcat":
    enable    => true,
    ensure => running,
    require   => File["${tomcatInstallationDirectory}"],
  }  
}