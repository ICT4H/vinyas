class mysql-common {
	package { "MySQL-shared-compat" :
		ensure  => present
	}

	package { "MySQL-shared" :
		ensure  => present
	}	
}

class mysql {
	#require yum-repo
	require mysql-common

	package { "MySQL-client" :
		ensure  => present
	}
}

class mysqlserver {
	#require yum-repo
	require mysql-common
	
	package { "MySQL-server" :
		ensure  => present
	}
	
	file { "/etc/my.cnf" :
		ensure      => present,
		content     => template("mysql/my.cnf"),
		require     => Package["MySQL-server"],
	}
	
	file { "/tmp/changepassword.sql" :
		ensure      => present,
		content     => template("mysql/changepassword.sql.erb"),
	}

	file { "/root/initdb.sh" :
		ensure      => present,
		content     => template("mysql/initdb.sh.erb"),
	}

	service { "mysql" :
		ensure => running,
		enable => true,
		require => File["/etc/my.cnf"],
	}

	notice('sh /root/initdb.sh ${mysqlRootPassword} ${deployment_log_expression}')

	exec {"changepassword" : 
		command		=> "sh /root/initdb.sh ${mysqlRootPassword} ${deployment_log_expression}",
	    provider  	=> shell,
    	user      	=> "root",
    	require 	=> [File["/tmp/changepassword.sql"], File["/root/initdb.sh"], Service["mysql"]],
	}
}