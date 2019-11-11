#!/bin/sh
# the next line restarts using wish \
exec wish "$0" -- "$@"

# Linger, a simple flexible platform for reading experiments
# Written by Doug Rohde
# Copyright 2001-2003
set Version 2.96
# Adapted by Lauren Ackerman 2019-11-05
# added QuestionsFirst to specify whether Questions or Ratings should be collected first

############################# Default Preferences #############################

# These are global variables that affect Linger's behavior.
# They can be set to new values in your preferences file to customize it.

# Increase this in the preferences or with the -v option for more feedback.
set Verbosity 0

# The experiment procedure:
set Experiment   selfPacedReading
# Other experiment types are: 
#	selfPacedReading
#   autoPacedReading
#   centerSelfPacedReading
#   centerAutoPacedReading
#   blockReading
#   listenAndAnswer
#   auditoryPrimeLexicalDecision
#   speakAndListen
#   stopMakingSense (self paced reading with online grammatical judgment)

# The background color:
set BgColor      white
# The text color:
set TextColor    black
# The color of the dashes:
set MaskColor    black

# The font used for the sentences:
set TextFont     "-family {courier} -size -20 -weight bold"
# The font used for commands and other messages:
set BigFont      "-family {helvetica} -size 24 -weight bold"
# The font used for the PressKey message:
set ContinueFont "-family {helvetica} -size 20 -weight bold"
# The font used for the entry boxes (like fill-in-the-blank):
set EntryFont    "-family {helvetica} -size 12 -weight bold"
# The maximum number of characters per line:
set MaxChars     100

# Set this to 1 for debugging messages, printed with the debug command:
set Debug 0

# Set this to 1 if you want to collect questions *BEFORE* difficulty ratings, 
#	otherwise questions will always appear after difficulty ratings
set QuestionsFirst 0

# Set this to 1 to make the words visible in self-paced reading/listening:
set ShowWords    1
# Set this to 1 to play the words in self-paced reading/listening:
set PlayWords    0

# Should spaces within blocks be masked:
set MaskJoins    0
# Should spaces between blocks be masked:
set MaskSpaces   0
# The gap between mask dashes (in pixels):
set MaskGap      1
# The number of blocks to show at once with a moving window:
set WindowSize   1
# The number of blocks to step from one window to the next:
set WindowStep   1

# The key to see the next word:
set GoKey        space
# The key to respond no:
set NoKey        j
# The key to respond yes:
set YesKey       f
# Set multiple choice keys:
set MultiKeys    {{A g} {B h} {C v} {D n}}
# This key skips to the next screen:
set SkipKey      End
# If not {}, this key kills the program:
set KillKey      Escape

# The min time (in msec) the go key must be released (prevents holding):
set MinRelease   10
# The min time (in msec) before you can continue from an info display:
set MinInfo      1000
# The delay (in msec) before presenting each item:
set PreDelay     1000
# The delay between words in auto-paced reading:
set AutoPacedDelay 400
# The delay before the first word in auto-paced reading (and centerSelfPaced):
set AutoPacedInitDelay 1000

# This is the number of questions asked per item.  If it is the null string,
# all are asked:
set QuestNum     {}
# If true, multiple questions are randomly ordered:
set QuestRand    0
# The probability of asking each question if one or more is available:
set QuestProb    1.0

# The reward message, leave blank for no feedback:
set RightAnswer  ""
# The error message, leave blank for no feedback:
set WrongAnswer  "Oops.  Wrong answer."
# The time the feedback message stays on the screen:
set FeedbackDelay 1500

# Whether to request a rating in standard experiments:
set CollectRatings 0
# The maximum value of the rating scale:
set RatingChoices 7
# The message presented along with ratings:
set RatingMessage "How difficult was it to understand that sentence?"
# The label at the low end of the rating scale:
set RatingEasy "Very Easy"
# The label at the high end of the rating scale:
set RatingHard "Very Hard"

# The press any key message:
set PressKey     "press any key to continue"
# The question key explanation:
set QuestionKeys "\"[string toupper $YesKey]\" for yes.    \"[string toupper $NoKey]\" for no."

# The mark that identifies header lines in the items file:
set HeaderMark   "#"
# The mark that identifies question lines in the items file:
set QuestionMark "?"
# The mark that identifies multiple choice question lines in the items file:
set MultiChoiceMark "!"
# The mark that identifies a fill-in-the-blank question:
set FillInBlankMark "*"
# The mark that identifies lines with comments that are ignored:
set CommentMark  "%"
# The mark that joins words in a block:
set JoinMark     "_"
# The mark that divides things that are displayed separately but with no space.
set SplitMark    "|"
# The mark that precedes word (or block) tags:
set TagMark      "@"
# The default word (or block) tag:
set DefaultTag   "-"
# The code for a correct yes answer:
set Yes          "Y"
# The code for a correct no answer:
set No           "N"
# The experiment name used for filler items:
set FillerExp    "filler"
# The experiment name used for practice items:
set PracticeExp  "practice"

# The subdirectory in which audio is stored.  For self-paced listening, this
# needs a subdirectory for each item:
set AudioDir     "Audio"
# This separates an item's exper., item, condit., and word in audio filenames:
set AudioJoinMark "-"
# The extension on audio files:
set AudioExtension "wav"

# If 1, the order of items is randomized:
set RandomOrder  1
# The number of items between breaks (0 for no breaks):
set BreakInterval 0

# The command to play a sound file if the Snack package is not available:
set PlayAudio /usr/bin/play

# The amount the window is larger than the screen on either side:
set PadX         10
# The amount the window is larger than the screen on top and bottom:
set PadY         20
# A scale factor for the line spacing (2 for double spaced):
set LineSpacing  1
# The space between the left side of the screen and the sentences:
set RightShift   60
# The amount the sentences are shifted up from the middle of the screen:
set UpShift      20
# When doing center*PacedReading, if the words are left-justified relative to 
# one another:
set CenterLeftAligned  1
# When doing center*PacedReading, the amount the words are shifted to the left
# from the middle of the screen:
set CenterLeftShift  50
# The size of a fixation crosshair:
set CrossSize    10
# The amount the crosshair is shifted up from center:
set CrossUpShift 0
# The amount the crosshair is shifted left from center:
set CrossLeftShift 0
# Determines the horizontal spacing between multiple choice columns:
set MultiChoiceHGap 20
# Determines the vertical spacing between multiple choice rows:
set MultiChoiceVGap 30
# Whether the options are shuffled for multiple choice questions:
set MultiChoiceRandChoices 1
# The width of the fill-in-the-blank entry box:
set FillInBlankWidth 50

# The file, in the experiment directory, in which items are stored:
set ItemFile     "items"
# The file containing preferences that override these defaults:
set PrefFile     "preferences"
# The file containing the introduction commands:
set IntroFile    "introduction"
# The file containing the rest break commands:
set BreakFile    "break"
# The file containing the conclusion commands:
set ConclFile    "conclusion"

# This specifies the encoding used in the experiment files:
set LangEncoding utf-8
# English: iso8859-1
# Chinese: big5

# Set this to 1 for right-to-left languages like Arabic or Hebrew:
set RightToLeft 0

# Flags for the SNACK recorder:
set RecordOptions {-rate 44100}
# -encoding Lin16 | Lin8offset | Lin8 | Lin24 | Lin32 | Float | Alaw | Mulaw
# -rate 8000 | 11025 | 16000 | 22050 | 32000 | 44100 | 48000
# see the Snack manual for other options

############################### Helper Functions ##############################

set Items        {}
set Fillers      {}
set ResultFile   {}
set Continuing   0
set NumQuestions 0
set CorrectQuestions 0
set StartTime    0

# This function is used in place of "source" to execute a Tcl script that is
# encoded in a language-specific encoding, such as big5:
proc encSource file {
  global LangEncoding
  set fd [open $file r]
  fconfigure $fd -encoding $LangEncoding
  set script [read $fd]
  close $fd
  uplevel \#0 $script
}

# This function is used in place of "open" to open a file that is
# encoded in a language-specific encoding, such as big5:
proc openFile {file mode} {
  global LangEncoding
  set f [open $file $mode]
  fconfigure $f -encoding $LangEncoding
  return $f
}

# Give an error message and die (use rarely):
proc fatalError message {
  global Batch
  if {$Batch} {
    puts stderr "Error: $message"
  } else {
    bgerror "$message"
  }
  exit
}

# Print a little warning:
proc warning message {
  puts stderr "Warning: $message"
}

# Only print message if verbosity high enough:
proc feedback {minLevel message} {
  global Verbosity
  if {$Verbosity >= $minLevel} {
    puts stderr $message
  }
}

# Use this instead of puts to debug:
proc debug message {
  global Debug
  if {$Debug} {puts stderr $message}
}

# Generate a random integer in the range [0,n-1]:
proc randInt n {
  if {$n <= 0} {return 0}
  return [expr int(rand() * $n)]
}

# Choose a random element from a list:
proc chooseRand l {
  set n [llength $l]
  return [lindex $l [randInt $n]]
}

# Append a value to a list unless it is already there:
proc ladd {list value} {
  upvar 1 $list lst
  if {![info exists lst] || [lsearch -exact $lst $value] == -1} {
    lappend lst $value
  } else {return $lst}
}

# Replaces spaces in a string with the JoinMark (_):
proc joinWords string {
  global JoinMark
  return [string map "{ } $JoinMark" $string]
}

proc protectString string {
  return [string map {\{ \\{ \} \\} \" \\" \[ \\[ \] \\]} $string]
}

