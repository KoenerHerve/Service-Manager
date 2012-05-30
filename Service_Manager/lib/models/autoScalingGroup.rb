class Autoscalinggroup < Resource
	attr_reader :state, :size, :min, :max, :vms
    	attr_writer :state, :size, :min, :max, :vms

	def initialize row
		super(row.values_at(0,1,2,3,4,5,6))
		@state, @size, @min, @max, @vms = row.values_at(7,8,9,10,11)
		@min = @min.to_i if @min != nil
		@max = @max.to_i if @max != nil
		@size = @size.to_i if @size != nil
	end
end

