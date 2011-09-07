define sudo::alias::user($ensure = present,
                         $key, $user) {
	sudo::alias_ { "sudo/alias/user/${key}/${user}":
		ensure => $ensure,
		type   => user,
		key    => $key,
		item   => $user;
	}
}
