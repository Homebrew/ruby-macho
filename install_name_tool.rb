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

i = 0
archs = []
narchs = 0
input = nil

while i < ARGV.length
	case ARGV[i]
	when "-id"
		abort("more than one: #{ARGV[i]} option specified") if !id.nil?
		id = ARGV[i + 1]
		abort("missing argument to: #{ARGV[i]} option") if id.nil?
		i += 1
	when "-change"
		abort("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil? || ARGV[i + 2].nil?
		changes << INTHelpers::Change.new(ARGV[i + 1], ARGV[i + 2])
		nchanges += 1
		i += 2
	when "-rpath"
		abort("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil? || ARGV[i + 2].nil?

		nrpaths.times do |j|
			if rpaths[j].old == ARGV[i + 1]
				if rpaths[j].new == ARGV[i + 2]
					abort("\"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\" specified more than once")
				end

				abort("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end

			if rpaths[j].new == ARGV[i + 1] || rpaths[j].old == ARGV[i + 2] || rpaths[j].new == ARGV[i + 2]
				abort("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end
		end

		nadd_rpaths.times do |j|
			if add_rpaths[j].new == ARGV[i + 1] || add_rpaths[j].new == ARGV[i + 2]
				abort("can't specify both \"-add_rpath #{add_rpaths[j].new}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end
		end

		ndelete_rpaths.times do |j|
			if delete_rpaths[j].old == ARGV[i + 1] || delete_rpaths[j].old == ARGV[i + 2]
				abort("can't specify both \"-delete_rpath #{delete_rpaths[j].old}\" and \"-rpath #{ARGV[i + 1]} #{ARGV[i + 2]}\"")
			end
		end

		rpaths << INTHelpers::Rpath.new(ARGV[i + 1], ARGV[i + 2], false)
		nrpaths += 1
		i += 2
	when "-add_rpath"
		abort("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil?

		nadd_rpaths.times do |j|
			if add_rpaths[j].new == ARGV[i + 1]
				abort("\"-add_rpath #{add_rpaths[j].new} specified more than once\"")
			end
		end

		nrpaths.times do |j|
			if rpaths[j].old == ARGV[i + 1] || rpaths[j].new == ARGV[i + 1]
				abort("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-add_rpath #{ARGV[i + 1]}\"")
			end
		end

		ndelete_rpaths.times do |j|
			if delete_rpaths[j].old == ARGV[i + 1]
				abort("can't specify both \"-delete_rpath #{delete_rpaths[j].old}\" and \"-add_rpath #{ARGV[i + 1]}\"")
			end
		end

		add_rpaths << INTHelpers::AddRpath.new(ARGV[i + 1])
		nadd_rpaths += 1
		i += 1
	when "-delete_rpath"
		abort("missing argument(s) to: #{ARGV[i]} option") if ARGV[i + 1].nil?

		ndelete_rpaths.times do |j|
			if delete_rpaths[j].old == ARGV[i + 1]
				abort("\"-delete_rpath #{delete_rpaths[j].old} specified more than once\"")
			end
		end

		nrpaths.times do |j|
			if rpaths[j].old == ARGV[i + 1] || rpaths[j].new == ARGV[i + 1]
				abort("can't specify both \"-rpath #{rpaths[j].old} #{rpaths[j].new}\" and \"-delete_rpath #{ARGV[i + 1]}\"")
			end
		end

		nadd_rpaths.times do |j|
			if add_rpaths[j].new == ARGV[i + 1]
				abort("can't specify both \"-add_rpath #{add_rpaths[j].new}\" and \"-delete_rpath #{ARGV[i + 1]}\"")
			end
		end

		delete_rpaths << INTHelpers::DeleteRpath.new(ARGV[i + 1], false)
		ndelete_rpaths += 1
		i += 1
	else
		abort("more than one input file specified (#{ARGV[i]} and #{input})") if !input.nil?
		input = ARGV[i]
	end

	i += 1
end
