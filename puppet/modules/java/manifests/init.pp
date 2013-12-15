class java {
  require yum-repo
  
  if ($install_jdk == "true") {
    $java_home = "/usr/java/jdk1.7.0_21"

    package { "jdk" :
      ensure => installed
    }
    
    file { "jdk_home_path" :
      path    => "/etc/profile.d/java.sh",
      ensure  => present,
      content => template ("java/java.sh"),
      mode    => 664,
      require => Package["jdk"]
    }

  } else {

    $java_home = "/usr/java/default"

    package { "jre" :
      ensure => installed
    }
    
    file { "java_home_path" :
      path    => "/etc/profile.d/java.sh",
      ensure  => present,
      content => template ("java/java.sh"),
      mode    => 664,
      require => Package["jre"]
    }

    file { "${java_home}/lib/tools.jar" :
      source => "${packages_servers_dir}/tools.jar",
      ensure => present,
      require => Package["jre"]
    }

}


}