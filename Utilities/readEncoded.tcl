#!/bin/sh
# the next line restarts using wish \
exec wish "$0" -- "$@"

# This script simply displays a file that has been encoded in a non-ascii
# format.  Typically, these are foreign-language files.
# usage: readEncoded [encoding [file]]

wm withdraw .
set LangEncoding big5
set file {}
if {$argc > 0} {set LangEncoding [lindex $argv 0]}
if {$argc > 1} {
  set file [lindex $argv 1]
} else {
  set file [tk_getOpenFile]
}

text .t -width 100 -height 50 -yscrollcommand ".s set"
scrollbar .s -orient vert -command ".t yview"
pack .s -side right -fill y -expand 1
pack .t -fill both -expand 1

set f [open $file "r"]
fconfigure $f -encoding $LangEncoding
set data [read $f]
.t insert 0.0 $data
wm deiconify .
