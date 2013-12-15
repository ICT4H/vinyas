curl --form "fileupload=@filename.txt" http://example.com/resource.cgi
curl --data "param1=value1&param2=value2" http://example.com/resource.cgi


Form Dataview sourceview URL encoded
page:databasesetup.vm
database_connection:jdbc:mysql://localhost:3306/@DBNAME@?autoReconnect=true&sessionVariables=storage_engine=InnoDB&useUnicode=true&characterEncoding=UTF-8
database_driver:
openmrs_current_database_name:
current_openmrs_database:no
openmrs_new_database_name:openmrs
create_database_username:root
create_database_password:password
continue.x:27
continue.y:27


Form Dataview sourceview URL encoded
page:databasetablesanduser.vm
create_tables:yes
add_demo_data:no
current_database_username:
current_database_password:
current_database_user:no
create_user_username:root
create_user_password:password
continue.x:28
continue.y:21

Form Dataview sourceview URL encoded
page:otherruntimeproperties.vm
module_web_admin:yes
auto_update_database:yes
continue.x:29
continue.y:31

Form Dataview sourceview URL encoded
page:adminusersetup.vm
new_admin_password:Admin123
new_admin_password_confirm:Admin123
continue.x:22
continue.y:29

Form Dataview sourceview URL encoded
page:implementationidsetup.vm
implementation_name:Jan Swathya Sahyog
implementation_id:JSS
pass_phrase:
description:Bahmni, Created by ThoughtWorks
continue.x:30
continue.y:31

Form Dataview sourceview URL encoded
page:wizardcomplete.vm
continue.x:28
continue.y:28