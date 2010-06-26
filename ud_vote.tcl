#!/usr/bin/env tclsh8.5
#
# Usage: ./ud_vote.tcl <up or down> <definition id number>
#
# Get definition id number from visiting the definition and clicking the
# number beside the definition name. This will yield a URL such as
# http://www.urbandictionary.com/define.php?term=shebell&defid=2858498
# Take the 2858498 portion and do
#  ./ud_vote.tcl 2858498 up
# to vote this definition up
#

package require http

namespace eval ud_vote {
	variable url http://www.urbandictionary.com/thumbs.php
}

proc ud_vote::vote {defid direction} {
	http::config -useragent "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.1.6) Gecko/20091216 Firefox/3.0.6"

	set headers [list X-Requested-With XMLHttpRequest X-Prototype-Version 1.6.0.3]
	set query [http::formatQuery defid $defid direction $direction]
	set token [http::geturl $ud_vote::url -query $query -headers $headers]
	set data [http::data $token]
	http::cleanup $token

	return $data
}

proc ud_vote::usage {} {
	puts "Usage: ./ud_vote.tcl <up or down> <definition id number>"
}

if {$argc != 2} {
	ud_vote::usage
	return
}

set direction [lindex $argv 0]
if {$direction != "up" && $direction != "down"} {
	ud_vote::usage
	return
}

set defid [lindex $argv 1]
if {![string is digit $defid]} {
	ud_vote::usage
	return
}

puts "Result: [ud_vote::vote $defid $direction]"
