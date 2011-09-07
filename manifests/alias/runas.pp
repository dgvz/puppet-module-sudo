define sudo::alias::runas($ensure = present,
                          $key, $runas) {
	sudo::alias_ { "sudo/alias/runas/${key}/${runas}":
		ensure => $ensure,
		type   => runas_user,
		key    => $key,
		item   => $runas;
	}
}
