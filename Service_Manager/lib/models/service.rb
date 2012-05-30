class Service < Resource
	attr_reader :state
    	attr_writer :state

	def initialize row
		super(row.values_at(0,1,2,3,4,5,6))
		@state = row.values_at(7)
	end
end

