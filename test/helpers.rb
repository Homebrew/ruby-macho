require "digest/sha1"

module Helpers
	def equal_sha1_hashes(file1, file2)
		digest1 = Digest::SHA1.file(file1).to_s
		digest2 = Digest::SHA1.file(file2).to_s

		digest1 == digest2
	end

	def filechecks(except = nil)
		checks = [
			:object?, :executable?, :fvmlib?, :core?, :preload?, :dylib?,
			:dylinker?, :bundle?, :dsym?, :kext?
		]

		checks.delete(except)

		checks
	end
end
