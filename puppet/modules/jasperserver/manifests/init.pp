class jasperserver ($userName) {

    exec {"get_jasperserver":
        command     => "/usr/bin/wget -O /tmp/jasperreports-server-cp-5.0.0-bin.zip https://dl.dropbox.com/s/1p0jtt1hjfnrkp6/jasperreports-server-cp-5.0.0-bin.zip",
        timeout     => 0,
        provider    => "shell",
        user        => "${jssUser}",
        onlyif      => "test ! -f /tmp/jasperreports-server-cp-5.0.0-bin.zip"
    }

	file { "${jasperHome}":
            ensure      => "directory",
            purge       => true,
            owner       => "${jssUser}",
            group       => "${jssUser}"
    }

    exec { "unzip_jasperserver":
        command     => "unzip /tmp/jasperreports-server-cp-5.0.0-bin.zip && cp -r /tmp/jasperreports-server-cp-5.0.0-bin ./ && rm -rf /tmp/jasperreports-server-cp-5.0.0-bin",
        provider    => "shell",
        require     => [File["${jasperHome}"], Exec["get_jasperserver"]],
    }

    exec {"copy_mysql_jar" :
       command      => "cp /usr/share/java/mysql-connector-java.jar ${jasperHome}/buildomatic/conf_source/db/mysql/jdbc",
       require      => Exec["unzip_jasperserver"]
    }

    exec{ "change_jasperserver_owner" :
            command     => "chown -R ${userName}:${userName} ${jasperHome}",
            require     => Exec["unzip_jasperserver"],
    }

	file { "java_home_path":
        path 		=> "/etc/profile.d/java.sh",
        ensure 		=> "present",
        content 	=> template ("jasperserver/java.sh"),
        mode 		=> '644',
	}

    file { "${jasperHome}/buildomatic/default_master.properties":
        content     => template("jasperserver/default_master.properties.erb"),
        require     => Exec['change_jasperserver_owner'],
        owner       => "${jssUser}",
        group       => "${jssUser}"
    }

    file { "${jasperHome}/buildomatic/bin/do-js-setup.sh":
        content     => template("jasperserver/do-js-setup.sh"),
        require     => Exec['change_jasperserver_owner'],
        owner       => "${jssUser}",
        group       => "${jssUser}"
    }

    exec { "set_jasperserver_scripts_permission":
        command     => "find . -name '*.sh' | xargs chmod u+x",
        user        => "${jssUser}",
        require     => [File["${jasperHome}/buildomatic/bin/do-js-setup.sh"], File["${jasperHome}/buildomatic/default_master.properties"]],
        cwd         => "${jasperHome}"
    }
	
    exec { "set_jasperserver_ant_permission":
        command     => "chmod u+x ${jasperHome}/apache-ant/bin/ant",
        user        => "${jssUser}",
        require     => [File["${jasperHome}/buildomatic/bin/do-js-setup.sh"], File["${jasperHome}/buildomatic/default_master.properties"]],
        cwd         => "${jasperHome}"
    }

    exec { "make_jasperserver":
        command     => "echo '$jasperResetDb' | /bin/sh js-install-ce.sh minimal",
        require     => [Exec["set_jasperserver_scripts_permission"],File["java_home_path"], Exec["copy_mysql_jar"],Exec["set_jasperserver_ant_permission"]],
        cwd         => "${jasperHome}/buildomatic",
        user        => "${jssUser}"
    }

    file { "/tmp/configure_jasper_home.sh" :
         require    => Exec["make_jasperserver"],
         content    => template("jasperserver/configure_jasper_home.sh"),
         owner      => "${jssUser}",
         group      => "${jssUser}",
         mode       =>  764
    }

    exec { "config-jasper-home" :
        require     => File["/tmp/configure_jasper_home.sh"],
        command     => "sh /tmp/configure_jasper_home.sh ${jasperHome} ${jssUser}",
        user        => "${jssUser}"
    }
	
	exec {"restart_tomcat" :
        command     => "/home/${jssUser}/apache-tomcat-7.0.22/bin/shutdown.sh && /home/jss/apache-tomcat-7.0.22/bin/startup.sh",
        user        => "${jssUser}",
        require		=> Exec["make_jasperserver"],
	}
}
