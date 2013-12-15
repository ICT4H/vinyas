class host {
	$host_log_file = "${logs_dir}/bahmni_host.log"
	$host_log_expression = ">> ${host_log_file} 2>> ${host_log_file}"

  require yum-repo

  file { "${temp_dir}" :
    ensure    => directory,
    recurse   => true,
    force     => true,
    purge     => true,
    mode      => 777,
  }

	file { "${temp_dir}/logs" :
		ensure 		=> directory,
    mode      => 777,
    require		=> File["${temp_dir}"]
	}

	file { "${package_dir}" :
		ensure 		=> directory,
		mode      => 777,
		recurse   => true
	}

	class { "timezone" :
    timezone => "Asia/Kolkata"
  }

  package { "ntp" :
  	ensure => installed
  }

  exec { "ntp_service" :
  	command => "chkconfig ntpd on ${host_log_expression}",
  	path 		=> "${os_path}",
  	require	=> [Package["ntp"], File["${temp_dir}/logs"]]
  }

  exec { "time_clock_synchronized" :
  	command => "ntpdate -u pool.ntp.org ${host_log_expression}",
  	path 		=> "${os_path}",
  	require	=> [Exec["ntp_service"], File["${temp_dir}/logs"]]
  }

  service { "ntpd" :
  	ensure => running,
  	require => Exec["time_clock_synchronized"]
  }

  exec { "selinux_disabled_from_enforcing" :
    command => "sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config",
    path    => "${os_path}"
  }

  exec { "selinux_disabled_from_permissive" :
  	command => "sed -i 's/SELINUX=permissive/SELINUX=disabled/g' /etc/selinux/config",
  	path 		=> "${os_path}"
  }
}