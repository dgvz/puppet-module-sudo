define sudo::entry($ensure   = present,
                   $user,
                   $host     = $hostname,
                   $command,
                   $runas    = "root",
                   $passwd   = undef,
                   $exec     = undef,
                   $setenv   = undef) {
	include sudo

	if $user == "root" {
		warning("Refusing to add Sudo entry for '${user}'")
	} else {
		$base = "spec[user='${user}']/host_group[host='${host}']/command[.='${command}'][runas_user='${runas}']"

		case $ensure {
			present: {
				augeas { "sudo/entry/${name}":
					incl    => "/etc/sudoers",
					lens    => "Sudoers.lns",
					changes => [
						"set spec[last()+1]/user ${user}",
						"set spec[last()]/host_group/host ${host}",
						"set spec[last()]/host_group/command '${command}'",
						"set spec[last()]/host_group/command/runas_user ${runas}",
					],
					onlyif  => "match ${base} size == 0";
				}

				Sudo::Entry::Tag_ {
					base    => $base,
					require => Augeas["sudo/entry/${name}"],
				}
				sudo::entry::tag_ { "${name}/passwd": tagname => "PASSWD", value => $passwd }
				sudo::entry::tag_ { "${name}/exec":   tagname => "EXEC",   value => $exec   }
				sudo::entry::tag_ { "${name}/setenv": tagname => "SETENV", value => $setenv }
			}
			absent: {
				augeas { "sudo/entry/${name}":
					incl    => "/etc/sudoers",
					lens    => "Sudoers.lns",
					changes => "rm *[user='${user}'][host_group/host='${host}'][host_group/command='${command}'][host_group/command/runas_user='${runas}']",
					onlyif  => "match *[user='${user}'][host_group/host='${host}'][host_group/command='${command}'][host_group/command/runas_user='${runas}'] size > 0",
				}
			}
		}
	}
}