# This returns the elapsed time in microseconds from start to stop even if 
# the clock wrapped around.  If the value is greater than MaxInt, MaxInt will 
# be returned.
set MaxInt 2147483647
proc timeElapsed {start stop} {
  global MaxInt
  set d [expr $stop - $start]
  if {$d < 0} {
    set d [expr $d + 2 * $MaxInt]
    if {$d < 0} {set d $MaxInt}
  }
  return $d
}

# This returns the width of some text in pixels.  It is the same as "font
# measure TextFont $text", but is much faster.
proc fontWidth text {
  global FontWidth
  set len [string length $text]
  set width 0
  for {set i 0} {$i < $len} {incr i} {
    set c [string index $text $i]
    if {![info exists FontWidth($c)]} {
      set FontWidth($c) [font measure TextFont $c]
    }
    incr width $FontWidth($c)
  }
  return $width
}

# After setting the bindings on a key, you can call this to prevent the key
# from being held down, which would generate rapid responses.
# This prevents either two presses without a release or a press immediately
# after a release.
# If you don't provide a key name, it will apply to all keys.
# However, if you do this and a key has a key-specific binding, then the 
# key-specific binding will take precedence and the prevention won't work.
# In that case, you must call preventRepeat specifically on that key.
proc preventRepeat {{key {}}} {
  global _KR
  if {$key == {}} {set type ""} else {set type -$key}
  set pressbind [bind . <KeyPress$type>]
  if {$key != {} && $pressbind == {}} {set pressbind [bind . <KeyPress>]}
  set releasebind [bind . <KeyRelease$type>]
  if {$key != {} && $releasebind == {}} {set releasebind [bind . <KeyRelease>]}
  bind . <KeyPress$type> {
    set KeyTime [clock clicks -milliseconds]
    if {[info exists _KR(%k)]} {set v $_KR(%k)} \
        else {set v [expr $KeyTime + 1000]}
    set _KR(%k) {}
    if {$v == {} || ([timeElapsed $v $KeyTime] < ($MinRelease * $ClockRes))} \
        break
  }
  bind . <KeyPress$type> +$pressbind
  bind . <KeyRelease$type> {set _KR(%k) [clock clicks -milliseconds]}
  bind . <KeyRelease$type> +$releasebind
}

# Randomly sorts a list:
proc shuffleList list {
  set len [llength $list]
  set new {}
  for {set i 0} {$len > 0} {incr i} {
    set j [randInt $len]
    lappend new [lindex $list $j]
    set list "[lrange $list 0 [expr $j - 1]] [lrange $list [expr $j + 1] end]"
    incr len -1
  }
  return $new
}

# Waits for a key press (which is ignored before MinInfo msec):
proc waitForKey {{key ""}} {
  global Waiting MinInfo StartTime ClockRes
  if {$key != {}} {set key -$key}
  bind . <KeyPress$key> {
    set StopTime [clock clicks -milliseconds]
    if {[timeElapsed $StartTime $StopTime] > ($MinInfo * $ClockRes)} {
      set Waiting 0
    }
  }
  preventRepeat
  update
  set StartTime [clock clicks -milliseconds]
  set Waiting 1
  vwait Waiting
  bind . <KeyPress> {}
}

# These commands are used to implement delay periods in which Linger can try
# to get some work done (such as parsing sentences and loading sound files).
# Unless there is no work to be done, this is a better way to implement a
# delay than simply using "after":
# startDelay takes a timer name and a delay time in msec.
# After calling this, you can implement the procedures that do the work that 
# needs to be done.
# Then call waitOnDelay with the name of the timer to wait until the time is 
# up (which may already be the case).
proc startDelay {var delay} {
  global $var
  set $var 1
  after $delay "set $var 0"
}
proc waitOnDelay var {
  global $var
  if {[set $var]} {vwait $var}
}

# This is the way to clear the window:
proc clearWindow {} {
  set good [.c find withtag noclear]
  if {$good == {}} {
    .c delete all
  } else {
    set items [.c find all]
    set bad {}
    foreach item $items {
      if {[lsearch $good $item] == -1} {lappend bad $item}
    }
    eval .c delete $bad
  }
  catch {destroy .msg}
  update
  feedback 2 "window cleared"
}

proc showMessage {message font justify} {
  global RightShift UpShift BgColor TextColor
  catch {destroy .msg}
  message .msg -width [expr [winfo width .c] - 2 * $RightShift] \
      -text $message -font $font -bg $BgColor -fg $TextColor -justify $justify
  .c create window [expr [winfo width .c] / 2] \
      [expr [winfo height .c] / 2 - $UpShift] -win .msg -anchor center
  feedback 2 "showMessage \"$message\""
}

# Displays a message for MinInfo msec and then waits for a key press:
proc keyedMessage {message font justify} {
  global PadY Waiting MinInfo StartTime PressKey ClockRes Batch
  if {$Batch} return
  showMessage $message $font $justify
  bind . <KeyPress> {
    set StopTime [clock clicks -milliseconds]
    if {[timeElapsed $StartTime $StopTime] > ($MinInfo * $ClockRes)} {
      set Waiting 0
    }
  }
  preventRepeat
  after $MinInfo {
    .c create text [expr [winfo width .c] / 2] \
     	[expr [winfo height .c] - $PadY - 40] \
	     -text $PressKey -font ContinueFont -fill $TextColor -anchor s
  }
  update
  set StartTime [clock clicks -milliseconds]
  set Waiting 1
  vwait Waiting
  bind . <KeyPress> {}
  clearWindow
}

# Displays a message for the given delay (msec):
proc timedMessage {message delay font justify} {
  global Waiting
  showMessage $message $font $justify
  startDelay Waiting $delay
  update
  waitOnDelay Waiting
  clearWindow
  destroy .msg
}

# This is used to give instructions in small font:
proc instruct message {keyedMessage $message TextFont left}
# This is used to give a simple command in big font:
proc command  message {keyedMessage $message BigFont center}

set LoadedSounds {}
# This code is for playing sounds.  There are two versions, one which uses the
# Snack package and one which doesn't.  Using Snack is highly recommended
# because your sound playing timings will be more accurate.
# Each version provides three functions: loadSound, playSound, and deleteSound.
if {[catch {package require snack 2.2}]} {
# This sets the sound playing functions if Snack is not available:
  proc loadSound {file name} {
    global _SoundFile LoadedSounds
    feedback 1 "loadSound $file $name"
    set _SoundFile($name) $file
    lappend LoadedSounds $name
  }

  # If the donecmd is set, it will be non-blocking, but the command won't 
  # actually run.
  # solo is ignored here.
  proc playSound {name {donecmd {}} {solo 0}} {
    global PlayAudio _SoundFile
    feedback 1 "playSound $name"
    if {$donecmd == {}} {
      exec $PlayAudio $_SoundFile($name) &
    } else {
      exec $PlayAudio $_SoundFile($name)
    }
    return 1
  }

  proc deleteSound {name} {
    global _SoundFile LoadedSounds
    feedback 1 "deleteSound $name"
    unset _SoundFile($name)
    set i [lsearch $LoadedSounds $name]
    set LoadedSounds [lreplace LoadedSounds $i $i]
  }

  proc deleteSounds {} {
    global LoadedSounds
    feedback 1 "deleteSounds"
    foreach name $LoadedSounds {unset _SoundFile($name)}
    set LoadedSounds {}
  }

  proc startSilence {} {}
  proc stopSilence {} {}
} else {
# This sets the sound playing functions using Snack:
  proc loadSound {file name} {
    global LoadedSounds
    feedback 1 "loadSound $file $name"
    snack::sound $name -load $file
    lappend LoadedSounds $name
  }

  # If the donecmd is set, it will be non-blocking and that command will be
  # executed when it is done.  You can use 1 if you don't want a command.  
  # Otherwise it is blocking.
  # If solo is 1, it will abort if another sound file is playing.
  # Returns 1 if the sound played, 0 on abort.
  proc playSound {name {donecmd {}} {solo 0}} {
    if {$solo && [snack::audio active]} {return 0}
    feedback 1 "playSound $name"
    if {$donecmd == 1} {set donecmd " "}
    if {$donecmd == ""} {
      $name play -blocking 1
    } else {
      $name play -blocking 0 -command $donecmd
    }
    return 1
  }

  proc deleteSound name {
    global LoadedSounds
    feedback 1 "deleteSound $name"
    $name destroy
    set i [lsearch $LoadedSounds $name]
    set LoadedSounds [lreplace LoadedSounds $i $i]
  }

  proc deleteSounds {} {
    global LoadedSounds
    feedback 1 "deleteSounds"
    foreach name $LoadedSounds {catch {$name destroy}}
    set LoadedSounds {}
  }

  proc startRecording name {
    global RecordOptions
    feedback 1 "startRecording $name"
    eval snack::sound $name $RecordOptions
    $name record 
  }
  proc stopRecording name {
    $name stop
    feedback 1 "stopRecording $name"
  }
  proc saveSound {name file} {$name write $file}

  proc bell {} {
    set f [snack::filter generator 280.0 30000 0.0 sine 3000]
    set s [snack::sound]
    $s play -filter $f -command "update; $s destroy; $f destroy"
  }

  proc initSilence {{rate 44100}} {
    global SilenceF SilenceS
#    set SilenceF [snack::filter generator 200 20000 0 sine]
    set SilenceF [snack::filter generator 10 0 0 rectangle]
    set SilenceS [snack::sound -rate $rate]
    proc stopSilence {} {
      global SilenceS
      $SilenceS stop   
    }
    proc playSilence {} {
      global SilenceF SilenceS
      $SilenceS play -filter $SilenceF -blocking 0 
    }
  }
  proc deleteSilence {} {
    global SilenceF SilenceS
    catch {$SilenceS stop}
    catch {$SilenceS destroy}
    catch {$SilenceF destroy}
  }
}

