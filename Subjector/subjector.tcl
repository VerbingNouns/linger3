#!/usr/bin/wish

set Version 1.41

cd [file dirname $argv0]

set Fields {Code Last First Email Phone Contact DOB Race}
set Entries {.code .last .first .email .phone .contact .dob .race}
set i -1
foreach v $Fields {set Col($v) [incr i]; set Orig($v) {}}
set Subject 0
set MinSessionTime 50

set OtherFont    "-family helvetica -size 12 -weight bold"
eval font create OtherFont $OtherFont
option add *font OtherFont userDefault
#set FixedFont    "-family fixed -size 14"
#eval font create FixedFont $FixedFont

wm title . "Subjector v$Version"
wm geometry . +450+280

#frame .f1 -relief ridge -bd 3
#frame .f4
#frame .f4b -width 2
#entry .e1 -width 6 -relief ridge -textvar SeekID
#bind .e1 <Key-Return> findSubject
#label .l1 -text "Initials or Code:"
#pack .l1 .e1 .f4b -in .f4 -side left
#pack .b1 -in .f4 -side left -fill x -expand 1
#pack .f4 -in .f1 -fill x

frame .f2 -relief ridge -bd 3

frame .f2l
frame .f2r
frame .f5
label .lcode -text Code:
entry .code -width 15 -relief ridge -textvar Code
pack .code .lcode -in .f5 -side right
bind .code <Key-Return> searchOrSubmit
bind .code <KeyRelease> "fieldChange .code Code"

frame .f9
label .lfirst -text First:
entry .first -width 15 -relief ridge -textvar First
pack .first .lfirst -in .f9 -side right
bind .first <Key-Return> searchOrSubmit
bind .first <KeyRelease> "fieldChange .first First"

frame .f6
label .llast -text Last:
entry .last -width 15 -relief ridge -textvar Last
pack .last .llast -in .f6 -side right
bind .last <Key-Return> searchOrSubmit
bind .last <KeyRelease> "fieldChange .last Last"

frame .f13
label .ldob -text "DOB:"
entry .dob -width 15 -relief ridge -textvar DOB
pack .dob .ldob -in .f13 -side right
bind .dob <Key-Return> searchOrSubmit
bind .dob <KeyRelease> "fieldChange .dob DOB"

frame .f7
label .lemail -text Email:
entry .email -width 15 -relief ridge -textvar Email
pack .email .lemail -in .f7 -side right
bind .email <Key-Return> searchOrSubmit
bind .email <KeyRelease> "fieldChange .email Email"

frame .f10
label .lphone -text Phone:
entry .phone -width 15 -relief ridge -textvar Phone
pack .phone .lphone -in .f10 -side right
bind .phone <Key-Return> searchOrSubmit
bind .phone <KeyRelease> "fieldChange .phone Phone"

frame .f8
label .lcontact -text Contact:
entry .contact -width 15 -relief ridge -textvar Contact
pack .contact .lcontact -in .f8 -side right
bind .contact <Key-Return> searchOrSubmit
bind .contact <KeyRelease> "fieldChange .contact Contact"

frame .f14
label .lrace -text Race:
entry .race -width 15 -relief ridge -textvar Race
pack .race .lrace -in .f14 -side right
bind .race <Key-Return> searchOrSubmit
bind .race <KeyRelease> "fieldChange .race Race"

frame .f12
button .search -text "Find Record" -bd 1 -command findSubject
button .clear  -text "Clear Record"  -bd 1 -command clearSubject
button .submit -text "Submit Record" -bd 1 -command submitSubject
pack .search .clear .submit -in .f12 -side left -expand 1 -fill x

pack .f5 .f9 .f6 .f13 -in .f2l -side top -anchor e
pack .f7 .f10 .f8 .f14 -in .f2r -side top -anchor e
pack .f12 -in .f2 -side bottom -fill x
pack .f2l .f2r -in .f2 -side left

frame .f3 -relief ridge -bd 3

