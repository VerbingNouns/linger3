# toc.tcl --
#
# This file contains routines to send toc messages
# and decode incoming message and call registered callbacks.
# Most routines are not commented, see doc/Protocol instead.
#
# $Revision: 1.48 $

# Copyright (c) 1998-9 America Online, Inc. All Rights Reserved.
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

# OUTGOING:
# Since we handle having multiple toc connections the
# first argument to ALL toc_ methods is the connection
# "name".   This name doesn't have to be the screenname
# used by the connection, but that is usually a convient
# name to use.  We ALWAYS normalize the connection name 
# before using it.
#
# We have matching toc_ methods for all the toc_ methods mentioned
# in the doc/Protocol file, with the exact same arguments with two exceptions:
#    1) An extra first argument of the connection name (see above)
#    2) All variable length arguments are done with a tcl list
#
# All outgoing messages can be registered for using toc_register_func.
# The arguments and the function name to register for are the same
# as the toc function you are calling.
#
# INCOMING:
# Again since we support multiple toc connections all incoming
# message have a connection name.  You first must register
# what procedure you want called when a particular toc message
# is received.  You do this by calling toc_register_func
#
# We support all the incoming messages in doc/Protocol,
# and parse the arguments out before calling the registered
# procedure.  Again the first argument to the registered
# procedure will be the connection name, and variable
# length arguments are turned in to lists.

# Load the low level sflap routines.
source sflap.tcl

# Load the utility routines
source util.tcl

# toc_open -- 
#     Utility function that opens the sflap connection and sends 
#     the toc_signon message.
#
# Arguments:
#     connName - name to give the SFLAP connection
#     tochost  - hostname of TOC server
#     tocport  - port of TOC server
#     authhost - hostname of OSCAR authorizer
#     authport - port of OSCAR authorizer
#     sn       - user's screen name
#     pw       - user's password
#     lang     - language to use.
#     version  - client version string
#     proxy    - proxy to use
proc toc_open {connName tochost tocport authhost authport sn pw lang 
              {version "toc.tcl Unknown"} {proxy ""}} {

    # Have extra updates here for when toc.tcl is used for stress testing.
    update
    sflap::connect [normalize $connName] $tochost $tocport [normalize $sn] \
        $proxy
    update
    toc_signon $connName $authhost $authport $sn $pw $lang $version
    update

    incr ::TOCSTATS(toc_open)
}

#
# toc_close --
#     Just a matching for toc_open.  Close the TOC and SFLAP connection.
#
# Arguments:
#     connName - SFLAP connection name.

proc toc_close {connName} {
    set norm [normalize $connName]

    sflap::close $norm

    if {$::TOCSTATS($norm,ONLINE)} {
        incr ::TOCSTATS(ONLINE) -1
    } else {
        incr ::TOCSTATS(TOTAUTHFAIL)
    }

    unset ::TOCSTATS($norm,ONLINE)

    incr ::TOCSTATS(CONNECTED) -1
    incr ::TOCSTATS(toc_close)
}

# toc_register_func --
#     Register the proc to be called
#     when certain messages are received.  A connName of
#     "*" implies all connections should use that function
#
# Arguments:
#     connName - name of SFLAP connection or "*" = all
#     cmd      - the PROTOCOL cmd
#     func     - the callback that is executed when cmd is received.

proc toc_register_func {connName cmd func} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    }

    lappend ::FUNCS($connName,$cmd) $func

    incr ::TOCSTATS(toc_register_func)
}

# toc_unregister_func --
#     Unregister the proc to be called when certain messages are received.
#     A connName of "*" implies all connections should unregister that function
#
# Arguments:
#     connName - name of SFLAP connection or "*" = all
#     cmd      - the PROTOCOL cmd
#     func     - the callback that is executed when cmd is received.

proc toc_unregister_func {connName cmd func} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    }

    set i [lsearch -exact $::FUNCS($connName,$cmd) $func]
    if {$i != -1} {
        set ::FUNCS($connName,$cmd) [lreplace $::FUNCS($connName,$cmd) $i $i]
    }

    incr ::TOCSTATS(toc_unregister_func)
}

# toc_unregister_all --
#     Remove all the proc registrations for a particular connection.
#
# Arguments:
#     connName - name of SFLAP connection or "*" = all

