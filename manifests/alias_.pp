define sudo::alias_($ensure = present,
                    $type, $key, $item) {
	include sudo

	if $key !~ /^[A-Z][A-Z0-9_]*$/ {
		fail("Invalid key: ${key}")
	}

	case $type {
		user:       { $directive = "User_Alias" }
		runas_user: { $directive = "Runas_Alias" }
		host:       { $directive = "Host_Alias" }
		command:    { $directive = "Cmnd_Alias" }
		default: {
			fail("Invalid type: ${type}")
		}
	}

	Augeas {
		incl => "/etc/sudoers",
		lens => "Sudoers.lns",
	}

	case $ensure {
		present: {
			augeas { "sudo/alias/${type}/${key}/${item}":
				changes => [
					"set ${directive}[alias/name='${key}']/alias/name ${key}",
					"set ${directive}[alias/name='${key}']/alias/${type}[last()+1] '${item}'",
				],
				onlyif  => "match ${directive}[alias/name='${key}']/alias/${type}[.='${item}'] size == 0";
			}
		}
		absent: {
			augeas { "sudo/alias/${type}/${key}/${item}":
				changes => [
					"rm ${directive}[alias/name='${key}']/alias/${type}[.='${item}']",
					"rm ${directive}[alias/name='${key}'][count(alias/${type})=0]",
				],
				onlyif  => "match ${directive}[alias/name='${key}']/alias/${type}[.='${item}'] size > 0";
			}
		}
	}
}
