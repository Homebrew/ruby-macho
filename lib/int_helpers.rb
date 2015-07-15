module INTHelpers
	Changes = Struct.new("Changes", :old, :new)

	Rpaths = Struct.new("Rpaths", :old, :new, :found) do
		def found?
			found
		end
	end

	AddRpaths = Struct.new("AddRpaths", :new)

	DeleteRpaths = Struct.new("DeleteRpaths", :old, :found) do
		def found?
			found
		end
	end
end
