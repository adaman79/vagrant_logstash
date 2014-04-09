define aptkey($ensure, $apt_key_url = 'http://packages.elasticsearch.org/') {
  case $ensure {
    'present': {
      exec { "apt-key present $name":
	command => "/usr/bin/wget -q $apt_key_url$name -O -|/usr/bin/apt-key add -",
	unless  => "/usr/bin/apt-key list|/bin/grep -c $name",
      }
    }
    'absent': {
      exec { "apt-key absent $name":
	command => "/usr/bin/apt-key del $name",
	onlyif  => "/usr/bin/apt-key list|/bin/grep -c $name",
      }
    }
    default: {
      fail "Invalid 'ensure' value '$ensure' for apt::key"
    }
  }
}


node "logstash.cc.de" {
	# apt sources
	file {'logstashlist':
		path	=> '/etc/apt/sources.list.d/logstash.list',
		ensure	=> present,
		mode	=> 0644,
		content	=> 'deb http://packages.elasticsearch.org/logstash/1.4/debian stable main',
	}

	aptkey { 'GPG-KEY-elasticsearch':
		ensure	=> present,
	}
	# update and source installation
	exec { "apt-update":
		command	=> "/usr/bin/apt-get update",
		require	=> [
			Aptkey['GPG-KEY-elasticsearch'],
			File['logstashlist'],
#			File['/etc/apt/apt.conf.d/99auth'],
		]
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
}
class { 'logstash': 
	java_install	=> true,
}

 class { 'elasticsearch':
	package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb',
	config                   => {
	     'node'                 => {
	       'name'               => 'elasticsearch001'
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