proc toc_unregister_all {connName} {
    if {$connName != "*"} {
        set connName [normalize $connName]
    } else {
        set connName "\\\*"
    }

    foreach i [array names ::FUNCS "$connName,*"] {
        unset ::FUNCS($i)
    }

    incr ::TOCSTATS(toc_unregister_all)
}

#******************************************************
#******************OUTGOING PROTOCOL ******************
#******************************************************

# These are documented in the PROTOCOL document

proc toc_signon {connName authhost authport sn pw lang 
                 {version "toc.tcl Unknown"}} {

    if {[string  match "0x0x*" $pw]} {
        set cpw [string range $pw 2 end]
    } else {
        set cpw [roast_password $pw]
    }

    set norm [normalize $connName]

    set ::TOCSTATS($norm,ONLINE) 0

    set result [sflap::send $norm "toc_signon $authhost $authport \
                [normalize $sn] $cpw $lang [encode $version]"]

    if {$result} {
        incr ::TOCSTATS(CONNECTED)
        incr ::TOCSTATS(TOTCONNECTED)
    }
    incr ::TOCSTATS(toc_signon)

    return $result
}

proc toc_init_done {connName} {
    sflap::send [normalize $connName] "toc_init_done"

    set funcs [p_getFuncList $connName toc_init_done]
    foreach func $funcs {
        $func $connName
    }

    incr ::TOCSTATS(toc_init_done)
}

proc toc_send_im {connName nick msg {auto ""}} {
    sflap::send [normalize $connName] "toc_send_im [normalize $nick]\
                                       [encode $msg] $auto" 

    set funcs [p_getFuncList $connName toc_send_im]
    foreach func $funcs {
        $func $connName $nick $msg $auto
    }

    incr ::TOCSTATS(toc_send_im)
}

proc toc_add_buddy {connName blist} {
    set str "toc_add_buddy"
    foreach i $blist {
        append str " " [normalize $i]
    }
    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_add_buddy]
    foreach func $funcs {
        $func $connName $blist
    }

    incr ::TOCSTATS(toc_add_buddy)
}

proc toc_remove_buddy {connName blist} {
    set str "toc_remove_buddy"
    foreach i $blist {
        append str " " [normalize $i]
    }
    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_remove_buddy]
    foreach func $funcs {
        $func $connName $blist
    }

    incr ::TOCSTATS(toc_remove_buddy)
}

proc toc_set_config {connName config} {
    sflap::send [normalize $connName] "toc_set_config {$config}" 

    set funcs [p_getFuncList $connName toc_set_config]
    foreach func $funcs {
        $func $connName $config
    }

    incr ::TOCSTATS(toc_set_config)
}

proc toc_set_away {connName {msg ""}} {

    if {[string length $msg] == 0} {
        sflap::send [normalize $connName] "toc_set_away" 
    } else {
        sflap::send [normalize $connName] "toc_set_away [encode $msg]" 
    }

    set funcs [p_getFuncList $connName toc_set_config]
    foreach func $funcs {
        $func $connName $msg
    }

    incr ::TOCSTATS(toc_set_away)
}

proc toc_evil {connName nick {anon F}} {
    if {$anon == "T" || $anon == "anon"} {
        sflap::send [normalize $connName] "toc_evil [normalize $nick] anon" 
    } else {
        sflap::send [normalize $connName] "toc_evil [normalize $nick] norm" 
    }

    set funcs [p_getFuncList $connName toc_evil]
    foreach func $funcs {
        $func $connName $nick $anon
    }

    incr ::TOCSTATS(toc_evil)
}

proc toc_add_permit {connName {plist {}}} {
    set str "toc_add_permit"
    foreach i $plist {
        append str " " [normalize $i]
    }
    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_add_permit]
    foreach func $funcs {
        $func $connName $plist
    }

    incr ::TOCSTATS(toc_add_permit)
}

proc toc_add_deny {connName {dlist {}}} {
    set str "toc_add_deny"
    foreach i $dlist {
        append str " " [normalize $i]
    }
    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_add_deny]
    foreach func $funcs {
        $func $connName $dlist
    }

    incr ::TOCSTATS(toc_add_deny)
}