# Displays a crosshair in the center:
proc crossHairOn {} {
  global CrossSize UpShift CrossUpShift CrossLeftShift
  set x [expr [winfo width .c] / 2 - $CrossLeftShift]
  set y [expr [winfo height .c] / 2 - $UpShift - $CrossUpShift]
  .c create line [expr $x - $CrossSize] $y [expr $x + $CrossSize] $y -tag cross
  .c create line $x [expr $y - $CrossSize] $x [expr $y + $CrossSize] -tag cross
  update idletasks
}

# Removes the crosshair:
proc crossHairOff {} {
  .c delete cross
}

# This presents an item using the default proc (useful in the introduction):
proc presentItem item {
  global Experiment
  ${Experiment}Item $item
}

proc percentCorrect {} {
  global NumQuestions CorrectQuestions
  return [format "%d" [expr round(double($CorrectQuestions) * 100 / \
                                  $NumQuestions)]]
}

####################### Experiment and Subject Choosing #######################

# Generates the next available subject number:
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

# Sets the experiment name:
proc setExperiment exp {
  global Exp
  .ce.b1 config -text $exp
  set Exp $exp
  .ce.e1 delete 0 end
  cd $exp
  .ce.e1 insert 0 [nextSubject]
  cd ..
}

# Sets the AIM notification address:
proc setNotify {name address} {
  global Notify
  .ce.b5 config -text $name
  set Notify(destname) $address
}

# Checks to see if the subject exists and, if so, asks whether you want to
# abort, overwrite, or continue a previously halted experiment:
proc checkSubject {} {
  global Testing Waiting Subject Exp Continuing
  set Subject [string trim [.ce.e1 get]]
  if {![string is integer $Subject]} {
    bgerror "Sorry, the subject name must be an integer."
    return
  }
  if {!$Testing} {
    if {[file exists $Exp/Results/$Subject.dat]} {
      if {[file exists $Exp/Results/$Subject.itm]} {
	set v [tk_dialog .dia "Duplicate Subject!!" "The results file $Subject.dat already exists.  Do you want to abort, continue from where this subject left off, or overwrite the original data?" warning 0 Abort Continue Overwrite]
	if {$v == 0} return
	if {$v == 1} {set Continuing 1}
      } else {
	set v [tk_dialog .dia "Duplicate Subject!!" "The results file $Subject.dat already exists.  Are you sure you want to overwrite it?" warning 0 Abort Overwrite]
	if {$v == 0} return
      }
    }
  }
  set Waiting 0
}

# This handles the initial experiment and subject choosing window:
proc chooseExperiment {} {
  global Testing Waiting Subject Version tcl_platform
  toplevel .ce
  wm title .ce "Linger, version $Version"
  wm resizable .ce 0 0
  wm geometry .ce +[expr [winfo screenwidth .ce] / 2 - 120]+[expr [winfo screenheight .ce] / 2 - 100]
  frame .ce.f1
  label .ce.l1 -text Experiment: -width 12 -anchor w
  menubutton .ce.b1 -menu .ce.b1.menu -width 16 -relief raised -pady 4
  menu .ce.b1.menu -tearoff 0
  set exps {}
  set files {}
  catch {set files [glob *]}
  foreach file $files {
    if {[file isdirectory $file]} {lappend exps $file}
  }
  if {[llength $exps] == 0} {
    fatalError "There are no experiment directories."
  }
  foreach exp $exps {
    .ce.b1.menu add command -label $exp -command "setExperiment \{$exp\}"
  }
  pack .ce.l1 .ce.b1 -in .ce.f1 -side left

  frame .ce.f2
  label .ce.l2 -text "Subject Num:" -width 12 -anchor w
  entry .ce.e1 -width 17 -justify center
  pack .ce.l2 .ce.e1 -in .ce.f2 -side left

  frame .ce.f4
  label .ce.l4 -text "AIM Notify:" -width 12 -anchor w
  menubutton .ce.b5 -text "None" -menu .ce.b5.menu -width 16 -relief raised \
      -pady 4
  menu .ce.b5.menu -tearoff 0
  global Experimenters
  .ce.b5.menu add command -label "None" -command "setNotify None {}"
  foreach pair $Experimenters {
    .ce.b5.menu add command -label [lindex $pair 0] \
	-command "setNotify $pair"
  }
  pack .ce.l4 .ce.b5 -in .ce.f4 -side left

  frame .ce.f3
  button .ce.b3 -text Test -command "set Testing 1; checkSubject" -pady 4
  button .ce.b2 -text Run -width 10 -pady 4 \
      -command "set Testing 0; checkSubject"
  button .ce.b4 -text Quit -command "exit" -pady 4
  pack .ce.b3 -in .ce.f3 -side left
  pack .ce.b4 -in .ce.f3 -side right
  pack .ce.b2 -in .ce.f3 -side left -fill x -expand 1

  pack .ce.f1 .ce.f2 .ce.f4 -in .ce -side top -padx 5 -pady 2
  pack .ce.f3 -in .ce -side top -padx 5 -pady 2 -fill x

  setExperiment [lindex $exps 0]
  tkwait visibility .ce
  grab .ce
  if {$tcl_platform(os) == "Darwin"} {wm iconify .ce; wm deiconify .ce}
  set Waiting 1
  vwait Waiting
  destroy .ce
}

# Produces a window for soliciting subject data.  fields is a list of triples
# with the code, field name, and entry width.
proc getData {title msg fields} {
  global Version tcl_platform ResultFile
  toplevel .gd
  wm title .gd $title
  wm resizable .gd 0 0
  wm geometry .gd +[expr [winfo screenwidth .gd] / 2 - 120]+[expr [winfo screenheight .gd] / 2 - 100]
  if {$msg != ""} {
    message .gd.msg -text $msg -justify left -aspect 600
    pack .gd.msg -side top -fill x
  }
  frame .gd.f1
  frame .gd.f2
  foreach field $fields {
    set code [lindex $field 0]
    set name [lindex $field 1]
    set size [lindex $field 2]
    label .gd.l$code -text $name -anchor w
    entry .gd.e$code -width $size
    pack .gd.l$code -in .gd.f1 -side top -anchor e -pady 1
    pack .gd.e$code -in .gd.f2 -side top -anchor w
  }
  button .gd.b1 -text "Submit" -command "set Waiting 0"
  pack .gd.b1 -in .gd.f2 -side top -fill x -expand 1 -anchor n
  pack .gd.f1 .gd.f2 -side left -anchor n

  tkwait visibility .gd
  grab .gd
  focus .gd.e[lindex [lindex $fields 0] 0]
#  if {$tcl_platform(os) == "Darwin"} {wm iconify .gd; wm deiconify .gd}
  set Waiting 1
  vwait Waiting

  if {$ResultFile != {}} {
    foreach field $fields {
      set code [lindex $field 0]
      puts $ResultFile "# $code: [.gd.e$code get]"
    }
  }
  destroy .gd
}


################################# Item Parsing ################################

# This parses an item description, storing the sentences in the Sentence array
# and the questions in the Question array.  The "name" of the item is
# "experiment:item:condition":
proc parseItem info {
  global HeaderMark QuestionMark MultiChoiceMark FillInBlankMark FillerExp \
      CommentMark Items Fillers Conditions Sentence Question Yes No \
      PracticeExp PracticeItems
  set exp {}
  set blanks 0
  foreach line $info {
    set line [string trim $line]
    feedback 2 "parsing \"$line\""
    set mark [string index $line 0]
    if {$mark == $CommentMark} continue
    if {$mark == $HeaderMark} {
      if {[llength $line] != 4} {
	fatalError "Item header \"$line\" doesn't contain four fields."
      }
      set exp  [lindex $line 1]
      set item [lindex $line 2]
      set cond [lindex $line 3]
      set Sentence($exp:$item:$cond) {}
      set Question($exp:$item:$cond) {}
      
      if {$exp == $PracticeExp} {
        ladd PracticeItems $exp:$item
      } else {
        ladd Items $exp:$item
      }
 
      if {[info exists Conditions($exp:$item)]} {
	if {[lsearch -exact $Conditions($exp:$item) $cond] != -1} {
	  fatalError "Multiple items have the label \"$line\"."
	}
      }
      lappend Conditions($exp:$item) $cond
    } elseif {$mark == $QuestionMark} {
      if {$exp == {}} {
	fatalError "Question \"$line\" isn't preceded by a header."
      }
      if {[lindex $line end] != $Yes && [lindex $line end] != $No} {
	fatalError "Item \"$exp $item $cond\" has a question whose answer is not $Yes or $No"
      }
      lappend Question($exp:$item:$cond) [string trim $line]
    } elseif {$mark == $MultiChoiceMark} {
      if {$exp == {}} {
	fatalError "Question \"$line\" isn't preceded by a header."
      }
      set choices [lindex $line [expr [llength $line] - 2]]
      set answer [lindex $line end]
      if {![lsearch $choices $answer] == -1} {
	fatalError "Item \"$exp $item $cond\" has a multiple choice question whose answer ($answer) is not among the choices ($choices)"
      }
      lappend Question($exp:$item:$cond) [string trim $line]
    } elseif {$mark == $FillInBlankMark} {
      if {$exp == {}} {
	fatalError "Question \"$line\" isn't preceded by a header."
      }
      lappend Question($exp:$item:$cond) [string trim $line]
    } else {
      if {$exp == {}} {
	fatalError "Sentence \"$line\" isn't preceded by a header."
      }
      if {$line == {}} {
        if {$Sentence($exp:$item:$cond) != {}} {incr blanks}
      } else {
        for {set b 0} {$b < $blanks} {incr b} {
          lappend Sentence($exp:$item:$cond) {}
        }
        set blanks 0
        if {$mark == "\\"} {set line [string range $line 1 end]}
        lappend Sentence($exp:$item:$cond) [string trim $line]
      }
    }
  }
}

