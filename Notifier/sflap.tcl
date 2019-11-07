# sflap.tcl --
#
# SFLAP is just FLAP with the special String TOC 
# support on top.  Basically all outgoing messages
# are null terminated and all incoming messages have
# arguments seperated by colons.
#
# $Revision: 1.47 $

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

# All SFLAP methods take a name given to the connection.
# This allows multiple connections open at the
# same time if desired.  If sflap::connect
# is used, the connection is connsidered in
# client mode.  If sflap::listen is used, the
# incoming connection is considered to be in
# server mode.  A single app can have both
# types of connections.
#
# Client Mode:
# When data is received we call a method named 
# scmd_<COMMAND_NAME>, where <COMMAND_NAME> is the
# everything before the first colon in the message
# received.  The method is passed two parameters,
# the name given to the SFLAP connection and the 
# arguments to the command, but not the command itself.
#
# Server Mode:
# When data is received the method scmd_SERVER_MSG
# is called with the arguments of user name and
# the command.


# Check to make sure we are using some form of tcl 8.
if {[string index [info tclversion] 0] != 8} {
    puts "\n\n*** Sorry, Tcl/Tk 8.x required, you have version\
        [info tclversion]. ***"
    puts "The full path of the currently running tcl is [info nameofexecutable]\n"
    puts "You can download Tcl/Tk version 8.x from http://www.scriptics.com\n"
    exit 1;
}

# Create sflap namespace
namespace eval sflap {
    namespace export connect send peerinfo close socks listen
    variable debug_level 0
    variable server
    variable info
}

# sflap::connect --
#     Create a new SFLAP connection.  We try and connect to the
#     server many times if certain errors occur.  This is because
#     this code is used for stress testing, and certain platforms
#     return strange errors, and we only want to fail if we have to.
#
# Arguments:
#     name  - name to give the SFLAP connection
#     host  - host the server is running on
#     port  - port the server is listening on
#     sname - screen name used in the FLAP SIGNON frame.
#     proxy - function to call to create the socket,
#             otherwise the tcl function "socket" is called.
#
proc sflap::connect {name host port sname {proxy ""}} {

    # Connect to the TOC server
    if {$sflap::debug_level > 0} {
        puts "$name:Connecting to $host $port"
    }

    if {$proxy == ""} {
        set messages 0
        while {1} {
            # Since we use the same code for stress testing we will need to
            # pause sometimes if no local ports are available.
            set err [catch {set fd [socket $host $port]}]

            if { $err } {
                if {([lindex $::errorCode 0] == "POSIX")} {
                    set messages [expr $messages + 1]
                    if {$messages < 4} {
                        if {([lindex $::errorCode 1] == "EADDRNOTAVAIL")} {
                            if {$sflap::debug_level > 0} {
                                puts "Pausing since no local ports\
                                      available, this is normal."
                            }
                        } elseif {([lindex $::errorCode 1] == "EMFILE")} {
                            puts "Pausing since not enough file descriptors\
                                  are available, this is NOT normal.\
                                  Try using ulimit to increase the number\
                                  of file descriptors available."
                        } elseif {([lindex $::errorCode 1] == "EHOSTUNREACH") || 
                                  ([lindex $::errorCode 1] == "ENETUNREACH")} {
                            puts "Pausing, can't reach TOC server.  This probably means\
                                  you are behind a firewall or you have the wrong\
                                  TOC server settings.  You are trying to use $host, try\
                                  connecting to it using telnet.  On some systems this\
                                  MIGHT mean you are out of file descriptors."
                        } else {
                            # Some other socket error.
                            puts "$::errorCode"
                            puts "$::errorInfo"
                            error "Unknown Socket Error!  This is NOT a bug with TiK!"
                        }
                    }

                    # This will pause us for a total of one second.
                    # But we call update every 100ms so events are processed.
                    for { set i 0} {$i < 10} {incr i} {
                        update
                        after 100
                        update
                    }
                    continue;
                }

                # Some other socket error.
                puts "$::errorCode"
                puts "$::errorInfo"
                error "Socket Error!"
            } else {
                # We connected!
                break
            }
        }
    } else {
        # We assume the proxy function will take care of retries if needed
        set fd [$proxy $host $port $sname]
        if {$fd == 0} {
            return
        }
    }
    fconfigure $fd -translation binary

    incr ::SFLAPSTATS(ONLINE)
    incr ::SFLAPSTATS(TOTONLINE)
    # Connected! Setup the information on this socket
    set sflap::info($name,inseq) 0
    set sflap::info($name,fd) $fd
    set sflap::info($name,isclient) 1
    set seq [expr int(0xffff * rand())]

    # This turns the web connection into a SFLAP connection
    puts -nonewline $fd "FLAPON\r\n\r\n"
    flush $fd
    fileevent $fd readable [list sflap::receive $name]

    # wait for the FLAP SIGNON packet to be received.
    vwait sflap::info($name,FLAP_SIGNON)

    # Send our FLAP SIGNON packet
    set nlen [string length $sname]
    set dlen [expr 8+$nlen]
    set data [binary format "acSSISSa*" "*" 1 $seq $dlen 1 1 $nlen $sname]
    puts -nonewline $fd $data
    if { [ catch {flush $fd}] !=0 } {
      sflap::close $name
      scmd_CONNECTION_CLOSED $name EOF
    }

    # Ok we are pretty much all set
    set sflap::info($name,outseq) [expr ($seq + 1) & 0xffff]
    unset sflap::info($name,FLAP_SIGNON)
}

