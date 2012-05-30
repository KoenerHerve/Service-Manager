class Link < Entity
	attr_reader :source, :target
    	attr_writer :source, :target

	def initialize row
		super(row.values_at(0,1,2,3,4))
		@source, @target = row.values_at(5,6)
	end
end

