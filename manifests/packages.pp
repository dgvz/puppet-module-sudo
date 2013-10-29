class sudo::packages {
	sudo::noop { "sudo/installed": }
	Package { before => Noop["sudo/installed"] }

	package { "sudo": }
}
