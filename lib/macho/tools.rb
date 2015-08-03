module MachO
	module Tools
		def self.dylibs(file)
			false
		end

		def self.change_dylib_id(file, new_id)
			false
		end

		def self.change_install_name(file, old_name, new_name)
			false
		end
	end
end
