class Resource < Entity
	attr_reader :summary, :links
    	attr_writer :summary, :links

	def initialize row
		super(row.values_at(0,1,2,3,4))
		@summary, @links = row.values_at(5,6)
	end
end

