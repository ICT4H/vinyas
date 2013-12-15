class openelis {
  require ant

  $openelis_webapp_location =  "${tomcatInstallationDirectory}/webapps/openelis"
  $bahmni_openelis_temp_dir = "${temp_dir}/OpenElis"
  $log4j_xml_file = "${tomcatInstallationDirectory}/webapps/${openelis_war_file_name}/WEB-INF/classes/log4j.xml"

  exec { "latest_openelis_webapp" :
    command   => "rm -rf ${openelis_webapp_location} && unzip -o -q ${build_output_dir}/${openelis_war_file_name}.war -d ${openelis_webapp_location} ${deployment_log_expression}",
    provider  => shell,
    path      => "${os_path}",
    require   => [File["${deployment_log_file}"]],
    user      => "${bahmni_user}",
  }

  exec { "bahmni_openelis_codebase" :
    provider => "shell",
    command   => "rm -rf ${bahmni_openelis_temp_dir} && unzip -o -q ${build_output_dir}/OpenElis.zip -d ${temp_dir} ${deployment_log_expression}",
    path => "${os_path}"
  }

  exec { "openelis_setupdb" :
    provider => "shell",
    cwd => "${bahmni_openelis_temp_dir}",
    command => "ant setupDB",
    path => "${os_path}:${ant_home}/bin",
    require => Exec["bahmni_openelis_codebase"]
  }  

  file { "${log4j_xml_file}" :
    ensure      => present,
    content     => template("openelis/log4j.xml.erb"),
    owner       => "${bahmni_user}",
    group       => "${bahmni_user}",
    require     => Exec["latest_openelis_webapp"],
    mode        => 664,
  }

  file { "${uploadedFilesDirectory}" :
    ensure => directory,
    mode => 774,
    owner => "${bahmni_user}",
    group => "${bahmni_user}",
  }

  file { "${uploadedFilesDirectory}/elis" :
    ensure => directory,
    mode => 774,
    owner => "${bahmni_user}",
    group => "${bahmni_user}",
    require => File["${uploadedFilesDirectory}"],
  }

## tomcat file change
  ##<Context path="/uploaded-files" docBase="/home/jss/uploaded-files"/>
  
}