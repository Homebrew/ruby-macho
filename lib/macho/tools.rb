module MachO
	# A collection of convenient methods for common operations on Mach-O and Fat binaries.
	module Tools
		# @param filename [String] the Mach-O or Fat binary being read
		# @return [Array<String>] an array of all dylibs linked to the binary
		def self.dylibs(filename)
			file = MachO.open(filename)

			file.linked_dylibs
		end

		# Changes the dylib ID of a Mach-O or Fat binary, overwriting the source file.
		# @param filename [String] the Mach-O or Fat binary being modified
		# @param new_id [String] the new dylib ID for the binary
		# @return [void]
		def self.change_dylib_id(filename, new_id)
			file = MachO.open(filename)

			if File.is_a? MachO::MachOFile
				file.dylib_id = new_id
				file.write!
			else
				raise MachOError.new("changing dylib ids for fat binaries is incomplete")
			end
		end

		# Changes a shared library install name in a Mach-O or Fat binary, overwriting the source file.
		# @param filename [String] the Mach-O or Fat binary being modified
		# @param old_name [String] the old shared library name
		# @param new_name [String] the new shared library name
		# @return [void]
		def self.change_install_name(filename, old_name, new_name)
			file = MachO.open(filename)

			if File.is_a? MachO::MachOFile
				file.change_install_name(old_name, new_name)
			else
				raise MachOError.new("changing install names for fat binaries is incomplete")
			end
		end
	end
end
