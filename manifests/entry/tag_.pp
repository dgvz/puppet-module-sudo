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
			onlyif  => "match ${base}/tag[.='${tagname}' or .='NO${tagname}'] size > 0";
		}
	}
}
