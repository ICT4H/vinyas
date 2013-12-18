$log_file = "/var/log/puppet.log"
$log_expression = ">> ${log_file} 2>> ${log_file}"

file { "${log_file}" :
  ensure      => present,
  owner       => "root",
  group       => "root",
  mode        => 666,
  content     => "",
}