# Loads the items file:
proc loadItems file {
  global HeaderMark
  set f [openFile $file "r"]
  set info {}
  while {[gets $f line] != -1} {
    set line [string trim $line]
    if {[string index $line 0] == $HeaderMark && $info != {}} {
      parseItem $info
      set info {}
    }
    lappend info $line
  }
  if {$info != {}} {parseItem $info}
  close $f
}

# This can be called from the introduction script to create special items.  It
# should be passed the same item-description text that would appear in the
# items file.
proc createItem info {
  feedback 1 "createItem $info"
  parseItem [split $info "\n"]
}

################################ Item Ordering ################################

# This decides which condition of each item a subject will see, using a
# round-robin approach.  Subject 1 gets the first condition of item 1, the
# second of item 2, etc.  Subject 2 gets the second of item 1, the third of
# item 2...  The actual item name doesn't matter.
proc chooseItems subj {
  global Items Conditions ActiveItems
  set ActiveItems {}
  set i -1
  foreach item $Items {
    set conds [llength $Conditions($item)]
    set index [expr ($subj + $i) % $conds]
    lappend ActiveItems $item:[lindex $Conditions($item) $index]
    incr i
  }
}

# This randomly orders the items subject to the constraint (if possible) that
# no two items from the same experiment (other than fillers) occur in a row:
proc randOrderItems {} {
  global ActiveItems ExpItems FillerExp
  foreach item $ActiveItems {
    set e [lindex [split $item :] 0]
    ladd Experiments $e
    lappend Items($e) $item
  }
  set NumLeft 0
  foreach e $Experiments {
    set Items($e) [shuffleList $Items($e)]
    set N($e) [llength $Items($e)]
    incr NumLeft $N($e)
    set Index($e) 0
  }
  set ExpItems {}
  set lastExp {}
  while {$NumLeft > 0} {
# Choose the experiment    
    set n $NumLeft
    if {$lastExp != {}} {incr n -$N($lastExp)}
    if {$n == 0} break
    set i [randInt $n]
    foreach e $Experiments {
      if {$e == $lastExp} continue
      if {$i < $N($e)} break else {incr i -$N($e)}
    }
    if {$lastExp == {} && [info exists N($FillerExp)]} {set e $FillerExp}
    lappend ExpItems [lindex $Items($e) $Index($e)]
    incr Index($e)
    incr N($e) -1
    incr NumLeft -1
    set lastExp $e
  }
  if {$NumLeft > 0} {
    foreach e $Experiments {if {$N($e) > 0} break}
# First try to insert in spots that don't cause adjacencies.
    set safeSpots {}
    for {set i 1} {$i < [llength $ExpItems]} {incr i} {
      set a [lindex [split [lindex $ExpItems [expr $i - 1]] :] 0]
      set b [lindex [split [lindex $ExpItems $i] :] 0]
      if {$a != $e && $b != $e} {lappend safeSpots $i}
    }
    set safeSpots [lsort -decreasing -integer [lrange [shuffleList $safeSpots] \
	    0 [expr $NumLeft - 1]]]
    foreach i $safeSpots {
      set ExpItems [linsert $ExpItems $i [lindex $Items($e) $Index($e)]]
      incr Index($e)
      incr NumLeft -1
    }
# If still not done, insert the rest at random.
    if {$NumLeft > 0} {
      if {$e != $FillerExp} {
	warning "Too few fillers to prevent adjacent items from experiment $e."
      }
      while {$NumLeft > 0} {
	set i [expr [randInt [llength $ExpItems]] + 1]
        set ExpItems [linsert $ExpItems $i [lindex $Items($e) $Index($e)]]
	incr Index($e)
        incr NumLeft -1
      }
    }
  }
}

# This orders the items in the same order they were specified in the items
# file.  However, fillers will all come at the end.  So if you want fillers
# interspersed among your items, you should not call them "fillers":
proc straightOrderItems {} {
  global ActiveItems Fillers ExpItems
  set ExpItems "$ActiveItems $Fillers"
}

# This is for continuing an experiment that was aborted part-way through.  It
# reads the subject's .itm file to determine the initially chosen order of the
# items and then reads the subject's .dat file to eliminate the items already
# run:
proc loadContinueItems {} {
  global Subject ExpItems
  set file [open Results/$Subject.dat "r"]
  while {[gets $file line] != -1} {
    set exp [lindex $line 1]
    set item [lindex $line 2]
    set cond [lindex $line 3]
    set Done($exp:$item:$cond) 1
  }
  close $file

  set ExpItems {}
  set file [open Results/$Subject.itm "r"]
  while {[gets $file item] != -1} {
    if {![info exists Done($item)]} {lappend ExpItems $item}
  }
  close $file
}

################################# Sentence Parsing ############################

# This parses a sentence in the items file and figures out all of the tags,
# word breaks, line breaks, and other stuff:
proc parseSentence sentence {
  global DefaultTag TagMark JoinMark SplitMark NumLines L Line Start Length \
      Tag NumWords MaxChars Word X Y SpacesAfter RightShift UpShift \
      CharHeight Width RightToLeft LineSpacing

  set NumLines 0
  set w 0
  set Word($w) {}

  feedback 2 "parseSentence \"$sentence\""
  foreach line $sentence {
    set L($NumLines) {}
    set lineLen 0
    set len [string length $line]
    set mode space
    for {set i 0} {$i < $len} {incr i} {
      set c [string index $line $i]
      if {[string is space $c]} {
	if {$mode == "word"} {
	  set mode space
	  incr w
	  set Word($w) {}
	}
	if {$lineLen > 0} {
	  append L($NumLines) $c
	  incr lineLen
	}
      } elseif {$c == $SplitMark} {
	if {$mode == "space"} {
	  fatalError "$SplitMark appeared at the start of a word in the line \"$line\""
	}
	if {$mode == "word"} {
	  set mode space
	  incr w
	  set Word($w) {}
	}
      } elseif {$c == $TagMark} {
	set tag {}
	incr i
        while {$i < $len && ![string is space [set c [string index $line $i]]] && $c != $SplitMark} {
	  append tag [string index $line $i]
	  incr i
	}
	set Tag($w) $tag
	incr i -1
      }	else {
	if {$mode == "space"} {
	  set Line($w) $NumLines
	  set Start($w) $lineLen
	  set Length($w) 0
	  set Tag($w) $DefaultTag
	  set mode word
	}
	if {$c == $JoinMark} {set c " "}
	append L($NumLines) $c
	append Word($w) $c
	incr lineLen
	incr Length($w)
	if {$lineLen > $MaxChars && $Start($w) > 0} {
	  set L([expr $NumLines + 1]) \
	    [string range $L($NumLines) $Start($w) end]
	  set L($NumLines) \
            [string trim [string range $L($NumLines) 0 [expr $Start($w) - 1]]]
	  set Start($w) 0
	  set lineLen $Length($w)
	  incr Line($w)
	  incr NumLines
	}
      }
    }
    if {$mode == "word"} {incr w; set Word($w) {}}
    incr NumLines
  }
  set NumWords $w

  for {set w 0} {$w < $NumWords} {incr w} {
    if {$w == 0 || $Line($w) > $Line([expr $w - 1])} {set x $RightShift}
    set X($w) $x
    set Y($w) [expr [winfo height .c] / 2 - $UpShift + \
		   $CharHeight * $LineSpacing * ($Line($w) - 0.5 * $NumLines)]
    set Width($w) [fontWidth $Word($w)]
    if {$w < [expr $NumWords - 1]} {
      set SpacesAfter($w) [expr $Start([expr $w + 1]) - $Start($w) - $Length($w)]} else {set SpacesAfter($w) 0}
    incr x [expr $Width($w) + $SpacesAfter($w) * [fontWidth " "]]
  }

# This reverses the order and right justifies for RTL languages:  
  if {$RightToLeft} {
    for {set w 0} {$w < $NumWords} {incr w} {
      set X($w) [expr [winfo width .c] - $X($w) - $Width($w)]
    }
  }
}

proc checkSentenceWrap {} {
  global Items Sentence NumLines Conditions BgColor TextColor RightShift
  puts "These items will wrap because one or more lines were too long:"
  foreach item $Items {
    foreach cond $Conditions($item) {
      set S $Sentence($item:$cond)
      showMessage "Checking sentence length...\n\n$item:$cond" BigFont center
      update
      parseSentence $S
      if {$NumLines != [llength $S]} {puts $item:$cond; bell}
      clearWindow
    }
  }
  command "Press any key to exit."
}

################################## Display ####################################

# This tries to make the window a little bigger than the screen.
# Some window managers don't allow this.
# Cursors cannot be hidden under Windows:
proc buildMainWindow {} {
  global BgColor PadX PadY GoKey KillKey RightShift tcl_platform
  #set width  [expr [winfo screenwidth .] + $PadX * 2]
  #set height [expr [winfo screenheight .] + $PadY * 2]
  #wm geometry . ${width}x${height}+-${PadX}+-${PadY}
  wm attributes . -fullscreen 1

  wm title . ""
  if {$tcl_platform(platform) == "windows"} {
    . configure -cursor "crosshair"
  } else {
    . configure -cursor "crosshair $BgColor"
  }
  if {$KillKey != {}} {bind . <Key-$KillKey> {safeExit}}
  canvas .c -bg $BgColor
  pack .c -fill both -expand 1
  wm deiconify .
  update
  focus -force .
}

