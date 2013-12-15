class nagios {
    require yum-repo
    
    package { "nagios" :
        ensure  =>  "present"
    }

    package { "nagios-plugins-all" :
        ensure  => "present",
        require => Package["nagios"]
    }

    package { "nrpe" :
        ensure  => "present",
        require => Package["nagios-plugins-all"]
    }

    file { "/etc/nagios/nrpe.cfg":
        content     => template("nagios/nrpe.cfg"),
        ensure      => present,
        owner       => "${nagios_user}",
        notify      => Service["nrpe"]
    }

    service { "nrpe":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package["nrpe"]
    }

    package { "nagios-plugins-nrpe" :
        ensure  => "present",
        require => Service["nrpe"]
    }

    package { "mailx" :
        ensure  =>  "present"
    }

    file { "${nagios_plugins_dir}":
        ensure  => directory,
        require => Package["nagios"]
    }

    file { "/usr/lib64/nagios/plugins/":
        source      => "${nagios_plugins_dir}",
        recurse     => true,
        owner       => "${nagios_user}",
        group       => "${nagios_user}",
        mode        =>  555,
        require     => File["${nagios_plugins_dir}"]
    }
}