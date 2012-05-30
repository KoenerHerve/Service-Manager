require 'erb'

class RequestInterface_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# Display all registered Kinds, Actions and Mixins
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the representation of all registered Kinds, Actions and Mixins
	# throws: DatabaseError : throw if there is a Mysql Error.
	def show(contentType)
		contentType = contentType.sub(/\//,"_")+"_"
		@kinds = self.getManagerOf("kind").getList
		@mixins = self.getManagerOf("mixin").getList
		@actions = self.getManagerOf("category").getList
		erb=ERB.new(File.read(@view+contentType+'index.erb'))
		erb.result(binding)
	end

	# addMixin
	# add one or more new user defined mixin
	# request: _String_ list of mixins representations
	# throws: KindNotFoundError: throw if the mixin instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	def addMixin(request)

		categories = Request.process(request).category
		mixins = Array.new
		categories.each do |category|

			if category[2] == "mixin"
				if self.verifKind(category[1].split('/').last.chop)
					mixins << Mixin.new([0, category[1],#scheme
								category[0],#term
								category[3],#title
								category[4],#attributes
								category[1].split('/').last.chop,#kind
								category[5],#actions
								category[7],#location
								category[6]])#related
				end
			end
		end
		self.getManagerOf("mixin").create(mixins)
		Log.info "User Mixin created." if !mixins.empty?
		return ""
	end

	# removeMixin
	# remove one or more user defined mixin
	# request: _String_ list of mixins representations
	# throws: KindNotFoundError: throw if the mixin instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	def removeMixin(request)
		categories = Request.process(request).category
		if !categories.empty?
			mixins = Array.new
			categories.each do |category|
			if category[2] == "mixin"
				if self.verifKind(category[1].split('/').last.chop)
					mixins << Mixin.new([0, category[1],#scheme
								category[0],#term
								category[3],#title
								category[4],#attributes
								category[1].split('/').last.chop,#kind
								category[5],#actions
								category[7],#location
								category[6]])#related
				end
			end
		end
			self.getManagerOf("mixin").delete(mixins)
			Log.info "User Mixin deleted." if !mixins.empty?
		elsif request == ""
			self.getManagerOf("mixin").deleteAll()
			Log.info "All the User Mixins are deleted."
		else
			raise KindNotFoundError, "This mixin does'nt exist."
		end
		return ""
	end
end
