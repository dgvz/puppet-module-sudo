define sudo::entry::tag_($base,
                         $tagname,
                         $value   = undef) {
	case $value {
		yes,true,1: { $tag_ = $tagname       }
		no,false,0: { $tag_ = "NO${tagname}" }
		default:    { $tag_ = undef          }
	}

	Augeas {
		incl => "/etc/sudoers",
		lens => "Sudoers.lns",
	}

	if $tag_ {
		augeas { $name:
			changes => "set ${base}/tag[.='${tagname}' or .='NO${tagname}'] ${tag_}",
			onlyif  => "match ${base}/tag[.='${tag_}'] size == 0";
		}
	} else {
		augeas { $name:
			changes => "rm ${base}/tag[.='${tagname}' or .='NO${tagname}']",
			onlyif  => "match ${base}/tag[.='${tagname}' or .='NO${tagname}'] size > 0";
		}
	}
}
