#! /bin/bash

#
# This program will generate 'Markers' from bars marked with \barNumberCheck
# Two modes are supported:
#  - basic: each marker is the current bar number in a \markup \box
#  - alpha: each marker is an alphabetic character (nyi)
set -x
gawk -f - $1 <<'EOF'
BEGIN {
    bar = 0
}
{
	if (match($0, "\\\\time[ \t\n\r]*([0-9]+)/([0-9])+", tok)) {
		r[bar+1] = "s"tok[2]"*"tok[1]
        if ( !bar ) r[bar] = r[bar+1]
    }
	if (match($0, "\\|[ \t\n\r]*[%][ \t\n\r]*([0-9]+)", tok)) {
		bar = tok[1]
        if (b[bar-1]) r[bar] = r[bar-1]
        if (!b[bar]++){
            print "| %" bar
            print r[bar]
        }
    }
	if (match($0, "\\|[ \t\n\r]*\\\\barNumberCheck[ \t\n\r]*[#]([0-9]+)", tok)) {
		bar = tok[1]
        if (b[bar-1]) r[bar] = r[bar-1]
        if (!b[bar]++) {
            print "| %" bar
            print r[bar]
        }
		if (!m[tok[1]]++) print "\\mark \\markup { \\box { " tok[1] " } } "
    }

}
EOF


