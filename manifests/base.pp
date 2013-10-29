class sudo::base {
	include sudo::packages

	Augeas { require => Sudo::Noop["sudo/installed"] }

	# NRPE checks don't have a tty
	augeas { "sudo/requiretty":
		incl    => "/etc/sudoers",
		lens    => "Sudoers.lns",
		changes => [
			"ins #comment before Defaults[requiretty]",
			"set #comment[following-sibling::Defaults/requiretty][last()] 'Defaults requiretty'",
			"rm Defaults/requiretty",
			"rm Defaults[count(*) = 0]",
		],
		onlyif => "match Defaults/requiretty size > 0";
	}

	case $::operatingsystem {
		RedHat,CentOS: {
			if to_i($::operatingsystemrelease) >= 6 {
				# Red Hat doesn't like /usr/local, apparently. Let's fix
				# that by making secure_path consistent with Debian's.
				augeas { "sudo/secure_path":
					incl    => "/etc/sudoers",
					lens    => "Sudoers.lns",
					changes => [
						"set Defaults/secure_path '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'",
					],
					onlyif  => "match Defaults[secure_path='/sbin:/bin:/usr/sbin:/usr/bin'] size > 0",
				}
			}
		}
	}
}
