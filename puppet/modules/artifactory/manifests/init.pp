class artifactory {
    require yum-repo

    package { "artifactory":
        ensure => present
    }

    service { "artifactory":
        ensure     => running,
        enable     => true,
        hasrestart => true,
        hasstatus  => true,
        require    => Package["artifactory"]
    }
}