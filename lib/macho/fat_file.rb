module MachO
	class FatFile
		attr_reader :header, :fat_archs, :machos

		def initialize(filename)
			raise ArgumentError.new("filename must be a String") unless filename.is_a? String

			@filename = filename
			@raw_data = open(@filename, "rb") { |f| f.read }
			@header = get_fat_header
			@fat_archs = get_fat_archs
			@machos = get_machos
		end

		def serialize
			@raw_data
		end

		def dylib_id
			if !machos.all?(&:dylib?)
				return nil
			end

			ids = machos.map(&:dylib_id)

			# this should never be the case, but let's be defensive
			if !ids.uniq!.size == 1
				return nil
			end

			ids.first
		end

		def dylib_id=(new_id)
			if !new_id.is_a?(String)
				raise ArgumentError.new("argument must be a String")
			end

			if !machos.all?(&:dylib?)
				return nil
			end

			machos.each do |macho|
				macho.dylib_id = new_id
			end

			synchronize_raw_data
		end

		def linked_dylibs
			dylibs = machos.map(&:linked_dylibs)

			# can machos inside fat binaries have different dylibs?
			dylibs.uniq!
		end

		# stub
		def change_dylib(old_path, new_path)
			raise DylibUnknownError.new(old_path) unless linked_dylibs.include?(old_path)
		end

		alias :change_install_name :change_dylib

		def write(filename)
			File.open(filename, "wb") { |f| f.write(@raw_data) }
		end

		def write!
			File.open(@filename, "wb") { |f| f.write(@raw_data) }
		end

		private

		def get_fat_header
			magic, nfat_arch = @raw_data[0..7].unpack("N2")

			if !MachO.magic?(magic)
				raise MagicError.new(magic)
			end

			if !MachO.fat_magic?(magic)
				raise MachOBinaryError.new
			end

			FatHeader.new(magic, nfat_arch)
		end

		def get_fat_archs
			archs = []

			header[:nfat_arch].times do |i|
				fields = @raw_data[8 + (FatArch.bytesize * i), FatArch.bytesize].unpack("N5")
				archs << FatArch.new(*fields)
			end

			archs
		end

		def get_machos
			machos = []

			fat_archs.each do |arch|
				machos << MachOFile.new_from_bin(@raw_data[arch[:offset], arch[:size]])
			end

			machos
		end

		# when we create machos within FatFile, we initialize them with slices
		# from @raw_data. this means creating new arrays that don't affect
		# @raw_data directly, so we need to synchronize it after changing
		# anything within the machos.
		def synchronize_raw_data
			machos.each_with_index do |macho, i|
				arch = fat_archs[i]

				@raw_data[arch[:offset], arch[:size]] = macho.serialize
			end
		end
	end
end