# This draws a word in the correct place on the screen:
proc drawWord w {
  global BgColor L Line Start Length X Y
  set text [string range $L($Line($w)) $Start($w) \
		[expr $Start($w) + $Length($w) - 1]]
  .c create text $X($w) $Y($w) -text $text -anchor nw -font TextFont \
      -justify left -fill $BgColor -tag w$w
}

# This creates the dashes that are used to mask the characters:
proc maskWord w {
  global Length X Y CharHeight MaskJoins MaskGap MaskColor MaskSpaces \
      SpacesAfter Word RightToLeft
  set x $X($w)
  set y [expr $Y($w) + $CharHeight / 2]
  set sl [expr int($MaskGap / 2)]
  set sr [expr $MaskGap - $sl]
  set chars $Length($w)
  for {set i 0} {$i < $chars} {incr i} {
    set c [string index $Word($w) $i]
    set dx [fontWidth $c]
    if {![string is space $c] || $MaskJoins} {
      .c create line [expr $x + $sl] $y [expr $x + $dx - $sr] $y \
	  -fill $MaskColor -tag m$w
    }
    incr x $dx
  }
  if {$MaskSpaces && [set num $SpacesAfter($w)] > 0} {
    set dx [fontWidth " "]
    for {set i 0} {$i < $num} {incr i} {
      if {$RightToLeft} {
        .c create line [expr $X($w) - ($i + 1) * $dx + $sl] $y \
            [expr $X($w) - $i * $dx - $sr] $y -fill $MaskColor -tag a$w
      } else {
        .c create line [expr $x + $sl] $y [expr $x + $dx - $sr] $y \
            -fill $MaskColor -tag a$w
        incr x $dx
      }
    }
  }
}

# Loads a word audio file for self-paced listening:
proc loadWordAudio {item w} {
  global AudioJoinMark AudioExtension AudioDir
  set label [string map ": $AudioJoinMark" $item]
  set dir $AudioDir/$label
  set file $dir/$label$AudioJoinMark[expr $w + 1].$AudioExtension
  if [file readable $file] {
    loadSound $file word$w
  } else {
    warning "Sound file $file is missing or protected."
  }
}

# Plays a word's audio for self-paced listening.  The junk about silence is to
# prevent clicking caused by hanging up the audio device when done playing.
proc playWord w {
  catch {stopSilence}
  if [catch {playSound word$w 1}] bell
  catch {playSilence}
}

# Deletes a word's audio for self-paced listening:
proc deleteWordAudio w {deleteSound word$w}

# Lowers the word below the dashes and colors it white:
proc hide tags {
  global BgColor
  .c itemconfig $tags -fill $BgColor
  .c lower $tags
}

# Raises the word above the dashes and colors it white:
proc show {tags color} {
  .c itemconfig $tags -fill $color
  .c raise $tags
}

proc delete tags {
  .c delete $tags
}

proc showWord w {
  global NumWords TextColor
  if {$w < 0 || $w >= $NumWords} return
  hide m$w
  hide a$w
  show w$w $TextColor
}

proc hideWord w {
  global NumWords MaskColor
  if {$w < 0 || $w >= $NumWords} return
  hide w$w
  show m$w $MaskColor
  if {$w > 0} {show a[expr $w - 1] $MaskColor}
}

proc showWindow {w wArray} {
  global WindowSize WindowStep
  upvar $wArray Words
  if {$w == 0} {
    for {set i 0} {$i < $WindowSize} {incr i} {
      if [info exists Words($i)] {showWord $Words($i)}
    }
  } else {
    for {set i [expr $w+$WindowSize-$WindowStep]} {$i <= $w+$WindowSize-1} {incr i} {
      if [info exists Words($i)] {showWord $Words($i)}
    }
  }
}

proc hideWindow {w wArray} {
  global WindowStep
  upvar $wArray Words
  for {set i $w} {$i < $w + $WindowStep} {incr i} {
    if [info exists Words($i)] {hideWord $Words($i)}
  }
}

################################ Questions ####################################

# Displays the feedback after a question:
proc giveFeedback right {
  global RightAnswer WrongAnswer FeedbackDelay NumQuestions CorrectQuestions
  incr NumQuestions
  if {$right} {incr CorrectQuestions}
  if {$right && $RightAnswer != {}} {
    timedMessage $RightAnswer $FeedbackDelay BigFont center
  } elseif {!$right && $WrongAnswer != {}} {
    timedMessage $WrongAnswer $FeedbackDelay BigFont center
  }
}

proc orderMultiAnswers choices {
  return [shuffleList $choices]
}

# Asks a multiple choice question, return 1 if correct:
proc presentMultiChoice {question item font justify} {
  global TextColor RightShift UpShift Answer MultiKeys StartTime StopTime \
      ResultFile Subject SkipKey MultiChoiceHGap MultiChoiceVGap ClockRes \
      MultiChoiceRandChoices
  set len [llength $question]
  set tag [string range [lindex $question 0] 1 end]
  set choices [lindex $question [expr $len - 2]]
  if {$MultiChoiceRandChoices} {
    set choices [orderMultiAnswers $choices]
  }
  set correct [lindex $question end]
  set question [lrange $question 1 [expr $len - 3]]
  if {$justify == "center"} {
    .c create text [expr [winfo width .c] / 2] \
        [expr [winfo height .c] / 2 - $UpShift] \
        -text $question -anchor c -fill $TextColor -font $font
  } else {
    .c create text $RightShift [expr [winfo height .c] / 2 - $UpShift] \
        -text $question -anchor w -fill $TextColor -font $font
  }
  set maxl 0
  set maxr 0
  set i 0
  foreach choice $choices {
    set w [fontWidth "M) $choice"]
    #if {($i % 2) == 0 && $w > $maxl} {set maxl $w}
    #if {($i % 2) == 1 && $w > $maxr} {set maxr $w}
    set maxl $w ; # replaces previous two if expressions
    incr i
  }
  set width [expr $maxl + $maxr + 2 * $MultiChoiceHGap]
  set i 0
  foreach choice $choices {
    set label [lindex [lindex $MultiKeys $i] 0]
    set key   [lindex [lindex $MultiKeys $i] 1]
    #if {($i % 2) == 0} {set xshift [expr -$width / 2]} \
    else {set xshift [expr -$width / 2 + $MultiChoiceHGap + $maxl]}
    set xshift [expr -$width / 2] ; # replaces if-else expression
    #.c create text [expr [winfo width .c] / 2 + $xshift] \
	[expr [winfo height .c] / 2 + 2 * $MultiChoiceVGap + int($i / 2) * $MultiChoiceVGap] \
	-text "$label) [string map {_ { }} $choice]" -anchor w -fill $TextColor -font $font
	.c create text [expr [winfo width .c] / 2 + $xshift] \
	[expr [winfo height .c] / 2 + 2 * $MultiChoiceVGap + int($i / 1) * $MultiChoiceVGap] \
	-text "$label) [string map {_ { }} $choice]" -anchor w -fill $TextColor -font $font
    bind . <Key-$key> "set StopTime \$KeyTime; set Answer \"$choice\""
    preventRepeat $key
    incr i
  }
  update
  set StartTime [clock clicks -milliseconds]
  bind . <Key-$SkipKey> "set StopTime $StartTime; set Answer \"[lindex $correct 0]\""
  set Answer {}
  vwait Answer

  set i 0
  foreach choice $choices {
    set key [lindex [lindex $MultiKeys $i] 1]
    bind . <Key-$key> {}
    incr i
  }
  bind . <Key-$SkipKey>  {}
  set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
  clearWindow
#  if {[string equal $Answer $correct]} {set code 1} else {set code 0}
  if {[lsearch $correct $Answer] != -1} {set code 1} else {set code 0}
  giveFeedback $code
  if {$ResultFile != {} && $item != {}} {
    puts $ResultFile "$Subject [split $item :] !$tag \{$Answer\} $code $delay"
    flush $ResultFile
  }
  return $code
}

# Asks a fill-in-the-blank question:
proc presentFillInBlank {question item font justify} {
  global TextColor BgColor RightShift UpShift Answer StartTime StopTime \
      ResultFile Subject SkipKey FillInBlankWidth ClockRes EntryFont
  set len [llength $question]
  set tag [string range [lindex $question 0] 1 end]
  set question [lrange $question 1 end]
  message .msg -width [expr [winfo width .c] - 2 * $RightShift] \
      -text $question -font $font -bg $BgColor -fg $TextColor -justify $justify
  .c create window [expr [winfo width .c] / 2] \
      [expr [winfo height .c] / 2 - $UpShift] -win .msg -anchor center
  entry .entry -width $FillInBlankWidth -font $EntryFont
  .c create window [expr [winfo width .c] / 2] \
      [expr [winfo height .c] / 2 + [winfo height .msg] + 20] -window .entry \
    -anchor n
  focus .entry

  bind .entry <Return> {
    set StopTime [clock clicks -milliseconds]
    set Answer [.entry get]
  }
  bind . <Key-$SkipKey> "set StopTime $StartTime; set Answer -"
  update
  set StartTime [clock clicks -milliseconds]
  set Answer {}
  vwait Answer

  bind . <Key-$SkipKey>  {}
  set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
  catch {destroy .entry .msg}
  clearWindow

  set Answer [protectString $Answer]

  if {$ResultFile != {} && $item != {}} {
    puts $ResultFile "$Subject [split $item :] ?$tag \{$Answer\} 1 $delay"
    flush $ResultFile
  }
  return 1
}

