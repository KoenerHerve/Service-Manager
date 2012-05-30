require 'erb'

class Dependence_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# Display the representation of the dependence instance
	# url: _String_ location url of the dependence instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the representation of the dependence instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ResourceNotFound : throw if the representation of the dependence instance does not exist.
	def show(url, contentType)
		contentType = contentType.sub(/\//,"_")+"_"
		@dependence= self.getManagerOf("dependence").getUnique(url)

		raise ResourceNotFound, "ResourceNotFound: The dependence does not exist" if @dependence == nil

		erb=ERB.new(File.read(@view+contentType+'index.erb'))
		erb.result(binding)
	end

	# create
	# Create a new dependence instance
	# request: _String_ the representation of the new dependence instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# throws: CategoryError: throw if the mixin instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	# throws: ResourceNotFound : throw if the representation of the dependence instance does not exist.
	def create(request, contentType)
		request = Request.process(request)
		request.category.each do |category|
			if category[0].downcase == "dependence" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/dependence#" &&
				category[2].downcase == "kind"

				val = [	request.getAttribute('occi.core.id'),
					request.getAttribute('occi.core.title'),
					'kind',
					'mixins',
					'location',
					request.getAttribute('occi.core.source'),
					request.getAttribute('occi.core.target')]
				dependence = Dependence.new(val)
				dependence_manager = self.getManagerOf("dependence")
				id = dependence.id == nil ? dependence_manager.create(dependence): dependence_manager.update(dependence, true)

				# We link the resource to the mixins
				request.category.each_index do |i|
					if request.category[i][2] == "mixin"
						kind = request.category[i][1].split("/").last.chop.downcase 
						mixin = request.category[i][0].downcase
						if self.verifKind(kind)
							resource = Array.new() << (Array.new() << '/dependence/'+id.to_s)
							self.getManagerOf("mixin").add(kind, mixin,resource)
						end
					end
				end

				Log.info "Dependence created."
				return self.show(id, contentType)
			end
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'dependence' and the term kind must match with this kind"
	end

	# update
	# Update an dependence instance
	# request: _String_ the representation of the dependence instance to update
	# full: _Boolean_ true if it's a full update, false either
	# throws: CategoryError: throw if the mixin instances kinds
	# 	or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	def update(url, request, full)
		request = Request.process(request)
		goodkind = false
		if full
			request.category.each do |category|
				if category[0].downcase == "dependence" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/dependence#" &&
				category[2].downcase == "kind"
					goodkind = true
				end
			end
		else
			goodkind = true
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'dependence' and the term kind must match with this kind" if !goodkind

		val = [	url,
			request.getAttribute('occi.core.title'),
			'kind',
			'mixins',
			'location',
			request.getAttribute('occi.core.source'),
			request.getAttribute('occi.core.target')]
		dependence = Dependence.new(val)
		id = self.getManagerOf("dependence").update(dependence, full)

		# We link the resource to the mixins
		self.getManagerOf("dependence").dissociateAllMixin(id) if full
		request.category.each_index do |i|
			if request.category[i][2] == "mixin"
				kind = request.category[i][1].split("/").last.chop.downcase 
				mixin = request.category[i][0].downcase
				if self.verifKind(kind)
					resource = Array.new() << (Array.new() << '/dependence/'+id.to_s)
					f.getManagerOf("mixin").add(kind, mixin,resource)
				end
			end
		end

		Log.info "Dependence updated."
		return ""
end

	# delete
	# delete one dependence instance
	# url: _String_ location url of the dependence instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(url)
		self.getManagerOf("dependence").delete(url)
		Log.info "Dependence deleted."
	end

	# deleteAll
	# delete all dependence instances
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		self.getManagerOf("dependence").deleteAll()
		Log.info "All the dependences are deleted."
	end

	# action
	# Apply an action to the dependence instance
	# url: _String_ location url of the dependence instance
	# action: _String_ action to apply
	# request: _String_ list of parameters required by the action
	# throws: ActionError: throw if the action cannot be apply to the dependence instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	def action(id, action , request)
		raise ActionError, "Action Error: Action not supported"
	end
end
