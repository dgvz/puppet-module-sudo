class sudo {
	package { "sudo": ensure => present }

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
}
