require 'erb'

class Autoscalinggroup_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# Display the representation of the autoscaling group instance
	# url: _String_ location url of the autoscaling group instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the representation of the autoscaling group instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ResourceNotFound : throw if the representation of the autoscalinggroup instance does not exist.
	def show(url, contentType)
		contentType = contentType.sub(/\//,"_")+"_"
		@autoscalinggroup = self.getManagerOf("autoscalinggroup").getUnique(url)
		
		@links = Array.new
		raise ResourceNotFound, "ResourceNotFound: The autoscalinggroup does not exist" if @autoscalinggroup == nil

		if @autoscalinggroup != nil && @autoscalinggroup.links != nil
			@autoscalinggroup.links.split(',').each do |link|
				@links << self.getManagerOf("dependence").getUnique(link.split('/').last)
			end
		end
		erb=ERB.new(File.read(@view+contentType+'index.erb'))
		erb.result(binding)
	end

	# create
	# Create a new autoscaling group instance
	# request: _String_ the representation of the new autoscaling group instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# throws: CategoryError: throw if the mixin instances kinds
	#	 or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	# throws: ResourceNotFound : throw if the representation of the autoscalinggroup instance does not exist.
	def create(request, contentType)
		request = Request.process(request)
		request.category.each do |category|
			if category[0].downcase == "autoscalinggroup" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/autoscalinggroup#" &&
				category[2].downcase == "kind"

				val = [	request.getAttribute('occi.core.id'),
					request.getAttribute('occi.core.title'),
					'kind',
					'mixins',
					'location',
					request.getAttribute('occi.core.summary'),
					'links',
					'state',
					request.getAttribute('occi.autoscalinggroup.size'),
					request.getAttribute('occi.autoscalinggroup.min'),
					request.getAttribute('occi.autoscalinggroup.max')]
				val[8] = 0 if val[8] == nil
				val[9] = 0 if val[9] == nil
				val[10] = 1 if val[10] == nil

				autoscalingGroup = Autoscalinggroup.new(val)
				autoscalingGroup_manager = self.getManagerOf("autoscalinggroup")
				id = autoscalingGroup.id == nil ? autoscalingGroup_manager.create(autoscalingGroup): autoscalingGroup_manager.update(autoscalingGroup, true)

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
							'/autoscalinggroup/'+id.to_s,
							link[0]]
						dependence = Dependence.new(val)
						dependence_manager = self.getManagerOf("dependence")
						dependence.id == nil ? dependence_manager.create(dependence): dependence_manager.update(dependence, true)
					end
				end

				# We link the resource to the mixins
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

				Log.info "Autoscalinggroup created."
				return self.show(id, contentType)
			end
		end
		raise CategoryError, "Category Error: The kind of the ressource must be 'autoscalinggroup' and the term kind must match with this kind"
	end

	# update
	# Update an autoscaling group instance
	# request: _String_ the representation of the autoscaling group instance to update
	# full: _Boolean_ true if it's a full update, false either
	# throws: CategoryError: throw if the mixin instances kinds
	#	 or the link instances kinds don't exist
	# throws: ActionError: throw if we want to change the size of the autoscaling group instance
	#	 or if it isn't a full update and if there is a problem with the dependence of the autoscaling group.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ForbiddenError : throw if the ressource kind isn't compatible with the mixin kind.w 
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def update(url, request, full)
		request = Request.process(request)
		goodkind = false
		if full
			request.category.each do |category|
				if category[0].downcase == "autoscalinggroup" &&
				category[1].downcase == "http://schemas.ogf.org/occi/servicemanager/autoscalinggroup#" &&
				category[2].downcase == "kind"
					goodkind = true
				end
			end
		else
			goodkind = true
		end

		raise CategoryError, "Category Error: The kind of the ressource must be 'autoscalinggroup' and the term kind must match with this kind" if !goodkind

		val = [	url,
			request.getAttribute('occi.core.title'),
			'kind',
			'mixins',
			'location',
			request.getAttribute('occi.core.summary'),
			'links',
			'state',
			request.getAttribute('occi.autoscalinggroup.size'),
			request.getAttribute('occi.autoscalinggroup.min'),
			request.getAttribute('occi.autoscalinggroup.max')]
		if full
			val[8] = 0 if val[8] == nil
			val[9] = 0 if val[9] == nil
			val[10] = 1 if val[10] == nil
		end

		autoscalingGroup = Autoscalinggroup.new(val)
		raise ActionError, "Action Error: the size can be modify only with the increase or decrease actions" if autoscalingGroup.size != nil && !full
		autoscalingGroup_manager = self.getManagerOf("autoscalinggroup")
		id = autoscalingGroup_manager.update(autoscalingGroup, full)

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
					'/autoscalinggroup/'+id.to_s,
					link[0]]
				dependence = Dependence.new(val)
				dependence_manager = self.getManagerOf("dependence")
				group.id == nil ? dependence_manager.create(dependence): dependence_manager.update(dependence, full)
			end
		end

		# We link the resource to the mixins
		autoscalingGroup_manager.dissociateAllMixin(id) if full
		request.category.each_index do |i|
			if request.category[i][2] == "mixin"
				kind = request.category[i][1].split("/").last.chop.downcase 
				mixin = request.category[i][0].downcase
				if self.verifKind(kind)
					resource = Array.new() << (Array.new() << '/autoscalinggroup/'+id.to_s)
					f.getManagerOf("mixin").add(kind, mixin,resource)
				end
			end
		end

		Log.info "Autoscalinggroup updated."
		return ""
	end

	# delete
	# delete one autoscaling group instance
	# url: _String_ location url of the autoscaling group instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(url)
		self.getManagerOf("autoscalinggroup").delete(url)
		Log.info "Autoscalinggroup deleted."
	end

	# deleteAll
	# delete all autoscaling group instances
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		self.getManagerOf("autoscalinggroup").deleteAll()
		Log.info "All the autoscalinggroups are deleted."
	end

	# action
	# Apply an action to the autoscaling group instance
	# url: _String_ location url of the autoscaling group instance
	# action: _String_ action to apply
	# request: _String_ list of parameters required by the action
	# throws: ActionError: throw if the action cannot be apply to the autoscaling group instance
	#	 or if there is a problem with the dependence of the autoscaling group.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: VmError : throw if there is a connection error
	# 	or if opennebula throw an Exception.
	def action(url, action , request)
		action.downcase!
		case action
			when "start", "stop"
				self.getManagerOf("autoscalinggroup").send(action,url, 0)
			when "restart"
				self.getManagerOf("autoscalinggroup").send(action,url)
			when "increase", "decrease"
				request = Request.process(request)
				raise ActionError, "Action Error: The size is required" if request.getAttribute('size') == nil
				self.getManagerOf("autoscalinggroup").send(action,url, request.getAttribute('size').to_i)
			when "execute"
				request = Request.process(request)
				raise ActionError, "Action Error: The script is required" if request.getAttribute('script') == nil
				self.getManagerOf("autoscalinggroup").send(action,url, request.getAttribute('script'))
			else
				raise ActionError, "Action Error: Action not supported"
		end

		Log.info "Action "+action+" performed."
		return ""
	end

end
