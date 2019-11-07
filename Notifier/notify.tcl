# This is a package that allows linger to send AOL Instant Messages to the 
# experimenter to warn when a subject is about to finish an experiment.
# Written by Doug Rohde
# Copyright 2001-2002

source toc.tcl

set Notify(names)    {Linger0000 Linger0001 Linger0003 Linger0004 Linger0005 Linger0006 Linger0007 Linger0008}
set Notify(destname) {}
set Notify(tochost)  toc.oscar.aol.com
set Notify(tocport)  9898
set Notify(authhost) login.oscar.aol.com
set Notify(authport) 1234
set Notify(password) password
set AIMWaiting       0

proc notifyExperimenter msg {
  global Notify AIMWaiting
  if {$Notify(destname) == {}} return
  set screenname [chooseRand $Notify(names)]
#  puts "name: $screenname"

  set AIMWaiting 1
  catch {toc_close foo}
  toc_open foo $Notify(tochost) $Notify(tocport) $Notify(authhost) \
      $Notify(authport) $screenname $Notify(password) english \
      {TIK:$Revision: 1.180 $} ""
  vwait AIMWaiting

  toc_send_im foo $Notify(destname) $msg
#  puts "notified $Notify(tochost) $Notify(tocport) $Notify(authhost) \
#      $Notify(authport) $screenname $Notify(password) $Notify(destname) $msg"
}

set Experimenters {}
if [file readable experimenters] {
  set f [open experimenters "r"]
  while {[gets $f line] != -1} {lappend Experimenters $line}
  close $f
}

proc SIGN_ON {name version} {
  global AIMWaiting Notify
#  puts "SIGN_ON: $name $version"
#  toc_add_buddy foo $Notify(destname)
#  toc_add_permit foo $Notify(destname)
#  toc_init_done foo
  set AIMWaiting 0
#  toc_send_im foo NotifyName "Hi, geek"
}

#proc CONFIG {name data} {
#  puts CONFIG
#  puts "$name $data"
#}

#proc NICK {name nick} {
#  puts NICK
#  puts "$name $nick"
#}

#proc IM_IN {name source msg auto} {
#  puts IM_IN
#  puts "$name $source $msg $auto"
#}

proc IM_OUT {name source msg auto} {
#  puts "IM_OUT: $name $source $msg $auto"
  update
  catch {toc_close foo}
}

#proc UPDATE_BUDDY {name user online evil signon idle uclass} {
#  puts UPDATE_BUDDY
#  puts "$name $user $online $evil $signon $idle $uclass"
#}

proc ERROR {name code data} {
  global AIMWaiting
  warning "AIM error: $code $data"
  set AIMWaiting 0
}

#proc PAUSE {name data} {
#    puts "PAUSING"
#}

#proc CONNECTION_CLOSED {name data} {
#  puts CONNECTION_CLOSED
#  puts "$name $data"
#}

toc_register_func * SIGN_ON           SIGN_ON
#toc_register_func * CONFIG            CONFIG
#toc_register_func * NICK              NICK
#toc_register_func * IM_IN             IM_IN
toc_register_func * toc_send_im       IM_OUT
#toc_register_func * UPDATE_BUDDY      UPDATE_BUDDY
toc_register_func * ERROR             ERROR
#toc_register_func * PAUSE             PAUSE
#toc_register_func * CONNECTION_CLOSED CONNECTION_CLOSED

