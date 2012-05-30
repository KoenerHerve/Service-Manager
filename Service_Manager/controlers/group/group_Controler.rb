require 'erb'

class Group_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# Display the representation of the group instance
	# url: _String_ location url of the group instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the representation of the group instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ResourceNotFound : throw if the representation of the group instance does not exist.
	def show(url, contentType)
		contentType = contentType.sub(/\//,"_")+"_"
		@group= self.getManagerOf("group").getUnique(url)

		raise ResourceNotFound, "ResourceNotFound: The group does not exist" if @group == nil

		erb=ERB.new(File.read(@view+contentType+'index.erb'))
		erb.result(binding)
	end

	# create
	# Create a new group instance
	# request: _String_ the representation of the new group instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# throws: CategoryError: throw if the mixin instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	# throws: ResourceNotFound : throw if the representation of the group instance does not exist.
	def create(request, contentType)
		request = Request.process(request)
		request.category.each do |category|
			if category[0].downcase == "group" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/group#" &&
				category[2].downcase == "kind"

				val = [	request.getAttribute('occi.core.id'),
					request.getAttribute('occi.core.title'),
					'kind',
					'mixins',
					'location',
					request.getAttribute('occi.core.source'),
					request.getAttribute('occi.core.target')]
				group = Group.new(val)
				group_manager = self.getManagerOf("group")
				id = group.id == nil ? group_manager.create(group): group_manager.update(group, true)

				# We link the resource to the mixins
				request.category.each_index do |i|
					if request.category[i][2] == "mixin"
						kind = request.category[i][1].split("/").last.chop.downcase 
						mixin = request.category[i][0].downcase
						if self.verifKind(kind)
							resource = Array.new() << (Array.new() << '/group/'+id.to_s)
							self.getManagerOf("mixin").add(kind, mixin,resource)
						end
					end
				end

				Log.info "Group created."
				return self.show(id, contentType)
			end
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'group' and the term kind must match with this kind"
	end

	# update
	# Update an group instance
	# request: _String_ the representation of the group instance to update
	# full: _Boolean_ true if it's a full update, false either
	# throws: CategoryError: throw if the mixin instances kinds
	#	 or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	def update(url, request, full)
		request = Request.process(request)
		goodkind = false
		if full
			request.category.each do |category|
				if category[0].downcase == "group" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/group#" &&
				category[2].downcase == "kind"
					goodkind = true
				end
			end
		else
			goodkind = true
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'group' and the term kind must match with this kind" if !goodkind

		val = [	url,
			request.getAttribute('occi.core.title'),
			'kind',
			'mixins',
			'location',
			request.getAttribute('occi.core.source'),
			request.getAttribute('occi.core.target')]
		group = Group.new(val)
		id = self.getManagerOf("group").update(group, full)

		# We link the resource to the mixins
		self.getManagerOf("group").dissociateAllMixin(id) if full
		request.category.each_index do |i|
			if request.category[i][2] == "mixin"
				kind = request.category[i][1].split("/").last.chop.downcase 
				mixin = request.category[i][0].downcase
				if self.verifKind(kind)
					resource = Array.new() << (Array.new() << '/group/'+id.to_s)
					f.getManagerOf("mixin").add(kind, mixin,resource)
				end
			end
		end

		Log.info "Group updated."
		return ""
	end

	# delete
	# delete one group instance
	# url: _String_ location url of the group instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(url)
		self.getManagerOf("group").delete(url)
		Log.info "Group deleted."
	end

	# deleteAll
	# delete all group instances
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		self.getManagerOf("group").deleteAll()
		Log.info "All the groups are deleted."
	end

	# action
	# Apply an action to the group instance
	# url: _String_ location url of the group instance
	# action: _String_ action to apply
	# request: _String_ list of parameters required by the action
	# throws: ActionError: throw if the action cannot be apply to the group instance
	def action(id, action , request)
		raise ActionError, "Action Error: Action not supported"
	end
end
