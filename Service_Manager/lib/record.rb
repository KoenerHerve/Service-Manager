class Record
	attr_reader :id
    	attr_writer :id

	def initialize id
		@id = id.to_i if id != nil
	end
end
