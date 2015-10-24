module MachO
	# Represents a "Fat" file, which contains a header, a listing of available
	# architectures, and one or more Mach-O binaries.
	# @see https://en.wikipedia.org/wiki/Mach-O#Multi-architecture_binaries
	# @see MachO::MachOFile
	class FatFile
		# @return [MachO::FatHeader] the file's header
		attr_reader :header

		# @return [Array<MachO::FatArch>] an array of fat architectures
		attr_reader :fat_archs

		# @return [Array<MachO::MachOFile>] an array of Mach-O binaries
		attr_reader :machos

		# Creates a new FatFile from the given filename.
		# @param filename [String] the fat file to load from
		# @raise [MachO::MagicError] if the file does not have a Mach-O magic number.
		# @raise [MachO::MachOBinaryError] if the file is not a fat binary.
		def initialize(filename)
			raise ArgumentError.new("filename must be a String") unless filename.is_a? String

			@filename = filename
			@raw_data = open(@filename, "rb") { |f| f.read }
			@header = get_fat_header
			@fat_archs = get_fat_archs
			@machos = get_machos
		end

		# The file's raw fat data.
		# @return [String] the raw fat data
		def serialize
			@raw_data
		end

		# The file's dylib ID. If the file is not a dylib, returns `nil`.
		# @example
		#  file.dylib_id # => 'libBar.dylib'
		# @return [String] the file's dylib ID
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

		# Changes the file's dylib ID to `new_id`. If the file is not a dylib, does nothing.
		# @example
		#  file.dylib_id = 'libFoo.dylib'
		# @param new_id [String] the new dylib ID
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

		# All shared libraries linked to the file's Mach-Os.
		# @return [Array<String>] an array of all shared libraries
		def linked_dylibs
			dylibs = machos.map(&:linked_dylibs).flatten

			# can machos inside fat binaries have different dylibs?
			dylibs.uniq!
		end

		# Changes all dependent shared library install names from `old_name` to `new_name`.
		# In a fat file, this changes install names in all internal Mach-Os.
		# @example
		#  file.change_install_name('/usr/lib/libFoo.dylib', '/usr/lib/libBar.dylib')
		# @param old_name [String] the shared library name being changed
		# @param new_name [String] the new name
		# @todo incomplete
		def change_install_name(old_name, new_name)
			machos.each do |macho|
				macho.change_install_name(old_name, new_name)
			end

			synchronize_raw_data
		end

		alias :change_dylib :change_install_name

		# Extract a Mach-O with the given CPU type from the file.
		# @example
		#  file.extract("CPU_TYPE_I386") # => MachO::MachOFile
		# @param cputype [String] the CPU type of the Mach-O being extracted
		# @return [MachO::MachOFile, nil] the extracted Mach-O or nil if no Mach-O has the given CPU type
		def extract(cputype)
			machos.select { |macho| macho.cputype == cputype }.first
		end

		# Write all (fat) data to the given filename.
		# @param filename [String] the file to write to
		def write(filename)
			File.open(filename, "wb") { |f| f.write(@raw_data) }
		end

		# Write all (fat) data to the file used to initialize the instance.
		# @note Overwrites all data in the file!
		def write!
			File.open(@filename, "wb") { |f| f.write(@raw_data) }
		end

		private

		# Obtain the fat header from raw file data.
		# @return [MachO::FatHeader] the fat header
		# @private
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

		# Obtain an array of fat architectures from raw file data.
		# @return [Array<MachO::FatArch>] an array of fat architectures
		# @private
		def get_fat_archs
			archs = []

			header[:nfat_arch].times do |i|
				fields = @raw_data[8 + (FatArch.bytesize * i), FatArch.bytesize].unpack("N5")
				archs << FatArch.new(*fields)
			end

			archs
		end

		# Obtain an array of Mach-O blobs from raw file data.
		# @return [Array<MachO::MachOFile>] an array of Mach-Os
		# @private
		def get_machos
			machos = []

			fat_archs.each do |arch|
				machos << MachOFile.new_from_bin(@raw_data[arch[:offset], arch[:size]])
			end

			machos
		end

		# @todo this needs to be redesigned. arch[:offset] and arch[:size] are
		# already out-of-date, and the header needs to be synchronized as well.
		# @private
		def synchronize_raw_data
			machos.each_with_index do |macho, i|
				arch = fat_archs[i]

				@raw_data[arch[:offset], arch[:size]] = macho.serialize
			end
		end
	end
end
