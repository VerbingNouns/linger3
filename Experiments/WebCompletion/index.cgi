#!/usr/bin/tclsh

set LingerHome /home/tedlab/Linger
set Exp WebCompletion
set Title "Language Survey"

proc nextSubject {} {
  set max 0
  if {![file exists Results]} {return 1}
  cd Results
  set files {}
  catch {set files [glob *]}
  foreach f $files {
    set s [file root $f]
    if {[string is int $s] && $s > $max} {set max $s}
  }
  cd ..
  return [expr $max + 1]
}

puts "Content-type: text/html\n"
puts "<html><head><title>$Title</title>"
puts "<body background=Images/paper2.jpg>"
puts "<center><h2>$Title</h2></center>"

cd $LingerHome/Experiments/$Exp

if ![info exists env(CONTENT_LENGTH)] {
# Display the header page.
  source consent
} else {
  source $LingerHome/Utilities/parsePost.tcl
  if [info exists Post(HEADER)] {
# The consent form is complete, run the experiment.
    if {![info exists Post(CONSENT)]} {
      puts "<b>Sorry, you must acknowledge your consent by checking
the box on the form before participating in the experiment.  Use your
browser's Back button if you would like to return to the form.</b>"
    } elseif {$Post(NAME) == {}} {
      puts "<b>Sorry, you must fill in your name to participate in the
experiment. Use your browser's Back button if you would like to return
to the form.</b>"
    } else {
#      if {![file exists Results]} {file mkdir Results}
      set Subject [nextSubject]
      set f [open Results/$Subject.dat "w"]
      puts $f "# SUBJECT        $Subject"
      foreach var $PostVars {
        if {$var == "HEADER" || $var == "CONSENT"} continue
        puts $f [format "# %-14s %s" $var $Post($var)]
      }
      close $f
      set env(DISPLAY) :0.0
      puts [exec /usr/bin/tclsh $LingerHome/linger.tcl -b -t -e $Exp -s $Subject 2> /dev/null]
    }
  } else {
# The experiment is complete.
    set f [open Results/$Post(SUBJECT).dat "a"]
    foreach var $PostVars {
      if {$var == "SUBJECT"} continue
      puts $f [format "%-16s %s" $var $Post($var)]
    }
    close $f
    puts "<center><h4>Thank you for participating in the study.</h4></center>"
  }
}

puts {<hr>This experiment was generated using the <a
href="http://tedlab.mit.edu/~dr/Linger">Linger</a> software package.}
puts "</body></html>"
