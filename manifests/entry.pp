define sudo::entry::tag_($base, $tagname, $value) {
	case $value {
		yes,true,1: { $tag_ = $tagname       }
		no,false,0: { $tag_ = "NO${tagname}" }
		default:    { $tag_ = undef          }
	}
	if $tag_ {
		augeas { $name:
			context => "/files/etc/sudoers",
			changes => "set ${base}/tag[.='${tagname}' or .='NO${tagname}'] ${tag_}",
			onlyif  => "match ${base}/tag[.='${tag_}'] size == 0";
		}
	} else {
		augeas { $name:
			context => "/files/etc/sudoers",
			changes => "rm ${base}/tag[.='${tagname}' or .='NO${tagname}']",
			onlyif  => "match ${base}/tag[.='${tagname}' or .='NO${tagname}'] size != 0";
		}
	}
}

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
				augeas { $name:
					context => "/files/etc/sudoers",
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
					require => Augeas[$name],
				}
				sudo::entry::tag_ { "${name}/passwd": tagname => "PASSWD", value => $passwd }
				sudo::entry::tag_ { "${name}/exec":   tagname => "EXEC",   value => $exec   }
				sudo::entry::tag_ { "${name}/setenv": tagname => "SETENV", value => $setenv }
			}
			absent: {
				fail("ensure '${ensure}' not implemented")
			}
		}
	}
}