label .lexpts -text Experiments
scrollbar .sexpts -orient vertical -width 12 -command {.expts yview}
listbox .expts -height 8 -yscroll {.sexpts set} -font fixed
pack .lexpts -in .f3 -side top -fill x
pack .sexpts -in .f3 -side right -fill y
pack .expts -in .f3 -fill both -expand 1
bind .expts <Double-Button-1> deleteSelectedSession
#bind .expts <Key-Delete> {puts hi; puts [.expts get [.expts curselection]]}

frame .f11 -relief ridge -bd 3
label .lnew -text "Available For:"
menubutton .new -menu .new.m -width 15 -relief ridge -textvar Expt
menu .new.m
button .snew -text "Did It!" -bd 1 -command submitSession
pack .lnew .new -in .f11 -side left
pack .snew -in .f11 -side left -fill x -expand 1

pack .f2 -fill x
pack .f3  -fill both -expand 1
pack .f11 -fill x

proc fieldChange {entry v} {
  global $v Orig
  if {[set $v] != $Orig($v)} {
    $entry config -bg pink
  } else {
    $entry config -bg grey80
  }
}

proc configEntries {} {
  global Entries
  foreach entry $Entries {$entry config -bg grey80}
}

proc clearSubject {} {
  global Fields Subject Orig
  foreach i $Fields {
    global $i
    set $i {}
    set Orig($i) {}
  }
  .expts delete 0 end
  .new.m delete 0 end
  .snew config -state disabled
  .code config -state normal
  configEntries
  set Subject 0
}

proc loadSubject {} {
  global Fields Entries Col Subject Orig
  foreach v $Fields {global $v; set Orig($v) [set $v]}
  readSessions
  .code config -state disabled
  foreach i $Entries {$i config -bg grey80}
  if {$Contact == "DNR"} {.contact config -bg pink; bell; after 100; bell}
  set Subject 1
}

proc parseSubjInfo line {
  global Fields Entries Col Subject Orig
  foreach v $Fields {global $v; set $v [lindex $line $Col($v)]}
  loadSubject
}

proc chooseSubject matches {
  toplevel .d
  wm title .d "Which subject?"
  wm geometry .d +450+350
  label .d.l -text "Found [llength $matches] matching subjects"
  menubutton .d.b -text "Click here to pick one" \
      -menu .d.b.m -relief ridge
  menu .d.b.m
  button .d.c -text Cancel -command "destroy .d" -bd 1
  pack .d.l .d.b .d.c -side top -fill x
  foreach line $matches {
    set code [lindex $line 0]
    set last [lindex $line 1]
    set first [lindex $line 2]
    .d.b.m add command -label "$code $first $last" \
	-command "parseSubjInfo \{$line\}; destroy .d"
  }
  wm focus .d
  grab set .d
}

proc codeMatch {a b} {
  return [expr [string trimleft $a 0] == [string trimleft $b 0]]
}

proc match {field value pattern} {
  if {$field == "Code"} {
    return [codeMatch $value $pattern]
  } else {
    set pattern [string toupper $pattern]
    set value   [string toupper $value]
    return [regexp "^${pattern}" $value]
  }
}

proc findSubject {} {
  global Fields Col
  set keys {}
  foreach v $Fields {
    global $v
    if {[set $v] != {}} {lappend keys $v}
  }
  if {$keys == {}} {error "Try entering a code number, name, or initials."}
  set matches {}
  set f [open subjects "r"]
  while {[gets $f line] != -1} {
    set match 1
    foreach k $keys {
      if {![match $k [lindex $line $Col($k)] [set $k]]} {
        set match 0
        break
      }
    }
    if {$match} {lappend matches $line}
  }  
  close $f
  set n [llength $matches]
  if {$n == 0} {
    error "Sorry, no matches"
  } elseif {$n == 1} {
    parseSubjInfo [lindex $matches 0]
  } else {
    chooseSubject $matches
  }
}

proc subjInfo {} {
  global Fields
  foreach v $Fields {global $v}
  return [format "%-4s {%s} {%s} {%s} {%s} {%s} {%s} {%s}" \
      $Code $Last $First $Email $Phone $Contact $DOB $Race]
}

