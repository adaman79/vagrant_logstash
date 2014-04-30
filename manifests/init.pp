node "logstash.cc.de" {
	exec { "apt-update":
		command	=> "/usr/bin/apt-get update",
	}

	include 'logstash'
	include 'elasticsearch'
	
	package { "redis-server":
		ensure 	=> "installed",
		require	=> Exec['apt-update'],
	}
	
	file {"/etc/redis/redis.conf": 
		notify	=> Service["redis-server"],
		ensure	=> present,
		mode	=> 655,
		require	=> Package["redis-server"],
		content => template('/vagrant/templates/redis.conf.erb');
	}

	service {"redis-server":
		ensure	=> "running",
		enable	=> "true",
	}

	logstash::configfile { 'central':
	        content => template("/vagrant/templates/central.conf.erb"),
        	order   => 10
	}

}
class { 'logstash': 
	manage_repo   => true,
	repo_version  => '1.4',
	ensure	=> present,
	java_install  => true,
}

class { 'elasticsearch':
	package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb',
	config                   => {
		'cluster'	=> {
			'name'	=> 'logstash'
		},
	     'node'                 => {
	       'name'               => 'logstash'
	     },
	     'index'                => {
	       'number_of_replicas' => '0',
	       'number_of_shards'   => '5'
	     },
	     'network'              => {
	       'host'               => $::ipaddress_eth1
	     }
	   }
	}
