# This class as of now ensures httpd installed and running
# Project specific rules need to be inserted manually into httpd.conf and ssl.conf

class httpd {
    require yum
    $httpd_conf_file = "/etc/httpd/conf/httpd.conf"
    
    package { "httpd" :
        ensure => "present"
    }

    file { "${httpd_conf_file}" :
       content      => template("httpd/httpd.conf.erb", "httpd/httpd.conf.redirects.erb"),
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

	file { "/etc/httpd/conf.d/ssl.conf" :
	   content      => template("httpd/ssl.conf.erb"),
       notify       => Service["httpd"],
	}
}
