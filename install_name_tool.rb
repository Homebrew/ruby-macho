#!/usr/bin/env ruby

#	install_name_tool.rb

require "./lib/macho/macho"
require "./lib/int_helpers"

progname = $PROGRAM_NAME

# -id option
id = nil

# -change options
changes = []
nchanges = 0

# -rpath options
rpaths = []
nrpaths = 0

# -add_rpath options
add_rpaths = []
nadd_rpaths = 0

# -delete_rpath options
delete_rpaths = []
ndelete_rpaths = 0

# /*
#  * This is a pointer to an array of the original header sizes (mach header and
#  * load commands) for each architecture which is used when we are writing on the
#  * input file.
#  */
# static uint32_t *arch_header_sizes = NULL;

# /* apple_version is created by the libstuff/Makefile */
# extern char apple_version[];
# char *version = apple_version;

# REMIND: OUTPUT_OPTION was disabled in install_name_tool, so I'm not
# implementing it

#######

i, j = 0, 0
archs = []
narchs = 0
input = nil

ARGV.each_with_index do |opt, i|
	case opt
	when "-id"
		abort("more than one: #{opt} option specified") if !id.nil?
		id = ARGV[i + 1]
		abort("missing argument to: #{opt} option") if id.nil?
	when "-change"
		abort("missing argument(s) to: #{opt} option") if ARGV[i + 1].nil? || ARGV[i + 2].nil?
		changes << INTHelpers::Changes.new(ARGV[i + 1], ARGV[i + 2])
		nchanges += 1
	when "-rpath"
		abort("missing argument(s) to: #{opt} option") if ARGV[i + 1].nil? || ARGV[i + 2].nil?
	end
end
