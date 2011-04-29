#!/usr/bin/env tclsh8.5
#
# 28/04/2011
#
# Check whether a website (from a list of websites) is up, and if it is up
# whether it matches a known good version
#

package require http

namespace eval website_checker {
	variable sites [list www.storeylaw.com]
	variable storage_dir ${::env(HOME)}/.website_checker
}

proc ::website_checker::print_usage {} {
	puts "Usage: $::argv0 <check | build>"
	puts "\t- check: checks if the sites are up / in good configuration"
	puts "\t- build: record output of each site as good state"
	exit 1
}

proc ::website_checker::fetch_http {url} {
	set token [http::geturl http://${url} -timeout 10000]
	set ncode [http::ncode $token]
	set data [http::data $token]
	http::cleanup $token
	if {$ncode != 200} {
		error "Failure fetching URL (${ncode}): ${data}"
	}
	return $data
}

proc ::website_checker::check_sites {} {
	variable sites
	variable storage_dir

	foreach site $sites {
		if {![file exists ${storage_dir}/${site}]} {
			puts "State file does not exist for ${site}. Please run the script with 'build'."
			exit 1
		}

		set f [open ${storage_dir}/${site}]
		set good_state [read -nonewline $f]
		close $f

		if {[catch {fetch_http $site} output]} {
			puts "Failure checking site: $output"
		} else {
			if {$good_state == $output} {
				puts "${site} is up and in a good state."
			} else {
				puts "*** ${site} state changed!"
				#puts "Got $output"
				#puts "Expected $good_state"
			}
		}
	}
}

proc ::website_checker::build_sites {} {
	variable sites
	variable storage_dir

	# Doesn't fail if dir already exists
	file mkdir $storage_dir

	foreach site $sites {
		set f [open ${storage_dir}/${site} w]
		puts $f [fetch_http $site]
		close $f
	}
}

# Execution entry

if {$argc != 1} {
	website_checker::print_usage
}

if {[lindex $argv 0] == "check"} {
	website_checker::check_sites
} elseif {[lindex $argv 0] == "build"} {
	website_checker::build_sites
} else {
	website_checker::print_usage
}
