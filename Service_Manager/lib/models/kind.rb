class Kind < Category
	attr_reader :entity_type, :rel, :actions, :mixins, :location
    	attr_writer :entity_type, :rel, :actions, :mixins, :location

	def initialize row
		super(row.values_at(0,1,2,3,4))
		@entity_type, @rel, @actions, @mixins, @location = row.values_at(5,6,7,8,9)
	end
end

