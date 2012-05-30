class Category < Record
	attr_reader :scheme, :term, :title, :attributes
    	attr_writer :scheme, :term, :title, :attributes

	def initialize row
		super(row[0])
		@scheme, @term, @title, @attributes = row.values_at(1,2,3,4)
	end
end