# Asks a true/false question, returns 1 if correct:
proc presentQuestion {question item font justify} {
  global TextColor RightShift UpShift Answer YesKey NoKey StopTime \
      ResultFile Subject PadY QuestionKeys SkipKey MultiChoiceMark \
      FillInBlankMark ClockRes
  feedback 1 "presentQuestion \"$question\""
  if {[string index $question 0] == $MultiChoiceMark} {
    return [presentMultiChoice $question $item $font $justify]
  }
  if {[string index $question 0] == $FillInBlankMark} {
    return [presentFillInBlank $question $item $font left]
  }
  set len [llength $question]
  set tag [string range [lindex $question 0] 1 end]
  set correct [lindex $question end]
  set question [lrange $question 1 [expr $len - 2]]
  if {$justify == "center"} {
    .c create text [expr [winfo width .c] / 2] \
        [expr [winfo height .c] / 2 - $UpShift] \
        -text $question -anchor n -fill $TextColor -font $font
  } else {
    .c create text $RightShift [expr [winfo height .c] / 2 - $UpShift] \
        -text $question -anchor nw -fill $TextColor -font $font
  }
  .c create text [expr [winfo width .c] / 2] \
      [expr [winfo height .c] - $PadY - 40] \
      -text $QuestionKeys -font BigFont -fill $TextColor -anchor s
  bind . <Key-$YesKey> {set StopTime $KeyTime; set Answer $Yes}
  preventRepeat $YesKey
  bind . <Key-$NoKey>  {set StopTime $KeyTime; set Answer $No}
  preventRepeat $NoKey
  update
  set StartTime [clock clicks -milliseconds]
  bind . <Key-$SkipKey> "set StopTime $StartTime; set Answer $correct"
  set Answer {}
  vwait Answer

  bind . <Key-$YesKey>   {}
  bind . <Key-$NoKey>    {}
  bind . <Key-$SkipKey>  {}
  set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
  clearWindow
  if {$Answer == $correct} {set code 1} else {set code 0}
  giveFeedback $code
  if {$ResultFile != {} && $item != {}} {
    puts $ResultFile "$Subject [split $item :] ?$tag $Answer $code $delay"
    flush $ResultFile
  }
  return $code
}

proc chooseQuestions questions {
  global QuestNum QuestRand QuestProb QuestAll
# This is for backwards compatibility:
  if {[info exists QuestAll] && !$QuestAll && $QuestNum == {}} {set QuestNum 1}

  if {$QuestRand} {set questions [shuffleList $questions]}
  if {$QuestNum != {}} {
    set questions [lrange $questions 0 [expr $QuestNum - 1]]
  }
  if {$QuestProb < 1} {
    set chosen {}
    for {set i 0} {$i < [llength $questions]} {incr i} {
      if {rand() < $QuestProb} {lappend chosen [lindex $questions $i]}
    }
    return $chosen
  } else {return $questions}
}

# in `set y [expr [winfo height .c] / 3 - $UpShift]` 2 changed to 3 to prevent cursor overlap
proc getRating {item {tag {}}} {
  global Difficulty StartTime StopTime ResultFile UpShift BgColor ClockRes \
    Subject tcl_platform RatingChoices RatingMessage RatingEasy RatingHard
  set owidth 40
  set y [expr [winfo height .c] / 3 - $UpShift]
  set x [expr [winfo width .c] / 2]
  if {$tcl_platform(platform) == "windows"} {
    . configure -cursor center_ptr
  } else {
    . configure -cursor "center_ptr black"
  }
  .c create text $x [expr $y - 50] -text $RatingMessage -font ContinueFont
  .c create text [expr $x - (double($RatingChoices) / 2) * $owidth - 10] $y -text $RatingEasy \
    -anchor e -font ContinueFont
  .c create text [expr $x + (double($RatingChoices) / 2) * $owidth + 10] $y -text $RatingHard \
    -anchor w -font ContinueFont
  for {set i 1} {$i <= $RatingChoices} {incr i} {
    catch {destroy .d$i}
    radiobutton .d$i -value $i -variable Difficulty -text $i -command {set StopTime [clock clicks -milliseconds]}
    .c create window [expr $x - (double($RatingChoices) / 2 - $i) * $owidth] $y \
      -window .d$i -anchor e
    bind . <Key-$i> ".d$i invoke"
    preventRepeat $i
  }
  set StartTime [clock clicks -milliseconds]
  set Difficulty {}
  vwait Difficulty
  set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
  clearWindow
  if {$tcl_platform(platform) == "windows"} {
    . configure -cursor crosshair
  } else {
    . configure -cursor "crosshair $BgColor"
  }

  if {$ResultFile != {} && $item != {}} {
    puts $ResultFile "$Subject [split $item :] %$tag $Difficulty {} $delay"
  }
  for {set i 1} {$i <= $RatingChoices} {incr i} {bind . <Key-$i> {}}
}


# Asks the questions (with option to order ratings):
proc askQuestions {item font justify} {
  global Question CollectRatings QuestionsFirst
  if {$QuestionsFirst} {
    if {$Question($item) == {}} {
     if {$CollectRatings} {getRating $item}
    } else {
      set questions [chooseQuestions $Question($item)]
      foreach question $questions {
        presentQuestion $question $item $font $justify
      }
      if {$CollectRatings} {getRating $item}
    }
  } else {
    if {$CollectRatings} {getRating $item}
    if {$Question($item) == {}} return
  
    set questions [chooseQuestions $Question($item)]
    foreach question $questions {
      presentQuestion $question $item $font $justify
    }
  }

}

###############################################################################

# This is the main command for running most experiments.  It calls the runItem
# procedure on each item and does the break file and sends notifications at
# the appropriate times.
proc standardExperiment {runItem list} {
  global BreakInterval BreakFile Subject Exp
  feedback 1 "Starting standardExperiment"
  set i 0
  set items [llength $list]
  foreach item $list {
    if {$i > 0 && $BreakInterval > 0 && ($i % $BreakInterval) == 0} {
      if [file readable $BreakFile] {encSource $BreakFile}
    }
    $runItem $item
    incr i
    if {$i == ($items - 4)} {
      notifyExperimenter "Subject $Subject is nearly done with $Exp"
    }
  }
  feedback 1 "Finishing standardExperiment"
}

########################### Masked Self-Paced Reading #########################

proc selfPacedPresentSentence item {
  global Tag NumWords GoKey SkipKey StopTime ResultFile Subject Abort Word \
      ClockRes TextColor MaskColor ShowWords PlayWords WindowStep

  set Abort 0
  bind . <KeyPress-$SkipKey> {set Abort 1; set Waiting 0}
  bind . <KeyPress-$GoKey> {set StopTime $KeyTime; set Waiting 0}
  preventRepeat $GoKey

  set GoodWords 0
  for {set w 0} {$w < $NumWords} {incr w} {
    if {$Tag($w) != ""} {
      set Words($GoodWords) $w
      incr GoodWords
    }
  }
  if {$PlayWords} {
    for {set g 0} {$g < $GoodWords} {incr g} {loadWordAudio $item $Words($g)}
  }
  if {$ShowWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      drawWord $w; 
      if {$Tag($w) == ""} {
        show w$w $TextColor
        if {$w > 0} {hide a[expr $w - 1]}
      } else {maskWord $w}
    }
  } else crossHairOn

  update
  set Waiting 1
  vwait Waiting

  if {!$ShowWords} crossHairOff
  
  for {set g 0} {$g < $GoodWords && !$Abort} {incr g $WindowStep} {
    set w $Words($g)
    if {$ShowWords} {showWindow $g Words}
    if {$PlayWords} {playWord $w}

    update
    set StartTime [clock clicks -milliseconds]
    set StopTime $StartTime
    set Waiting 1
    vwait Waiting

    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    if {$ResultFile != {} && $item != {}} {
      puts $ResultFile "$Subject [split $item :] $w [joinWords $Word($w)] $Tag($w) $delay"
      flush $ResultFile
    }

    if {$ShowWords} {hideWindow $g Words}
  }
  if {$PlayWords} deleteSounds
  bind . <KeyPress-$SkipKey> {}
  bind . <KeyPress-$GoKey> {}
  clearWindow
}

proc selfPacedReadingItem item {
  global Sentence PreDelay
  feedback 1 "selfPacedReadingItem $item"
  startDelay D1 $PreDelay
  parseSentence $Sentence($item)
  waitOnDelay D1
  selfPacedPresentSentence $item
  askQuestions $item TextFont center
}

proc selfPacedReading list {
  standardExperiment selfPacedReadingItem $list
}

########################## Centered Self-Paced Reading ########################

proc centerSelfPacedPresentSentence item {
  global Tag NumWords GoKey SkipKey StopTime ResultFile Subject Abort Word \
      ClockRes TextColor X Y CenterLeftAligned CenterLeftShift UpShift \
      ShowWords PlayWords

  set Abort 0
  bind . <KeyPress-$SkipKey> {set Abort 1; set Waiting 0}
  bind . <KeyPress-$GoKey> {set StopTime $KeyTime; set Waiting 0}
  preventRepeat $GoKey

  if {$PlayWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      if {$Tag($w) != ""} {loadWordAudio $item $w}
    }
  }
  if {$ShowWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      if {$CenterLeftAligned} {
        set X($w) [expr [winfo width .c] / 2 - $CenterLeftShift]
      } else {
        set X($w) [expr ([winfo width .c] - [fontWidth $Word($w)]) \
                       / 2 - $CenterLeftShift]
      }
      set Y($w) [expr [winfo height .c] / 2 - $UpShift]
      drawWord $w
    }
  }
  crossHairOn
  set Waiting 1
  vwait Waiting
  
  crossHairOff

  for {set w 0} {$w < $NumWords && !$Abort} {incr w} {
    if {$Tag($w) == ""} continue
    if {$ShowWords} {show w$w $TextColor}
    if {$PlayWords} {playWord $w}

    update
    set StartTime [clock clicks -milliseconds]
    set StopTime $StartTime
    set Waiting 1
    vwait Waiting

    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    if {$ResultFile != {} && $item != {}} {
      puts $ResultFile "$Subject [split $item :] $w [joinWords $Word($w)] $Tag($w) $delay"
      flush $ResultFile
    }

    if {$ShowWords} {hide w$w}
  }
  if {$PlayWords} deleteSounds
  bind . <KeyPress-$SkipKey> {}
  bind . <KeyPress-$GoKey> {}
  clearWindow
}

