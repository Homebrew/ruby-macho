module INTHelpers
	Change = Struct.new("Changes", :old, :new)

	Rpath = Struct.new("Rpaths", :old, :new, :found) do
		def found?
			found
		end
	end

	AddRpath = Struct.new("AddRpaths", :new)

	DeleteRpath = Struct.new("DeleteRpaths", :old, :found) do
		def found?
			found
		end
	end
end
