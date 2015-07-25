module MachO
	# general purpose pseudo-structure
	class MachOStructure
		@format = nil
		@sizeof = 0

		def self.bytesize
			@sizeof
		end

		def self.new_from_bin(bin)
			self.new(*bin.unpack(@format))
		end
	end
end
