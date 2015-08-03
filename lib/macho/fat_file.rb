module MachO
	class FatFile
		attr_reader :header, :fat_archs, :machos

		def initialize(filename)
			raise ArgumentError.new("filename must be a String") unless filename.is_a? String

			@filename = filename
			@raw_data = open(@filename, "rb") { |f| f.read }
			@header = get_fat_header
			@fat_archs = get_fat_archs
			@machos = get_machos(@fat_archs)
		end

		private

		def get_fat_header
			magic, nfat_arch = @raw_data[0..7].unpack("N2")

			if !Utils.magic?(magic)
				raise MagicError.new(magic)
			end

			if !Utils.fat_magic?(magic)
				raise # need a new exception here
			end

			FatHeader.new(magic, nfat_arch)
		end

		def get_fat_archs
			archs = []

			header[:nfat_arch].times do |i|
				archs << FatArch.new(*@raw_data[8 + (FatArch.bytesize * i), FatArch.bytesize].unpack("N5"))
			end

			archs
		end

		def get_machos(fat_archs)
			[]
		end
	end
end