proc toc_chat_join {connName exchange loc} {
    sflap::send [normalize $connName] "toc_chat_join $exchange [encode $loc]"

    set funcs [p_getFuncList $connName toc_chat_join]
    foreach func $funcs {
        $func $connName $exchange $loc
    }

    incr ::TOCSTATS(toc_chat_join)
}

proc toc_chat_send {connName roomid msg} {
    sflap::send [normalize $connName] "toc_chat_send $roomid [encode $msg]"

    set funcs [p_getFuncList $connName toc_chat_send]
    foreach func $funcs {
        $func $connName $roomid $msg
    }

    incr ::TOCSTATS(toc_chat_send)
}

proc toc_chat_whisper {connName roomid user msg} {
    sflap::send [normalize $connName] "toc_chat_whisper $roomid\
                                       [normalize $user] [encode $msg]"

    set funcs [p_getFuncList $connName toc_chat_whisper]
    foreach func $funcs {
        $func $connName $roomid $user $msg
    }

    incr ::TOCSTATS(toc_chat_whisper)
}

proc toc_chat_invite {connName roomid msg people} {
    sflap::send [normalize $connName] "toc_chat_invite $roomid\
                                       [encode $msg] $people"

    set funcs [p_getFuncList $connName toc_chat_invite]
    foreach func $funcs {
        $func $connName $roomid $msg $people
    }

    incr ::TOCSTATS(toc_chat_invite)
}

proc toc_chat_leave {connName roomid} {
    sflap::send [normalize $connName] "toc_chat_leave $roomid"

    set funcs [p_getFuncList $connName toc_chat_leave]
    foreach func $funcs {
        $func $connName $roomid
    }

    incr ::TOCSTATS(toc_chat_leave)
}

proc toc_chat_accept {connName roomid} {
    sflap::send [normalize $connName] "toc_chat_accept $roomid"

    set funcs [p_getFuncList $connName toc_chat_accept]
    foreach func $funcs {
        $func $connName $roomid
    }

    incr ::TOCSTATS(toc_chat_accept)
}

proc toc_get_info {connName nick} {
    sflap::send [normalize $connName] "toc_get_info [normalize $nick]" 
    p_simpleFunc $connName $nick toc_get_info
    incr ::TOCSTATS(toc_get_info)
}

proc toc_set_info {connName info} {
    sflap::send [normalize $connName] "toc_set_info [encode $info]" 

    p_simpleFunc $connName $info toc_set_info

    incr ::TOCSTATS(toc_set_info)
}

proc toc_set_idle {connName idlesecs} {
    sflap::send [normalize $connName] "toc_set_idle $idlesecs" 

    set funcs [p_getFuncList $connName toc_set_idle]
    foreach func $funcs {
        $func $connName $idlesecs
    }

    incr ::TOCSTATS(toc_set_idle)
}

proc toc_get_dir {connName nick} {
    sflap::send [normalize $connName] "toc_get_dir [normalize $nick]"
    p_simpleFunc $connName $nick toc_get_dir

    incr ::TOCSTATS(toc_get_dir)
}

proc toc_set_dir {connName dir_info} {
    sflap::send [normalize $connName] "toc_set_dir [encode $dir_info]"
    p_simpleFunc $connName $dir_info toc_set_dir

    incr ::TOCSTATS(toc_set_dir)
}

proc toc_dir_search {connName dir_info} {
    sflap::send [normalize $connName] "toc_dir_search [encode $dir_info]"
    p_simpleFunc $connName $dir_info toc_dir_search

    incr ::TOCSTATS(toc_dir_search)
}

proc toc_set_caps {connName clist} {
    set str "toc_set_caps"
    foreach i $clist {
        append str " " $i
    }
    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_set_caps]
    foreach func $funcs {
        $func $connName $clist
    }

    incr ::TOCSTATS(toc_set_caps)
}

proc toc_rvous_accept {connName nick cookie service tlvlist} {
    set str "toc_rvous_accept [normalize $nick] $cookie $service" 

    foreach i $tlvlist {
        append str " " $i
    }

    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_rvous_accept]
    foreach func $funcs {
        $func $connName $nick $cookie $service $tlvlist
    }

    incr ::TOCSTATS(toc_rvous_accept)
}

