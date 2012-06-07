require 'erb'

class Service_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# Display the representation of the service instance
	# url: _String_ location url of the service instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the representation of the service instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ResourceNotFound : throw if the representation of the service instance does not exist.
	def show(url, contentType)
		contentType = contentType.sub(/\//,"_")+"_"
		@service= self.getManagerOf("service").getUnique(url)

		@links = Array.new
		raise ResourceNotFound, "ResourceNotFound: The service does not exist" if @service == nil

		if @service != nil && @service.links != nil
			@service.links.split(',').each do |link|
				@links << self.getManagerOf("group").getUnique(link.split('/').last)
			end
		end
		erb=ERB.new(File.read(@view+contentType+'index.erb'))
		erb.result(binding)
	end

	# create
	# Create a new service instance
	# request: _String_ the representation of the new service instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# throws: CategoryError: throw if the mixin instances kinds
	#	 or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group
	#	 (if the service contain autoscaling group).
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception
	#	 (if the service contain autoscaling group)
	# throws: ResourceNotFound : throw if the representation of the service instance does not exist.
	def create(request, contentType)
		request = Request.process(request)
		request.category.each do |category|
			if category[0].downcase == "service" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/service#" &&
				category[2].downcase == "kind"

				val = [	request.getAttribute('occi.core.id'),
					request.getAttribute('occi.core.title'),
					'kind',
					'mixins',
					'location',
					request.getAttribute('occi.core.summary'),
					'links',
					'state']
				service = Service.new(val)
				service_manager = self.getManagerOf("service")
				id = service.id == nil ? service_manager.create(service): service_manager.update(service, true)

				# We link the resources
				request.link.each_index do |i|
					link = request.link[i]
					idg = link[2] != nil ? link[2].split('/').last.to_i : nil
					if self.verifKind(link[0].split('/').last(2)[0].downcase)
						val = [idg,
							request.getLinkAttribute(i,'occi.core.title'),
							'kind',
							'mixins',
							'location',
							'/service/'+id.to_s,
							link[0]]
						group = Group.new(val)
						group_manager = self.getManagerOf("group")
						group.id == nil ? group_manager.create(group, false): group_manager.update(group, true)
					end
				end

				# We link the resource to the mixins
				request.category.each_index do |i|
					if request.category[i][2].downcase == "mixin"
						kind = request.category[i][1].split("/").last.chop.downcase 
						mixin = request.category[i][0].downcase
						if self.verifKind(kind)
							resource = Array.new() << (Array.new() << '/autoscalinggroup/'+id.to_s)
							self.getManagerOf("mixin").add(kind, mixin,resource)
						end
					end
				end

				Log.info "Service created."
				return self.show(id, contentType)
			end
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'service' and the term kind must match with this kind"
	end

	# update
	# Update an service instance
	# request: _String_ the representation of the service instance to update
	# full: _Boolean_ true if it's a full update, false either
	# throws: CategoryError: throw if the mixin instances kinds
	#	 or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group
	#	 (if the service contain autoscaling group).
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception
	#	 (if the service contain autoscaling group)
	def update(url, request, full)
		request = Request.process(request)
		goodkind = false
		if full
			request.category.each do |category|
				if category[0].downcase == "service" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/service#" &&
				category[2].downcase == "kind"
					goodkind = true
				end
			end
		else
			goodkind = true
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'service' and the term kind must match with this kind" if !goodkind

		val = [	url,
			request.getAttribute('occi.core.title'),
			'kind',
			'mixins',
			'location',
			request.getAttribute('occi.core.summary'),
			'links',
			'state']
		service = Service.new(val)
		service_manager = self.getManagerOf("service")
		id = service_manager.update(service, full)

		# We link the resources
		request.link.each_index do |i|
			link = request.link[i]
			idg = link[2] != nil ? link[2].split('/').last.to_i : nil
			if self.verifKind(link[0].split('/').last(2)[0].downcase)
				val = [idg,
					request.getLinkAttribute(i,'occi.core.title'),
					'kind',
					'mixins',
					'location',
					'/service/'+id.to_s,
					link[0]]
				group = Group.new(val)
				group_manager = self.getManagerOf("group")
				group.id == nil ? group_manager.create(group): group_manager.update(group, full)
			end
		end

		# We link the resource to the mixins
		service_manager.dissociateAllMixin(id) if full
		request.category.each_index do |i|
			if request.category[i][2] == "mixin"
				kind = request.category[i][1].split("/").last.chop.downcase
				mixin = request.category[i][0].downcase
				if self.verifKind(kind)
					resource = Array.new() << (Array.new() << '/autoscalinggroup/'+id.to_s)
					self.getManagerOf("mixin").add(kind, mixin,resource)
				end
			end
		end

		Log.info "Service updated."
		return ""
	end

	# delete
	# delete one service instance
	# url: _String_ location url of the service instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(url)
		self.getManagerOf("service").delete(url)
		Log.info "Service deleted."
	end

	# deleteAll
	# delete all dependence instances
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		self.getManagerOf("service").deleteAll()
		Log.info "All the services are deleted."
	end

	# action
	# Apply an action to the service instance
	# url: _String_ location url of the service instance
	# action: _String_ action to apply
	# request: _String_ list of parameters required by the action
	# throws: ActionError: throw if the action cannot be apply to the service instance
	#	 or if the service is empty
	#	 or there is a problem with the dependence of the autoscaling group.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def action(url, action , request)
		action.downcase!
		case action
			when "start", "stop", "restart"
				self.getManagerOf("service").send(action,url)
			else
				raise ActionError, "Action Error: Action not supported"
		end

		Log.info "Action "+action+" performed."
		return ""
	end
end
