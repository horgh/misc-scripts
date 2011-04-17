#!/usr/local/bin/tclsh8.5
#
# git_sock_spew.tcl - 0.1
#
# Created Feb 10 2010
# Will Storey
#
# Connect to a port and output a string
#
# Couple with a bot running svn.tcl this will output to the given channel a
# string about the commit
#
# Set ip and port to those matching svn.tcl
#
# Add call for this to file /bare_git_repo/hooks/post-receive as follows:
# /path/to/git_sock_spew.tcl "/path/to/repo.git"
#

set ip 127.0.0.1
set port 12345

proc spew {str} {
	set chan [socket $::ip $::port]
	puts $chan $str
	close $chan
}

proc git_info {path rev_old rev_new} {
	catch {exec /usr/bin/env -i GIT_DIR=${path} /usr/local/bin/git log --oneline ${rev_old}..${rev_new}} output
	foreach line [split $output \n] {
		set output_s [split $line]

		set rev [lindex $output_s 0]
		set commit [lrange $output_s 1 end]
		lappend lines "\002$rev\002: $commit"
	}
	return $lines
}

# see hooks/post-receive for what args is
gets stdin args
set args [split $args]
set rev_old [lindex $args 0]
set rev_new [lindex $args 1]
set ref_name [lindex $args 2]

# args given on command line should begin with path to repo
set argv [split $argv]
set path [lindex $argv 0]

foreach line [git_info $path $rev_old $rev_new] {
	spew [list #idiotbox $line]
}