proc toc_rvous_cancel {connName nick cookie service tlvlist} {
    set str "toc_rvous_cancel [normalize $nick] $cookie $service" 

    foreach i $tlvlist {
        append str " " $i
    }

    sflap::send [normalize $connName] $str

    set funcs [p_getFuncList $connName toc_rvous_cancel]
    foreach func $funcs {
        $func $connName $nick $cookie $service $tlvlist
    }

    incr ::TOCSTATS(toc_rvous_cancel)
}

proc toc_format_nickname {connName new_name} {
    sflap::send [normalize $connName] "toc_format_nickname {$new_name}"

    set funcs [p_getFuncList $connName toc_format_nickname]
    foreach func $funcs {
        $func $connName $new_name
    }

    incr ::TOCSTATS(toc_format_nickname)
}

proc toc_change_passwd {connName old_passwd new_passwd} {
    sflap::send [normalize $connName] "toc_change_passwd {$old_passwd} {$new_passwd}"

    set funcs [p_getFuncList $connName toc_change_passwd]
    foreach func $funcs {
        $func $connName $old_passwd $new_passwd
    }

    incr ::TOCSTATS(toc_change_passwd)
}

#******************************************************
#******************INCOMING PROTOCOL ******************
#******************************************************

# These are documented in the PROTOCOL document

proc p_getFuncList {connName func} {
    if {[catch {set al $::FUNCS(*,$func)}] != 0} {
        set al [list]
    }

    if {[catch {set l $::FUNCS($connName,$func)}] == 0} {
        return [concat $al $l]
    }

    return $al
}

proc p_simpleFunc {connName data func} {
    set funcs [p_getFuncList $connName $func]
    foreach func $funcs {
        $func $connName $data
    }
}

proc scmd_SIGN_ON {connName data} {
    incr ::TOCSTATS(SIGN_ON)

    if {! $::TOCSTATS($connName,ONLINE)} {
        set ::TOCSTATS($connName,ONLINE) 1
        incr ::TOCSTATS(ONLINE)
        incr ::TOCSTATS(TOTONLINE)
    }
    p_simpleFunc $connName $data SIGN_ON
}

proc scmd_CONFIG {connName data} {
    incr ::TOCSTATS(CONFIG)

    p_simpleFunc $connName $data CONFIG
}

proc scmd_NICK {connName data} {
    incr ::TOCSTATS(NICK)

    p_simpleFunc $connName $data NICK
}

proc scmd_IM_IN {connName data} {
    incr ::TOCSTATS(IM_IN)

    set args [split $data ":"]
    set source [lindex $args 0]
    set sourcel [string length $source]
    set auto [lindex $args 1]
    set msg [string range $data [expr $sourcel + 3] end]

    set funcs [p_getFuncList $connName IM_IN]
    foreach func $funcs {
        $func $connName $source $msg $auto
    }
}

proc scmd_UPDATE_BUDDY {connName data} {
    incr ::TOCSTATS(UPDATE_BUDDY)

    set args [split $data ":"]
    set user   [lindex $args 0]
    set online [lindex $args 1]
    set evil   [lindex $args 2]
    set signon [lindex $args 3]
    set idle   [lindex $args 4]
    set uclass [lindex $args 5]

    set funcs [p_getFuncList $connName UPDATE_BUDDY]
    foreach func $funcs {
        $func $connName $user $online $evil $signon $idle $uclass
    }
}

proc scmd_ERROR {connName data} {
    incr ::TOCSTATS(ERROR)

    set args [split $data ":"]
    set code [string range $args 0 2]
    if {[string length $data] > 4} {
        set args [string range $args 4 end]
    } else {
        set args ""
    }

    set funcs [p_getFuncList $connName ERROR]
    foreach func $funcs {
        $func $connName $code $args
    }
}

proc scmd_EVILED {connName data} {
    incr ::TOCSTATS(EVILED)

    set args [split $data ":"]
    set level [lindex $args 0]
    set eviler [lindex $args 1]

    set funcs [p_getFuncList $connName EVILED]
    foreach func $funcs {
        $func $connName $level $eviler
    }
}

proc scmd_CHAT_JOIN {connName data} {
    incr ::TOCSTATS(CHAT_JOIN)

    set args [split $data ":"]
    set id [lindex $args 0]
    set loc [lindex $args 1]

    set funcs [p_getFuncList $connName CHAT_JOIN]
    foreach func $funcs {
        $func $connName $id $loc
    }
}

