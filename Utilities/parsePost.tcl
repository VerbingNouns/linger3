set PostVars {}

proc translateData string {
  return [string map {+ " " %27 "'" %2C "," %2B "+" %0D "<br>" %0A "" \
      %7E "~" %21 "!" %40 "@" %23 "#" %24 "$" %25 "%" %5E "^" %26 "&" \
      %28 "(" %29 ")" %3D "=" %2F "/" %3C "<" %3E ">" %3F "?" %3B ";" \
      %3A ":" %22 \"  %5B "[" %5D "]" %7B "{" %7D "}" %5C "\\" %7C "|"} \
      $string]
}

while {[gets stdin line] != -1} {
  set args [split $line &]
  foreach arg $args {
    set arg [split $arg =]
    set var [translateData [lindex $arg 0]]
    set val [translateData [lindex $arg 1]]
    set Post($var) $val
    lappend PostVars $var
  }
}