proc centerSelfPacedReadingItem item {
  global Sentence PreDelay NumWords
  feedback 1 "centerSelfPacedReadingItem $item"
  parseSentence $Sentence($item)
  crossHairOn
  after $PreDelay
  crossHairOff
  centerSelfPacedPresentSentence $item
  askQuestions $item TextFont center
}

proc centerSelfPacedReading list {
  standardExperiment centerSelfPacedReadingItem $list
}

############################## Auto-Paced Reading #############################

proc autoPacedPresentSentence item {
  global Tag NumWords SkipKey AutoPacedInitDelay AutoPacedDelay \
      Subject Abort TextColor MaskColor ShowWords PlayWords WindowStep

  startDelay D1 $AutoPacedInitDelay
  set GoodWords 0
  for {set w 0} {$w < $NumWords} {incr w} {
    if {$Tag($w) != ""} {
      set Words($GoodWords) $w
      incr GoodWords
    }
  }
  if {$PlayWords} {
    for {set g 0} {$g < $GoodWords} {incr g} {loadWordAudio $item $Words($g)}
  }
  if {$ShowWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      drawWord $w; 
      if {$Tag($w) == ""} {
        show w$w $TextColor
        if {$w > 0} {hide a[expr $w - 1]}
      } else {maskWord $w}
    }
  } else crossHairOn

  update
  set Abort 0
  bind . <KeyPress-$SkipKey> {set Abort 1}
  waitOnDelay D1

  if {!$ShowWords} crossHairOff

  for {set g 0} {$g < $GoodWords && !$Abort} {incr g $WindowStep} {
    set w $Words($g)
    if {$ShowWords} {showWindow $g Words}
    if {$PlayWords} {playWord $w}

    update
    after $AutoPacedDelay

    if {$ShowWords} {hideWindow $g Words}
  }
  if {$PlayWords} deleteSounds
  bind . <KeyPress-$SkipKey> {}
  clearWindow
}

proc autoPacedReadingItem item {
  global Sentence PreDelay
  feedback 1 "autoPacedReadingItem $item"
  startDelay D1 $PreDelay
  parseSentence $Sentence($item)
  waitOnDelay D1
  autoPacedPresentSentence $item
  askQuestions $item TextFont center
}

proc autoPacedReading list {
  standardExperiment autoPacedReadingItem $list
}

############################ Center Auto-Paced Reading ########################

proc centerAutoPacedPresentSentence item {
  global Tag NumWords SkipKey AutoPacedInitDelay AutoPacedDelay \
      Subject Abort TextColor X Y CenterLeftAligned CenterLeftShift UpShift \
      ShowWords PlayWords

  startDelay D1 $AutoPacedInitDelay
  if {$PlayWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      if {$Tag($w) != ""} {loadWordAudio $item $w}
    }
  }
  if {$ShowWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      if {$CenterLeftAligned} {
        set X($w) [expr [winfo width .c] / 2 - $CenterLeftShift]
      } else {
        set X($w) [expr ([winfo width .c] - [fontWidth $Word($w)]) \
                       / 2 - $CenterLeftShift]
      }
      set Y($w) [expr [winfo height .c] / 2 - $UpShift]
      drawWord $w
    }
  }
  crossHairOn

  update
  set Abort 0
  bind . <KeyPress-$SkipKey> {set Abort 1}
  waitOnDelay D1
  
  crossHairOff
  
  for {set w 0} {$w < $NumWords && !$Abort} {incr w} {
    if {$ShowWords} {show w$w $TextColor}
    if {$PlayWords} {playWord $w}

    update
    after $AutoPacedDelay

    if {$ShowWords} {hide w$w}
  }
  if {$PlayWords} deleteSounds
  bind . <KeyPress-$SkipKey> {}
  clearWindow
}

proc centerAutoPacedReadingItem item {
  global Sentence PreDelay 
  feedback 1 "centerAutoPacedReadingItem $item"
  parseSentence $Sentence($item)
  crossHairOn
  after $PreDelay
  crossHairOff
  centerAutoPacedPresentSentence $item
  askQuestions $item TextFont center
}

proc centerAutoPacedReading list {
  standardExperiment centerAutoPacedReadingItem $list
}

############################## Block Reading ##################################

proc blockPresentText {item message {blockNum 0}} {
  global BgColor TextColor RightShift UpShift StartTime ResultFile Subject \
      StopTime ClockRes PreDelay
  startDelay D1 $PreDelay
  set message [join $message "\n"]
  message .msg -width [expr [winfo width .c] - 2 * $RightShift] \
      -text $message -font TextFont -bg $BgColor -fg $TextColor \
      -justify left
  .c create window [expr [winfo width .c] / 2] \
      [expr [winfo height .c] / 2 - $UpShift] -win .msg -anchor center
  bind . <KeyPress> {
    set StopTime $KeyTime
    if {[timeElapsed $StartTime $StopTime] > ($MinInfo * $ClockRes)} {
      set Waiting 0
    }
  }
  preventRepeat
  waitOnDelay D1

  update
  set StartTime [clock clicks -milliseconds]
  set Waiting 1
  vwait Waiting
  bind . <KeyPress> {}
  clearWindow
  destroy .msg
  if {$ResultFile != {} && $item != {}} {
    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    puts $ResultFile "$Subject [split $item :] $blockNum - - $delay"
    flush $ResultFile
  }
}

proc blockReadingItem item {
  global Sentence
  feedback 1 "blockReadingItem $item"
  blockPresentText $item $Sentence($item)
  askQuestions $item TextFont center
}

proc blockReading list {
  standardExperiment blockReadingItem $list
}

############################## Listen and Answer ##############################

proc listenAndAnswerItem item {
  global PreDelay Sentence
  feedback 1 "listenAndAnswerItem $item"
  crossHairOn
  if {$Sentence($item) != ""} {
    startDelay D1 $PreDelay
    loadSound [lindex $Sentence($item) 0] snd
    waitOnDelay D1
    playSound snd
  } else waitForKey
  crossHairOff
  askQuestions $item TextFont center
  if {$Sentence($item) != ""} {deleteSound snd}
}

proc listenAndAnswer list {
  standardExperiment listenAndAnswerItem $list
}

######################## Auditory Prime Lexical Decision ######################

proc auditoryPrimeLexicalDecisionItem item {
  global QuestProb Question Sentence PreDelay
  
  feedback 1 "APLDItem $item"
  loadSound $Sentence($item) snd
  crossHairOn
  after $PreDelay
  playSound snd
  crossHairOff
  askQuestions $item BigFont center
  deleteSound snd
}

proc auditoryPrimeLexicalDecision list {
  standardExperiment auditoryPrimeLexicalDecisionItem $list
}

############################## Speak and Listen ###############################

# SALRole is set to either Speaker or Listener.
# Use this in the introduction file for different instructions.

proc salSpeakerItem item {
  global BgColor TextColor RightShift UpShift StartTime ResultFile Subject \
      StopTime ClockRes PreDelay Sentence AudioJoinMark \
      ContinueFont PadY

  feedback 1 "salSpeakerItem $item"
  # Wait for the listener to be ready:
  command "Wait until the listener is ready."

  # Draw the screen and wait for a key press:
  set message [join $Sentence($item) "\n"]
  .c create text [expr [winfo width .c] / 2] \
      [expr [winfo height .c] / 2 - $UpShift - 50] -text "Don't Speak Yet" \
      -font BigFont -fill red -anchor s -tag tmsg
  message .msg -width [expr [winfo width .c] - 2 * $RightShift] \
      -text $message -font TextFont -bg $BgColor -fg $TextColor \
      -justify left
  .c create window [expr [winfo width .c] / 2] \
      [expr [winfo height .c] / 2 - $UpShift] -win .msg -anchor center
  .c create text [expr [winfo width .c] / 2] \
      [expr [winfo height .c] - $PadY - 40] -text \
      "When you are ready, press any key and begin speaking." \
      -font ContinueFont -fill $TextColor -anchor s -tag msg
  bind . <KeyPress> {
    set StopTime $KeyTime
    if {[timeElapsed $StartTime $StopTime] > ($MinInfo * $ClockRes)} {
      set Waiting 0
    }
  }
  preventRepeat
  update
  set StartTime [clock clicks -milliseconds]
  set Waiting 1
  vwait Waiting
  
  # Save the reading time:
  if {$ResultFile != {} && $item != {}} {
    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    puts $ResultFile "${Subject}S [split $item :] 0 wait - $delay"
    flush $ResultFile
  }

  # Record until a keypress:
  .c itemconfig tmsg -text "Recording..."
  .c itemconfig msg -text "Press any key to stop recording."
  startRecording snd
  update
  set StartTime [clock clicks -milliseconds]
  set Waiting 1
  vwait Waiting
  stopRecording snd 
  set file Results/$Subject/[string map ": $AudioJoinMark" $item].wav
  saveSound snd $file
  deleteSound snd

  # Save the speaking time:
  if {$ResultFile != {} && $item != {}} {
    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    puts $ResultFile "${Subject}S [split $item :] 1 speak - $delay"
    flush $ResultFile
  }
  bind . <KeyPress> {}
  clearWindow
  destroy .msg .press
}