proc scmd_CHAT_IN {connName data} {
    incr ::TOCSTATS(CHAT_IN)

    set args [split $data ":"]
    set id [lindex $args 0]
    set idl [string length $id]
    set source [lindex $args 1]
    set sourcel [string length $source]
    set whisper [lindex $args 2]
    set msg [string range $data [expr $idl + $sourcel + 4] end]

    set funcs [p_getFuncList $connName CHAT_IN]
    foreach func $funcs {
        $func $connName $id $source $whisper $msg
    }
}

proc scmd_CHAT_UPDATE_BUDDY {connName data} {
    incr ::TOCSTATS(CHAT_UPDATE_BUDDY)

    set args [split $data ":"]
    set id [lindex $args 0]
    set online [lindex $args 1]
    set argsl [llength $args]

    set blist [list]
    for {set i 2} {$i < $argsl} {incr i} {
        set p [lindex $args $i]
        lappend blist $p
    }

    set funcs [p_getFuncList $connName CHAT_UPDATE_BUDDY]
    foreach func $funcs {
        $func $connName $id $online $blist
    }
}

proc scmd_CHAT_INVITE {connName data} {
    incr ::TOCSTATS(CHAT_INVITE)

    set args [split $data ":"]
    set loc [lindex $args 0]
    set locl [string length $loc]
    set id [lindex $args 1]
    set idl [string length $id]
    set sender [lindex $args 2]
    set senderl [string length $sender]
    set msg [string range $data [expr $locl + $idl + $senderl + 3] end]

    set funcs [p_getFuncList $connName CHAT_INVITE]
    foreach func $funcs {
        $func $connName $loc $id $sender $msg
    }
}

proc scmd_CHAT_LEFT {connName data} {
    incr ::TOCSTATS(CHAT_LEFT)

    p_simpleFunc $connName $data CHAT_LEFT
}

proc scmd_GOTO_URL {connName data} {
    incr ::TOCSTATS(GOTO_URL)

    set args [split $data ":"]
    set window [lindex $args 0]
    set windowl [string length $window]
    incr windowl
    set url [string range $data $windowl end]

    set funcs [p_getFuncList $connName GOTO_URL]
    foreach func $funcs {
        $func $connName $window $url 
    }
}

proc scmd_PAUSE {connName data} {
    incr ::TOCSTATS(PAUSE)

    p_simpleFunc $connName $data PAUSE
}

proc scmd_CONNECTION_CLOSED {connName reason} {
    incr ::TOCSTATS(CONNECTION_CLOSED)

    p_simpleFunc $connName $reason CONNECTION_CLOSED
    if { [info exists ::TOCSTATS($connName,ONLINE)] } {
        if {$::TOCSTATS($connName,ONLINE)} {
            incr ::TOCSTATS(ONLINE) -1
        } else {
            incr ::TOCSTATS(TOTAUTHFAIL)
        }
        unset ::TOCSTATS($connName,ONLINE)
    }
    incr ::TOCSTATS(CONNECTED) -1
}

proc scmd_DIR_STATUS {connName data} {
    incr ::TOCSTATS(DIR_STATUS)

    set args [split $data ":"]
    set code [string range $args 0 2]
    if {[string length $data] > 4} {
        set args [string range $args 4 end]
    } else {
        set args ""
    }

    set funcs [p_getFuncList $connName DIR_STATUS]
    foreach func $funcs {
        $func $connName $code $args
    }
}

proc scmd_ADMIN_NICK_STATUS {connName data} {
    incr ::TOCSTATS(ADMIN_NICK_STATUS)

    set args [split $data ":"]
    set code [string range $args 0 2]
    if {[string length $data] > 4} {
        set args [string range $args 4 end]
    } else {
        set args ""
    }

    set funcs [p_getFuncList $connName ADMIN_NICK_STATUS]
    foreach func $funcs {
        $func $connName $code $args
    }
}

proc scmd_ADMIN_PASSWD_STATUS {connName data} {
    incr ::TOCSTATS(ADMIN_PASSWD_STATUS)

    set args [split $data ":"]
    set code [string range $args 0 2]
    if {[string length $data] > 4} {
        set args [string range $args 4 end]
    } else {
        set args ""
    }

    set funcs [p_getFuncList $connName ADMIN_PASSWD_STATUS]
    foreach func $funcs {
        $func $connName $code $args
    }
}

