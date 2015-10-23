module MachO
	# A general purpose pseudo-structure. 
	class MachOStructure
		# Subclasses should fill these in manually.
		@format = ""
		@sizeof = 0

		# @return [Fixnum] the size, in bytes, of the represented structure.
		def self.bytesize
			@sizeof
		end

		# @return [MachO::MachOStructure] a new MachOStructure initialized with `bin`
		def self.new_from_bin(bin)
			self.new(*bin.unpack(@format))
		end
	end
end
