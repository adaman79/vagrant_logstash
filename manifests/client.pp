node "client.cc.de" {
        # update and source installation
        exec { "apt-update":
                command => "/usr/bin/apt-get update",
        }
	$config_hash = {
		'LS_USER' => 'logstash',
   		'LS_GROUP' => 'adm',
 	}
        include 'logstash'
	
	logstash::configfile { 'shipper':
                content => template("/vagrant/templates/shipper.conf.erb"),
                order   => 10
        }
}
class { 'logstash':
        manage_repo   => true,
        repo_version  => '1.4',
        ensure  => present,
        java_install    => true,
	init_defaults => $config_hash
}