proc scmd_RVOUS_PROPOSE {connName data} {
    incr ::TOCSTATS(RVOUS_PROPOSE)

    set args [split $data ":"]

    set user [lindex $args 0]
    set uuid [lindex $args 1]
    set cookie [lindex $args 2]
    set seq [lindex $args 3]
    set rip [lindex $args 4]
    set pip [lindex $args 5]
    set vip [lindex $args 6]
    set port [lindex $args 7]

    set ltlvs ""

    set largs [llength $args]
    set i 8
    while {$i < $largs} {
        set num [lindex $args $i]
        incr i
        set value [lindex $args $i]
        incr i

        lappend ltlvs $num
        lappend ltlvs [fromBase64 $value]
    }

    set funcs [p_getFuncList $connName RVOUS_PROPOSE]
    foreach func $funcs {
        $func $connName $user $uuid $cookie $seq $rip $pip $vip $port $ltlvs
    }
}

# We keep stats that are used by the testing tools.  These aren't
# need for TiK, so I guess we could remove them. :-)
set ::TOCSTATS(toc_open) 0
set ::TOCSTATS(toc_close) 0
set ::TOCSTATS(toc_register_func) 0
set ::TOCSTATS(toc_unregister_func) 0
set ::TOCSTATS(toc_unregister_all) 0
set ::TOCSTATS(TOTCONNECTED) 0
set ::TOCSTATS(CONNECTED) 0
set ::TOCSTATS(TOTONLINE) 0
set ::TOCSTATS(ONLINE) 0
set ::TOCSTATS(TOTAUTHFAIL) 0
set ::TOCSTATS(toc_signon) 0
set ::TOCSTATS(toc_init_done) 0
set ::TOCSTATS(toc_send_im) 0
set ::TOCSTATS(toc_add_buddy) 0
set ::TOCSTATS(toc_remove_buddy) 0
set ::TOCSTATS(toc_set_config) 0
set ::TOCSTATS(toc_set_away) 0
set ::TOCSTATS(toc_evil) 0
set ::TOCSTATS(toc_add_permit) 0
set ::TOCSTATS(toc_add_deny) 0
set ::TOCSTATS(toc_chat_join) 0
set ::TOCSTATS(toc_chat_send) 0
set ::TOCSTATS(toc_chat_whisper) 0
set ::TOCSTATS(toc_chat_invite) 0
set ::TOCSTATS(toc_chat_leave) 0
set ::TOCSTATS(toc_chat_accept) 0
set ::TOCSTATS(toc_get_info) 0
set ::TOCSTATS(toc_set_info) 0
set ::TOCSTATS(toc_set_idle) 0
set ::TOCSTATS(toc_get_dir) 0
set ::TOCSTATS(toc_set_dir) 0
set ::TOCSTATS(toc_dir_search) 0
set ::TOCSTATS(toc_set_caps) 0
set ::TOCSTATS(toc_rvous_accept) 0
set ::TOCSTATS(toc_rvous_cancel) 0
set ::TOCSTATS(toc_format_nickname) 0
set ::TOCSTATS(toc_change_passwd) 0

set ::TOCSTATS(SIGN_ON) 0
set ::TOCSTATS(CONFIG) 0
set ::TOCSTATS(NICK) 0
set ::TOCSTATS(IM_IN) 0
set ::TOCSTATS(UPDATE_BUDDY) 0
set ::TOCSTATS(ERROR) 0
set ::TOCSTATS(EVILED) 0
set ::TOCSTATS(CHAT_JOIN) 0
set ::TOCSTATS(CHAT_IN) 0
set ::TOCSTATS(CHAT_UPDATE_BUDDY) 0
set ::TOCSTATS(CHAT_INVITE) 0
set ::TOCSTATS(CHAT_LEFT) 0
set ::TOCSTATS(GOTO_URL) 0
set ::TOCSTATS(PAUSE) 0
set ::TOCSTATS(CONNECTION_CLOSED) 0
set ::TOCSTATS(DIR_STATUS) 0
set ::TOCSTATS(RVOUS_PROPOSE) 0
set ::TOCSTATS(ADMIN_NICK_STATUS) 0
set ::TOCSTATS(ADMIN_PASSWD_STATUS) 0