proc submitNewSubject {} {
  global Code
  set f [open subjects "r"]
  set Max 0
  while {[gets $f line] != -1} {
    set Code [string trimleft [lindex $line 0] 0]
    if {$Code > $Max} {set Max $Code}
  }
  set Code [format "%04d" [expr $Max + 1]]
  close $f
  exec echo [subjInfo] >> subjects
}

proc submitUpdate {} {
  global Code
  set n [open /tmp/subjects "w"]
  set f [open subjects "r"]
  while {[gets $f line] != -1} {
    set code [lindex $line 0]
    if [codeMatch $code $Code] {
      puts $n [subjInfo]
    } else {puts $n $line}
  }
  close $n
  close $f
  if {[file readable /tmp/subjects] && [file size /tmp/subjects] > 0} {
    exec mv -f /tmp/subjects subjects
  } else {
    error "Failed to update subject file."
  }
}

proc submitSubject {} {
  global Code First Last Fields Orig
  if {$Last == {} || $First == {}} {
    error "First and last names would help."
  }
  if {$Code == {}} submitNewSubject else submitUpdate
  loadSubject
}

proc searchOrSubmit {} {
  global Subject
  if {$Subject} {submitSubject} else {findSubject}
}

proc chooseExpt expt {
  global Expt
  set Expt $expt
  .snew config -state normal
}

proc readSessions {} {
  global Code Expt
  .expts delete 0 end
  set Expt {}
  set done {}
  set f [open sessions "r"]
  while {[gets $f line] != -1} {
    set code [lindex $line 0]
    if [codeMatch $code $Code] {
      set expt [lindex $line 1]
      set date [lindex $line 2]
      .expts insert end "$date $expt"
      lappend done [string toupper $expt]
    }
  }
  close $f
  .new.m delete 0 end
  set f [open experiments "r"]
  while {[gets $f line] != -1} {
    if {[string index $line 0] == "#"} continue
    if {[string trim $line] == {}} continue
    if {[llength $line] != 3} {
      error "This line in the experiments file doesn't have three fields:\n$line"
    }
    set expt [lindex $line 0]
    set time [lindex $line 1]
    set conflicts "$expt [lindex $line 2]"
    set bad 0
    foreach i $conflicts {
      if {[lsearch -regexp $done [string toupper $i]] != -1} {set bad 1; break}
    }
    if {!$bad} {
      .new.m add command -label $expt -accelerator "$time min" \
	  -command "chooseExpt $expt"
      if {$Expt == {}} {chooseExpt $expt}
    }
  }  
  close $f
}

proc submitSession {} {
  global Code Expt
  if {$Code == {} || $Expt == {}} return
  set date [clock format [clock seconds] -format "%m/%d/%y"]
  exec echo [format "%s %-15s %s" $Code $Expt $date] >> sessions
  readSessions
}

proc deleteSession info {
  global Code
  set code $Code
  set date [lindex $info 0]
  set expt [lindex $info 1]
  set n [open /tmp/sessions "w"]
  set f [open sessions "r"]
  while {[gets $f line] != -1} {
    set c [lindex $line 0]
    set e [lindex $line 1]
    set d [lindex $line 2]
    if {$c == $code && $e == $expt && $d == $date} {
      puts "removed"
    } else {puts $n $line}
  }
  close $n
  close $f
  if {[file readable /tmp/sessions] && [file size /tmp/sessions] > 0} {
    exec mv -f /tmp/sessions sessions
  } else {
    error "Failed to update session file."
  }
  readSessions
}

proc deleteSelectedSession {} {
  global Code
  set info [.expts get [.expts curselection]]
  if [tk_dialog .dia "Delete Entry?" "Are you sure you want to delete the following experiment entry?\n\"$info\"" questhead 0 "No, Don't" "Yes, Delete It"] {
    deleteSession $info
  }
}

proc usage {} {
  puts "Usage: subjector \[options\]"
  puts "  -e min max maxAge"
  puts "     list or send mail (with -m) to eligible subjects"
  puts "     the maxAge is the time since last session, in days"
  puts "  -m message_file"
  puts "     if followed by -e, mails the message to the subjects"
  exit
}

