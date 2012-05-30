class Action < Record
	attr_reader :category, :kind, :mixin
    	attr_writer :category, :kind, :mixin

	def initialize row
		super(row[0])
		@category, @kind, @mixin = row.values_at(1,2,3)
	end
end
