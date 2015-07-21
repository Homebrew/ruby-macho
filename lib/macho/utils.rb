module MachO
	module Utils
		# http://www.opensource.apple.com/source/cctools/cctools-870/libstuff/rnd.c
		def self.round(value, round)
			round -= 1
			value += round
			value &= ~round
			value
		end
	end
end
