define sudo::entry($ensure   = present,
                   $user,
                   $host     = "ALL",
                   $command,
                   $runas    = "root",
                   $passwd   = undef,
                   $exec     = undef,
                   $setenv   = undef) {
	include sudo::base

	Augeas {
		incl    => "/etc/sudoers",
		lens    => "Sudoers.lns",
		require => Sudo::Noop["sudo/installed"],
	}

	if $user == "root" {
		warning("Refusing to add Sudo entry for '${user}'")
	} else {
		$base_filter  = "[user='${user}'][host_group[host='${host}'][command[.='${command}'][runas_user='${runas}']]]"
		$base_changes = [ "rm spec${base_filter}" ]

		case $ensure {
			present: {
				$init_changes = [
					"clear spec[#new]/#new",
					"set spec[#new]/user '${user}'",
					"set spec[#new]/host_group/host '${host}'",
					"set spec[#new]/host_group/command '${command}'",
					"set spec[#new]/host_group/command/runas_user '${runas}'",
				]

				case $passwd {
					true: {
						$passwd_changes = [ "set spec[#new]/host_group/command/tag[last()+1] 'PASSWD'" ]
						$passwd_filter  = "[host_group/command/tag[.='PASSWD']]"
					}
					false: {
						$passwd_changes = [ "set spec[#new]/host_group/command/tag[last()+1] 'NOPASSWD'" ]
						$passwd_filter  = "[host_group/command/tag[.='NOPASSWD']]"
					}
					undef: {
						$passwd_changes = []
						$passwd_filter  = ""
					}
					default: {
						fail("Invalid value for passwd: ${passwd}")
					}
				}
				case $exec {
					true: {
						$exec_changes = [ "set spec[#new]/host_group/command/tag[last()+1] 'EXEC'" ]
						$exec_filter  = "[host_group/command/tag[.='EXEC']]"
					}
					false: {
						$exec_changes = [ "set spec[#new]/host_group/command/tag[last()+1] 'NOEXEC'" ]
						$exec_filter  = "[host_group/command/tag[.='NOEXEC']]"
					}
					undef: {
						$exec_changes = []
						$exec_filter  = ""
					}
					default: {
						fail("Invalid value for exec: ${exec}")
					}
				}
				case $setenv {
					true: {
						$setenv_changes = [ "set spec[#new]/host_group/command/tag[last()+1] 'SETENV'" ]
						$setenv_filter  = "[host_group/command/tag[.='SETENV']]"
					}
					false: {
						$setenv_changes = [ "set spec[#new]/host_group/command/tag[last()+1] 'NOSETENV'" ]
						$setenv_filter  = "[host_group/command/tag[.='NOSETENV']]"
					}
					undef: {
						$setenv_changes = []
						$setenv_filter  = ""
					}
					default: {
						fail("Invalid value for setenv: ${setenv}")
					}
				}
				$fini_changes = [
					"rm spec[#new]/#new",
				]

				$changes = concat($base_changes, $init_changes, $passwd_changes, $exec_changes, $setenv_changes, $fini_changes)
				$filter  = concat($base_filter,                 $passwd_filter,  $exec_filter,  $setenv_filter,  $fini_filter)

				augeas { "sudo/entry/${name}":
					changes => $changes,
					onlyif  => "match spec${filter} size == 0";
				}
			}
			absent: {
				augeas { "sudo/entry/${name}":
					changes => $base_changes,
					onlyif  => "match spec${base_filter} size > 0",
				}
			}
		}
	}
}
