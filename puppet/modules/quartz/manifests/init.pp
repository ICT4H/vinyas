
class quartz {
	exec { "createdbmotechquartz" :
		command => "mysql -u root -p${mysqlPassword} -e \"create database if not exists quartz;\"",
		require => [Package["mysql-server"], Package["mysql"]]
	}
	
}
