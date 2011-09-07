define sudo::alias::host($ensure = present,
                         $key, $host) {
	sudo::alias_ { "sudo/alias/host/${key}/${host}":
		ensure => $ensure,
		type   => host,
		key    => $key,
		item   => $host;
	}
}
