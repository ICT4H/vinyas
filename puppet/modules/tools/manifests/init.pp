class tools {
	require yum

	package {"unzip" : ensure => "installed"}
	package {"zip" : ensure => "installed"}
	package {"wget" : ensure => "installed"}
	package {"screen" : ensure => "installed"}
}