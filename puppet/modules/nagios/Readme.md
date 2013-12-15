On Nagios server
=================
 * Change the $nagios_machine_type to "server"
 * Run the puppet module nagios and bahmni-nagios
 * Run the below command to set the password
 	 htpasswd -c /etc/nagios/htpasswd.users nagiosadmin
 * Restart httpd

 On Nagios Client
 ================
 * Change the $nagios_machine_type to "client"
 * Run the puppet module nagios and bahmni-nagios