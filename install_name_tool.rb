#!/usr/bin/env ruby

#	install_name_tool.rb

require "./lib/macho/macho"
require "./lib/int_helpers"

def error(msg)
	$stderr.puts("error: #{$PROGRAM_NAME}: #{msg}")
end

def usage
	$stderr.puts("Usage: #{$PROGRAM_NAME} [-change old new] ... [-rpath old new] ... [-add_rpath new] ... [-delete_rpath old] ... [-id name] input")
	exit(1)
end

def eu(msg)
	error(msg)
	usage
end

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

i = 0
archs = []
narchs = 0
input = nil

# TODO: replace all those hideos .times loops with .map/.include? combinations

while i < ARGV.length
	case ARGV[i]
	when "-id"
		eu("more than one: #{ARGV[i]} option specified") if !id.nil?
		id = ARGV[i + 1]
		eu("missing argument to: #{ARGV[i]} option") if id.nil?
		i += 1
	when "-change"
		eu("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil? || ARGV[i + 2].nil?
		changes << INTHelpers::Change.new(ARGV[i + 1], ARGV[i + 2])
		nchanges += 1
		i += 2
	when "-rpath"
		eu("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil? || ARGV[i + 2].nil?

		nrpaths.times do |j|
			if rpaths[j].old == ARGV[i + 1]
				if rpaths[j].new == ARGV[i + 2]
					eu("\"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\" specified more than once")
				end

				eu("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end

			if rpaths[j].new == ARGV[i + 1] || rpaths[j].old == ARGV[i + 2] || rpaths[j].new == ARGV[i + 2]
				eu("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end
		end

		nadd_rpaths.times do |j|
			if add_rpaths[j].new == ARGV[i + 1] || add_rpaths[j].new == ARGV[i + 2]
				eu("can't specify both \"-add_rpath #{add_rpaths[j].new}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end
		end

		ndelete_rpaths.times do |j|
			if delete_rpaths[j].old == ARGV[i + 1] || delete_rpaths[j].old == ARGV[i + 2]
				eu("can't specify both \"-delete_rpath #{delete_rpaths[j].old}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end
		end

		rpaths << INTHelpers::Rpath.new(ARGV[i + 1], ARGV[i + 2], false)
		nrpaths += 1
		i += 2
	when "-add_rpath"
		eu("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil?

		nadd_rpaths.times do |j|
			if add_rpaths[j].new == ARGV[i + 1]
				eu("\"-add_rpath #{add_rpaths[j].new} specified more than once\"")
			end
		end

		nrpaths.times do |j|
			if rpaths[j].old == ARGV[i + 1] || rpaths[j].new == ARGV[i + 1]
				eu("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-add_rpath #{ARGV[i + 1]}\"")
			end
		end

		ndelete_rpaths.times do |j|
			if delete_rpaths[j].old == ARGV[i + 1]
				eu("can't specify both \"-delete_rpath #{delete_rpaths[j].old}\" and \"-add_rpath #{ARGV[i + 1]}\"")
			end
		end

		add_rpaths << INTHelpers::AddRpath.new(ARGV[i + 1])
		nadd_rpaths += 1
		i += 1
	when "-delete_rpath"
		eu("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil?

		ndelete_rpaths.times do |j|
			if delete_rpaths[j].old == ARGV[i + 1]
				eu("\"-delete_rpath #{delete_rpaths[j].old} specified more than once\"")
			end
		end

		nrpaths.times do |j|
			if rpaths[j].old == ARGV[i + 1] || rpaths[j].new == ARGV[i + 1]
				eu("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-delete_rpath #{ARGV[i + 1]}\"")
			end
		end

		nadd_rpaths.times do |j|
			if add_rpaths[j].new == ARGV[i + 1]
				eu("can't specify both \"-add_rpath #{add_rpaths[j].new}\" and \"-delete_rpath #{ARGV[i + 1]}\"")
			end
		end

		delete_rpaths << INTHelpers::DeleteRpath.new(ARGV[i + 1], false)
		ndelete_rpaths += 1
		i += 1
	else
		eu("more than one input file specified (#{ARGV[i]} and #{input})") if !input.nil?
		input = ARGV[i]
	end

	i += 1
end

if input.nil? || (id.nil? && nchanges.zero? && nrpaths.zero? && nadd_rpaths.zero? && ndelete_rpaths.zero?)
	usage
end

# prototyped in include/stuff/breakout.h
# declared in libstuff/breakout.c
# breakout(input, &archs, &narchs, FALSE);

# TODO: install_name_tool uses an extern uint32_t errors to register errors.
# needs to be restructured.
