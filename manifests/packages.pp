class sudo::packages {
	noop { "sudo/installed": }
	Package { before => Noop["sudo/installed"] }

	package { "sudo": ensure => latest }
}
