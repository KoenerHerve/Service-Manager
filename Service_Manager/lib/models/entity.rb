class Entity < Record
	attr_reader :title, :kind, :mixins, :location
    	attr_writer :title, :kind, :mixins, :location

	def initialize row
		super(row[0])
		@title, @kind, @mixins, @location = row.values_at(1,2,3,4)
	end
end

