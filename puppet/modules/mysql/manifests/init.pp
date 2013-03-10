class mysql {
	package { "mysql" :
		ensure  =>  "present"
	}
}

class mysqlserver {
	package { "mysql-server" :
		ensure  =>  "present"
	}
	service { "mysqld" :
		ensure => running,
		enable => true,
		require => Package["mysql-server"]
	}
 	exec {"setmysqlpassword":
		command => "mysqladmin -u root PASSWORD ${mysqlRootPassword}; /bin/true",
		require => [Package["mysql-server"], Package["mysql"] , Service["mysqld"]],
	}
	
	package { "mysql-connector-java" :
		ensure  =>  "present",	
	}
}