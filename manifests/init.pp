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
}
class { 'logstash': 
	java_install	=> true,
}