# sflap::accept --
#     Internal routine that is called when we are accepting
#     a new connection.  This routine handles the FLAP signon
#     process.
#
# Arguments:
#     fd   - the socket name
#     ip   - the client's ip address
#     port - the client's port

proc sflap::accept {fd ip port} {

    incr ::SFLAPSTATS(ONLINE)
    incr ::SFLAPSTATS(TOTONLINE)

    set seq [expr int(0xffff * rand())]

    # Read the FLAPON, eventually need to also handle GET requests.
    set line [gets $fd]
    if {$line != "FLAPON"} {
        close $fd
        return
    }
    gets $fd

    fconfigure $fd -translation binary
    fileevent $fd readable [list sflap::sreceive $fd]

    # Send our FLAP SIGNON packet
    set data [binary format "acSSI" "*" 1 $seq 4 1]
    puts -nonewline $fd $data
    flush $fd

    # wait for the FLAP SIGNON packet to be received.
    vwait sflap::info(server,$fd,FLAP_SIGNON)

    # Connected! Setup the information on this socket
    set name [string range [lindex $sflap::info(server,$fd,FLAP_SIGNON) 1] 8 end]
    set sflap::info($name,inseq) [lindex $sflap::info(server,$fd,FLAP_SIGNON) 0]
    set sflap::info($name,fd) $fd
    set sflap::info($name,isclient) 0
    fileevent $fd readable [list sflap::receive $name]

    # Ok we are pretty much all set
    set sflap::info($name,outseq) [expr ($seq + 1) & 0xffff]
    unset sflap::info(server,$fd,FLAP_SIGNON)
}

# sflap::listen --
#     Listen for incoming SFLAP connections.  You can call
#     this routine multiple times, although sflap::server
#     will only have the last server sockets name.
#
# Arguments:
#     port  - The port to listen for incoming connections on.
proc sflap::listen {port} {
    set sflap::server [socket -server sflap::accept $port]
}

# sflap::send --
#     Send a string command on the SFLAP connection.  We add the
#     SFLAP header and the terminating null to the data if in
#     client mode.
#
# Arguments:
#     name - The name of the SFLAP connection to use
#     cmd  - The command to send
#
proc sflap::send {name cmd} {
    incr ::SFLAPSTATS(sflap_send)

    if {$sflap::debug_level > 1} {
        puts "$name:sflap::send($cmd)"
    }

    if {![info exists sflap::info($name,fd)]} {
        puts "sflap::send \"$name\" is not online"
        return 0
    }

    set len [string length $cmd]

    if  {$sflap::info($name,isclient)} {
        incr len
        set data [binary format "acSSa*c" "*" 2 \
            $sflap::info($name,outseq) $len $cmd 0]
    } else {
        set data [binary format "acSSa*" "*" 2 \
            $sflap::info($name,outseq) $len $cmd]
    }
    set sflap::info($name,outseq) [expr ($sflap::info($name,outseq) + 1) & 0xffff]
    puts -nonewline $sflap::info($name,fd) $data
    flush $sflap::info($name,fd)
    return 1
}

#
# sflap::peerinfo --
#     Return the peer information about the socket associated 
#     with name.  Needed for GOTO_URL which needs to know the host
#     we are connected to
#
# Arguments:
#     name - The name of the SFLAP connection to use

proc sflap::peerinfo {name} {
    return [fconfigure $sflap::info($name,fd) -peername]
}

#
# sflap::receive --
#     Private method that is called when there is data ready to be read 
#     on the SFLAP connection.  We always block and read an entire frame 
#     at a time.  Even though blocking might slow us down a little, it is 
#     easier then buffering it ourselfs.
#
# Arguments:
#     name - The name of the SFLAP connection to check for input on

