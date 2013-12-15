class python-packages {
  $download-python-packages-file = "${scripts_dir}/download_python_packages.sh"

  file { "${scripts_dir}" :
    ensure => directory,
    owner   => "root",
  }

  file { "${download-python-packages-file}" :
    ensure      => present,
    content     => template("python-packages/download_python_packages.sh.erb"),
    mode        => 664,
    require     => File["${scripts_dir}"]
  }

  exec { "download_build" :
    command     => "sh ${download-python-packages-file} ${deployment_log_expression}",
    provider  => shell,
    user      => "root",
    require     => File["$download-python-packages-file"],
    cwd       => "${python_package_dir}"
  }
}