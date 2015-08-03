module MachO
	module Utils
		# http://www.opensource.apple.com/source/cctools/cctools-870/libstuff/rnd.c
		def self.round(value, round)
			round -= 1
			value += round
			value &= ~round
			value
		end

		def self.magic?(num)
			MH_MAGICS.has_key?(num)
		end

		def self.fat_magic?(num)
			num == FAT_MAGIC || num == FAT_CIGAM
		end

		def self.magic32?(num)
			num == MH_MAGIC || num == MH_CIGAM
		end

		def self.magic64?(num)
			num == MH_MAGIC_64 || num == MH_CIGAM_64
		end
	end
end