proc salListenerItem item {
  global ResultFile Subject StartTime StopTime ClockRes
  feedback 1 "salListenerItem $item"
  timedMessage "Let the speaker know when you're ready." 2000 BigFont center
  crossHairOn
  waitForKey
  crossHairOff
  if {$ResultFile != {} && $item != {}} {
    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    puts $ResultFile "${Subject}L [split $item :] 0 - - $delay"
    flush $ResultFile
  }
  set s $Subject
  set Subject ${s}L
  askQuestions $item TextFont center
  set Subject $s
}

proc speakAndListen list {
  global SALRole Subject

  standardExperiment sal${SALRole}Item $list

  closeResults
  if {$SALRole == "Speaker"} {
    file rename -force Results/$Subject.dat Results/${Subject}S.dat
  } else {
    file rename -force Results/$Subject.dat Results/${Subject}L.dat
  }
}

proc speakAndListenInit {record_gain} {
  global SALRole Subject Experiment 
  package require snack
  snack::audio record_gain $record_gain
  set Experiment speakAndListen
  set type [tk_dialog .sal "Speak or Listen?" \
                "Are you the speaker or the listener?" \
                question {} Speaker Listener]
  expr srand($Subject)
  if {$type == 0} {
    set SALRole Speaker
    if {![file exists Results/$Subject]} {file mkdir Results/$Subject}
    proc speakAndListenItem item {salSpeakerItem $item}
  } else {
    set SALRole Listener
    proc speakAndListenItem item {salListenerItem $item}
  }
}


########################## StopMakingSenseReading #############################

# Press this key to indicate that the sentence is still ok:
set StopMakingSenseYesKey f
# Press this key to indicate that the sentence is not ok:
set StopMakingSenseNoKey  j
# If this is true (1), the sentence will abort on the first No press:
set StopMakingSenseAbortOnNo 1

proc stopMakingSenseReadingPresentSentence item {
  global Tag NumWords SkipKey StopTime ResultFile Subject Abort Word \
      ClockRes TextColor MaskColor ShowWords PlayWords WindowStep \
      StopMakingSenseYesKey StopMakingSenseNoKey MakesSense
  
  set Abort 0
  bind . <KeyPress-$SkipKey> {set Abort 1; set Waiting 0}
  bind . <KeyPress-$StopMakingSenseYesKey> {
    set StopTime $KeyTime
    set MakesSense 1
    set Waiting 0
  }
  preventRepeat $StopMakingSenseYesKey
  bind . <KeyPress-$StopMakingSenseNoKey> {
    set StopTime $KeyTime
    set MakesSense 0
    set Waiting 0
    if {$StopMakingSenseAbortOnNo} {set Abort 1}
  }
  preventRepeat $StopMakingSenseNoKey

  set GoodWords 0
  for {set w 0} {$w < $NumWords} {incr w} {
    if {$Tag($w) != ""} {
      set Words($GoodWords) $w
      incr GoodWords
    }
  }
  if {$PlayWords} {
    for {set g 0} {$g < $GoodWords} {incr g} {loadWordAudio $item $Words($g)}
  }
  if {$ShowWords} {
    for {set w 0} {$w < $NumWords} {incr w} {
      drawWord $w; 
      if {$Tag($w) == ""} {
        show w$w $TextColor
        if {$w > 0} {hide a[expr $w - 1]}
      } else {maskWord $w}
    }
  } else crossHairOn

  update
  set Waiting 1
  vwait Waiting

  if {!$ShowWords} crossHairOff
  
  for {set g 0} {$g < $GoodWords && !$Abort} {incr g $WindowStep} {
    set w $Words($g)
    if {$ShowWords} {showWindow $g Words}
    if {$PlayWords} {playWord $w}

    update
    set StartTime [clock clicks -milliseconds]
    set StopTime $StartTime
    set MakesSense 1
    set Waiting 1
    vwait Waiting

    set delay [expr [timeElapsed $StartTime $StopTime] / $ClockRes]
    if {$ResultFile != {} && $item != {}} {
      puts $ResultFile "$Subject [split $item :] $w [joinWords $Word($w)] $Tag($w) $delay $MakesSense"
      flush $ResultFile
    }

    if {$ShowWords} {hideWindow $g Words}
  }
  if {$PlayWords} deleteSounds
  bind . <KeyPress-$SkipKey> {}
  bind . <KeyPress-$StopMakingSenseYesKey> {}
  bind . <KeyPress-$StopMakingSenseNoKey> {}
  clearWindow
}

proc stopMakingSenseReadingItem item {
  global Sentence PreDelay
  feedback 1 "stopMakingSenseReadingItem $item"
  startDelay D1 $PreDelay
  parseSentence $Sentence($item)
  waitOnDelay D1
  stopMakingSenseReadingPresentSentence $item
  askQuestions $item TextFont center
}

proc stopMakingSenseReading list {
  standardExperiment stopMakingSenseReadingItem $list
}


############################## Initialization #################################

# Determine if it is a msec or usec clock:
set time [clock clicks -milliseconds]
after 10
if {[timeElapsed $time [clock clicks -milliseconds]] > 100} {
  set ClockRes 1000
} else {set ClockRes 1}

# Closes the results file if necessary:
proc closeResults {} {
  global ResultFile
  if {$ResultFile != {}} {
    close $ResultFile
    set ResultFile {}
  }
}

# Checks before exiting if the results file is open:
proc safeExit {} {
  global ResultFile
  if {$ResultFile != {}} {
    set answer [tk_messageBox -title "Quit Linger?" -icon question \
                    -type okcancel -default cancel \
		    -message "Are you sure you want to quit Linger?"]
    if {$answer == "cancel"} return
    closeResults
  }
  exit
}

# Hide the main window for now:
catch {wm withdraw .}
catch {console hide}

# Change to the Linger directory:
cd [file dirname $argv0]
if {![info exists env(LINGER_HOME)]} {
  if {[file readable linger.tcl]} {set HOME [pwd]} \
  else {
    puts stderr "If you run Linger from somewhere other than its home directory,"
    puts stderr "you must set the LINGER_HOME environment variable to point to the"
    puts stderr "main Linger directory."
    after 5000
    exit
  }
} else {set HOME $env(LINGER_HOME)}
cd $HOME

# Process the command-line arguments:
set Batch 0
set Exp {}
set Subject {}
set Testing 0
set CheckWrap 0
for {set i 0} {$i < $argc} {incr i} {
  set arg [lindex $argv $i]
  switch -- $arg \
      "-b" {set Batch 1} \
      "-t" {set Testing 1} \
      "-c" {set CheckWrap 1} \
      "-e" {incr i; set Exp [lindex $argv $i]} \
      "-s" {incr i; set Subject [lindex $argv $i]} \
      "-v" {incr i; set Verbosity [lindex $argv $i]} \
      default {fatalError "Unknown option: $arg"}
}

# Build the default font for windows:
if {!$Batch} {
  set WindowFont    "-family helvetica -size 12 -weight bold"
  eval font create WindowFont $WindowFont
  option add *font WindowFont userDefault
}

# Load the notification package:
cd Notifier
source notify.tcl
cd $HOME

# Get the experiment and subject:
if {$Exp != {}} {
  if {![file isdirectory Experiments/$Exp]} {
    fatalError "Experiment \"$Exp\" doesn't exist."
  }
} else {
  cd Experiments
  chooseExperiment
  cd $HOME
}

# Change to the experiment directory:
cd Experiments/$Exp
if {![file exists Results]} {file mkdir Results}

# If no subject, choose the next one:
if {$Subject == {}} {set Subject [nextSubject]}

# Load the preferences file:
if [file readable $PrefFile] {encSource $PrefFile}

# Load the sentences:
loadItems $ItemFile

if {$Continuing} {
  loadContinueItems
} else {
  # Select the test sentences:
  chooseItems $Subject
  feedback 2 "Active Items:\n$ActiveItems"

  # Order the test and filler sentences:
  if {$RandomOrder} randOrderItems else straightOrderItems
  feedback 1 "Items:\n$ExpItems"
}

if {!$Batch} {
  # Do preference-dependent setup:
  eval font create TextFont $TextFont
  if {![info exists CharHeight]} \
      {set CharHeight [font metrics TextFont -linespace]}
  eval font create BigFont $BigFont
  eval font create ContinueFont $ContinueFont
  eval font create EntryFont $EntryFont

  # Build the graphics:
  buildMainWindow
}

if {$CheckWrap} {
  catch {console show}
  update
  checkSentenceWrap
  exit
}

# Open the result file:
if {$Testing} {
  command {Warning, this is a test run.
No data will be recorded.}
} else {
  if {$Continuing} {
    set ResultFile [openFile Results/$Subject.dat "a"]
  } else {
    set ResultFile [openFile Results/$Subject.dat "w"]
    # Store the items for later continuation:
    set ExpFile [openFile Results/$Subject.itm "w"]
    foreach item $ExpItems {puts $ExpFile $item}
    close $ExpFile
  }
}

# Run the introduction script:
if [file readable $IntroFile] {encSource $IntroFile}

# Send initial notification:
notifyExperimenter "Subject $Subject is starting $Exp"

# Run the experiment:
$Experiment $ExpItems

# Close the result file:
closeResults

# Run the conclusion script:
if [file readable $ConclFile] {encSource $ConclFile}

exit
