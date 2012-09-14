class postgres ( $postgresUser, $postgresPassword, $postgresMachine, $postgresMaster, $postgresSlave, $os, $wordsize) {

    $allPacks = [ "postgresql91", "postgresql91-server", "postgresql91-libs", "postgresql91-contrib", "postgresql91-devel"]

    file{"/tmp/postgres-repo.rpm" :
        ensure      => present,
        source      => "puppet:///modules/postgres/pgdg-${os}-9.1-4-${wordsize}.noarch.rpm",
    }

    exec { "run_postgres_repo" :
        provider    => "shell",
        command     => "rpm -i /tmp/postgres-repo.rpm",
        creates     => "/etc/yum.repos.d/pgdg-91-centos.repo",
        require     => File["/tmp/postgres-repo.rpm"],
        onlyif      => "test `rpm -qa postgres | wc -l` -eq 0",
    }

    package { "postgres_packs" :
        name        => $allPacks,
        ensure      => "present",
        require     => Exec["run_postgres_repo"],
    }

    user { "${postgresUser}" :
        ensure      => present,
        shell       => "/bin/bash",
        home        => "/home/$postgresUser",
        password    => $postgresPassword,
        require     => Exec["run_postgres_repo"],
    }

    file { "/var/lib/pgsql/9.1/" :
        ensure      => "directory",
        owner       => "${postgresUser}",
    }

    file { "/var/lib/pgsql/9.1/data":
        ensure      => "directory",
        require     => File["/var/lib/pgsql/9.1/"],
        owner       => "${postgresUser}",
    }

    exec { "initdb":
        command     => "/usr/pgsql-9.1/bin/initdb -D /var/lib/pgsql/9.1/data",
        user        => "${postgresUser}",
        require     => [File["/var/lib/pgsql/9.1/data"], Package["postgres_packs"]],
        provider    => "shell",
        onlyif      => "test ! -f /var/lib/pgsql/9.1/data/PG_VERSION",
    }

    exec { "start-server":
        command     => "/usr/pgsql-9.1/bin/postgres -D /var/lib/pgsql/9.1/data &",
        user        => "${postgresUser}",
        require     => Exec["initdb"],
    }

    file { "/etc/init.d/postgresql":
        ensure      => "link",
        target      => "/etc/init.d/postgresql-9.1",
    }

    exec{"backup_conf":
                cwd         => "/var/lib/pgsql/9.1/data/",
                command     => "mv postgresql.conf postgresql.conf.backup && mv pg_hba.conf pg_hba.conf.backup",
                user        => "${postgresUser}",
                require     => Exec["start-server"],
            }

    file {"/var/lib/pgsql/9.1/data/pg_hba.conf":
                content     => template("postgres/pg_hba.erb"),
                owner       => "${postgresUser}",
                group       => "${postgresUser}",
                mode        => 600,
                require     => Exec["backup_conf"],
            }

    case $postgresMachine {

        master:{
            file {"/var/lib/pgsql/9.1/data/postgresql.conf":
                content     => template("postgres/master_postgresql.erb"),
                owner       => "${postgresUser}",
                group       => "${postgresUser}",
                mode        => 600,
                require     => Exec["backup_conf"],
            }
        }

        slave:{

            file {"/var/lib/pgsql/9.1/data/postgresql.conf":
                content     => template("postgres/slave_postgresql.erb"),
                owner       => "${postgresUser}",
                group       => "${postgresUser}",
                mode        => 600,
                require     => Exec["backup_conf"],
            }
            
            file {"/var/lib/pgsql/9.1/data/recovery.conf":
                content     => template("postgres/slave_recovery.erb"),
                owner       => "${postgresUser}",
                group       => "${postgresUser}",
                mode        => 600,
            }
        }
    }
}
