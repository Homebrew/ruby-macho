module MachO
	module Tools
		def self.dylibs(filename)
			file = MachO.open(filename)

			file.linked_dylibs
		end

		def self.change_dylib_id(filename, new_id)
			file = MachO.open(filename)

			if File.is_a? MachO::MachOFile
				file.dylib_id = new_id
				file.write!
			else
				raise MachOError.new("changing dylib ids for fat binaries is incomplete")
			end
		end

		def self.change_install_name(filename, old_name, new_name)
			raise MachOError.new("changing install names is incomplete")
		end
	end
end
