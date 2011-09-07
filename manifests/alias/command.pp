define sudo::alias::command($ensure = present,
                            $key, $command) {
	sudo::alias_ { "sudo/alias/command/${key}/${command}":
		ensure => $ensure,
		type   => command,
		key    => $key,
		item   => $command;
	}
}
