require 'erb'

class Sandbox_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end


	def show
		erb=ERB.new(File.read(@view+'index.erb'))
		erb.result(binding)
	end

	def post(request)
		return Request.process(request).category
	end
end
