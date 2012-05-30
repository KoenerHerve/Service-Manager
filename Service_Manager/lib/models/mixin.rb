class Mixin < Category
	attr_reader :kind, :actions, :location, :related
    	attr_writer :kind, :actions, :location, :related
	def initialize row
		super(row.values_at(0,1,2,3,4))
		@kind, @actions, @location, @related = row.values_at(5,6,7, 8)
	end
end
