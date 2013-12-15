# This class as of now ensures httpd installed and running
# Project specific rules need to be inserted manually into httpd.conf and ssl.conf

class httpd {
    require yum
    
    package { "httpd" :
        ensure => "present"
    }

    exec { "httpd_conf_backup" :
        cwd         => "/etc/httpd/conf",
        command     => "mv httpd.conf httpd.conf.bkup",
        path        => "${os_path}",
        require     => Package["httpd"],
    }

    file { "/etc/httpd/conf/httpd.conf" :
       content      => template("httpd/httpd.conf.erb", "httpd/httpd.conf.redirects.erb"),
       require      => Exec["httpd_conf_backup"],
       notify       => Service["httpd"],
    }

    service { "httpd" :
        ensure      => running,
        enable      => true,
        require     => Package["httpd"]
    }

	package { "mod_ssl" :
	    ensure      => present,
	    require     => File["/etc/httpd/conf/httpd.conf"],
	}

	exec { "ssl_conf_backup" :
	    cwd         => "/etc/httpd/conf.d",
	    command     => "mv ssl.conf ssl.conf.bkup",
        path        => "${os_path}",
	    require     => Package["mod_ssl"],
	}

	file { "/etc/httpd/conf.d/ssl.conf" :
	   content      => template("httpd/ssl.conf.erb"),
	   require      => Exec["ssl_conf_backup"],
       notify       => Service["httpd"],
	}
}