proc dayNum date {
  if [catch {set s [clock scan $date]}] {return 0}
  return [expr $s / 86400]
}

proc findEligibleSubjects {} {
  global ID MessageFile Contact MinSessionTime Email
  wm withdraw .
  set numSent 0
  set today [expr [clock seconds] / 86400]

# Read the sessions
  set f [open sessions "r"]
  while {[gets $f line] != -1} {
    set Code [string trimleft [lindex $line 0] 0]
    if {$Code < $ID(min) || $Code > $ID(max)} continue
    lappend Done($Code) [string toupper [lindex $line 1]]
    set date [dayNum [string toupper [lindex $line 2]]]
    if {![info exists Date($Code)] || $date > $Date($Code)} {
      set Date($Code) $date
    }
  }
  close $f

# Read the experiments
  set e [open experiments "r"]
  set Experiments {}
  while {[gets $e line] != -1} {
    if {[lindex $line 0] == "#"} continue
    if {[string trim $line] == {}} continue
    if {[llength $line] != 3} {
      error "This line in the experiments file doesn't have three fields:\n$line"
    }
    set expt [lindex $line 0]
    lappend Experiments $expt
    set time($expt) [lindex $line 1]
    set conflicts($expt) "$expt [lindex $line 2]"
  }
  close $e

# Read the subjects
  set f [open subjects "r"]
  while {[gets $f line] != -1} {
    set Code [string trimleft [lindex $line 0] 0]
    if {$Code < $ID(min) || $Code > $ID(max)} continue
    parseSubjInfo $line
    if {$Contact != "Y" && $Contact != ""} {
      puts "# $Code contact $Contact"; continue
    }
    if {$Email == {}} {puts "# $Code no email"; continue}
    if [info exists Date($Code)] {set date $Date($Code)} else {set date $today}
    if {($today - $date) > $ID(date)} {puts "# $Code too old [expr $today - $date]"; continue}

# Find the eligible experiments and sum their time
    if [info exists Done($Code)] {set done $Done($Code)} else {set done {}}
    set totalTime 0
    foreach expt $Experiments {
      set bad 0
      foreach i $conflicts($expt) {
	if {[lsearch -regexp $done [string toupper $i]] != -1} {
	  set bad 1
	  break
	}
      }
      if {!$bad} {incr totalTime $time($expt)}
    }
    if {$totalTime < $MinSessionTime} {
      puts "# $Code only eligible for $totalTime min"
      continue
    }

    puts "$Code $Email $totalTime"
    if {$MessageFile != {}} {
      exec mail -s "Reading Experiment" $Email < $MessageFile
      puts "SENT"
    }
    incr numSent
  }
  if {$MessageFile != {}} {
    puts "Sent $numSent emails."
  } else {puts "Would have sent $numSent emails."}
}

proc reportRaces exp {
# Read the sessions
  global Code Last First Race
  set f [open sessions "r"]
  while {[gets $f line] != -1} {
    set Code [string trimleft [lindex $line 0] 0]
    set Expt [lindex $line 1]
    if {[regexp $exp $Expt]} {set Active($Code) 1}
  }
  set f [open subjects "r"]
  while {[gets $f line] != -1} {
    set Code [string trimleft [lindex $line 0] 0]
    if {![info exists Active($Code)]} continue
    parseSubjInfo $line
    puts [format "%s %-12s %-12s %s" $Code $First $Last $Race]
  }
  close $f
}

set MessageFile {}
for {set arg 0} {$arg < $argc} {incr arg} {
  switch -exact -- [lindex $argv $arg] {
    "-m" {set MessageFile [lindex $argv [incr arg]]}
    "-e" {
      set ID(min) [lindex $argv [incr arg]]
      set ID(max) [lindex $argv [incr arg]]
      set ID(date) [lindex $argv [incr arg]]
      findEligibleSubjects
      exit
    }
    "-r" {
      reportRaces [lindex $argv [incr arg]]
      exit
    }
    default usage
  }
}

clearSubject