proc sflap::receive {name} {
    incr ::SFLAPSTATS(sflap_receive)

    set fd $sflap::info($name,fd)

    # Read the header and decode it
    if { [catch {set header [read $fd 6]}] !=0 || [eof $fd]} {
        sflap::close $name
        scmd_CONNECTION_CLOSED $name EOF
        return
    }
    binary scan $header "acSS" marker type seq len
    set seq [expr $seq & 0x0000ffff]
    set data [read $fd $len]

    if {$sflap::debug_level > 1} {
        set headerf [format "%s type=%d seq=%-5d len=%-3d" \
                     $marker $type $seq $len]
        puts "$name:$headerf =>$data<="
    }

    # Set the inseq right away since the callback methods might
    # not be atomic, and other events might fire.
    set inseq [expr ($sflap::info($name,inseq) + 1) & 0x0000ffff]
    set sflap::info($name,inseq) $seq

    # Now handle the message
    if { $type == 1 } {
        set sflap::info($name,FLAP_SIGNON) $data
    } elseif { $type == 2 } {
        if {$inseq != $seq} {
            puts "$name:Bad incoming sequence number: $seq expecting $inseq"
            sflap::close $name
            scmd_CONNECTION_CLOSED $name FLAPSEQ
            return
        }

        if  {!$sflap::info($name,isclient)} {
            scmd_SERVER_MSG $name $data
            return
        }

        set colon [string first ":" $data]
        if {$colon == -1} {
            set cmd $data
            set data ""
        } else {
            incr colon -1
            set cmd [string range $data 0 $colon]
            incr colon 2
            set data [string range $data $colon end]
        }
        if {[catch {scmd_$cmd $name $data}] != 0} {
            puts "$name:$::errorInfo"
        }
    } elseif { $type == 4 } {
        sflap::close $name
    }
    # All other frame types are ignored.
}

#
# sflap::sreceive --
#     Private method that is called when there is data ready to be read 
#     for the first frame of a server SFLAP connection.
#
# Arguments:
#     fd - The fd of the SFLAP connection to check for input on

proc sflap::sreceive {fd} {
    incr ::SFLAPSTATS(sflap_receive)

    # Read the header and decode it
    if { [catch {set header [read $fd 6]}] !=0 || [eof $fd]} {
        close $fd
        scmd_CONNECTION_CLOSED $name EOF
        return
    }
    binary scan $header "acSS" marker type seq len
    set seq [expr $seq & 0x0000ffff]
    set data [read $fd $len]


    if {$sflap::debug_level > 1} {
        set headerf [format "%s type=%d seq=%-5d len=%-3d" \
                     $marker $type $seq $len]
        puts "$fd:$headerf =>$data<="
    }

    # Now handle the message
    if { $type == 1 } {
        set sflap::info(server,$fd,FLAP_SIGNON) [list $seq $data]
        return
    } 

    # All other frame types are errors.
    sflap::close $name
    scmd_CONNECTION_CLOSED $name BAD
    return
}

# sflap::close --
#     Close the SFLAP connection.  We do NOT call the connection
#     closed callback.
#
# Arguments:
#     name - The name of the SFLAP connection to close

proc sflap::close {name} {
    set fd $sflap::info($name,fd)
    catch {fileevent $fd readable ""}
    catch {::close $fd}

    incr ::SFLAPSTATS(ONLINE) -1

    foreach i [array names sflap::info "$name,*"] {
        unset sflap::info($i)
    }
}

# sflap::socks --
#     Connect via socks proxy.  Realy this probably shouldn't be here,
#     but not sure where it should be.
#
# Arguments:
#     host  - The ip of the host we are connecting to through socks
#     port  - The port we are connecting to through socks
#     sname - Our user name, since some proxies might need it.

proc sflap::socks { host port sname } {
    if { ! [info exists ::SOCKSHOST] || ! [info exists ::SOCKSPORT]} {
        error "SOCKS ERROR: Please set SOCKSHOST and SOCKSPORT\n"
    }

    if { "$host" == "10.10.10.10"} {
        error "SOCKS ERROR: You must set TOC(production,host) to\
               the IP address of toc.oscar.aol.com\n"
    }

    # Check to make sure the toc host is an ip address.
    set match [scan $host "%d.%d.%d.%d" a b c d]

    if { $match != "4" } {
        error "SOCKS ERROR: TOC Host must be IP address, not name\n"
    }

    set fd [socket $::SOCKSHOST $::SOCKSPORT]
    set data [binary format "ccScccca*c" 4 1 $port $a $b $c $d $sname 0]
    puts -nonewline $fd $data
    flush $fd

    set response [read $fd 8]
    binary scan $response "ccSI" v r port ip

    if { $r != "90" } {
        puts "Request failed code : $r"
        return 0
    }

    return $fd
}

# We keep stats that are used by the testing tools.  These aren't
# need for TiK, so I guess we could remove them. :-)
set SFLAPSTATS(ONLINE) 0
set SFLAPSTATS(TOTONLINE) 0
set SFLAPSTATS(sflap_send) 0
set SFLAPSTATS(sflap_receive) 0
