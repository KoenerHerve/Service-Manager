require 'erb'

class Mixin_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# List all the resources of a mixin
	# url: _String_ location url of the mixin
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the list of all the resources instances of a mixin
	# throws: KindNotFoundError : throw if the kind of the mixin does not exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	def show(url, contentType)
		url = url.split("/")
		kind = url[0]
		mixin = url.last
		if self.verifKind(kind)
			contentType = contentType.sub(/\//,"_")+"_"
			@resources= self.getManagerOf("mixin").listResources(kind, mixin)
			erb=ERB.new(File.read(@view+contentType+'index.erb'))
			erb.result(binding)
		end
	end

	# add
	# associate one or more resource(s) instance(s) with a mixin
	# url: _String_ location url of the mixin
	# request: _String_ list of the location url of the resources to associate
	# throws: KindNotFoundError : throw if the kind of the mixin does not exist
	# throws: MixinError : throw if the kind of the ressource don"t match with the kind of the mixin
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	#	(when we add an autoscaling group or a service)
	# throws: VmError : throw if there is a connection error
	# 	or if opennebula throw an Exception.
	# 	(when we add an autoscaling group or a service)
	def add(url, request)
		url = url.split("/")
		kind = url[0]
		mixin = url.last
		if self.verifKind(kind)
			resources = Request.process(request).location
			self.getManagerOf("mixin").add(kind, mixin,resources)
			Log.info "Resources added to the mixin."
			return ""
		end
	end

	# remove
	# dissociate one or more resource(s) instance(s) with a mixin
	# url: _String_ location url of the mixin
	# request: _String_ list of the location url of the resources to dissociate
	# 	(if empty, all the resources of the mixin are dissociated)
	# throws: KindNotFoundError : throw if the kind of the mixin does not exist
	# throws: MixinError : throw if the kind of the ressource don"t match with the kind of the mixin
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# (when we add an autoscaling group or a service)
	# throws: VmError : throw if there is a connection error
	# 	or if opennebula throw an Exception.
	# 	(when we add an autoscaling group or a service)
	def remove(url, request)
		url = url.split("/")
		kind = url[0]
		mixin = url.last
		if self.verifKind(kind)
			resources = Request.process(request).location
			if !resources.empty?
				self.getManagerOf("mixin").remove(kind, mixin,resources)
				Log.info "The resources are dessociated."
			elsif request == ""
				self.getManagerOf("mixin").removeAll(kind, mixin)
				Log.info "All associated resources are removed."
			else
				raise MixinError, "MixinError: The request is not valid."
			end
			return ""
		end
	end

	# action
	# Apply an action to the resources associated instance with the mixin
	# url: _String_ location url of the mixin
	# action: _String_ action to apply
	# request: _String_ list of parameters required by the action
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: ActionError: throw if the action cannot be apply to the resources associated with the mixin
	# 	or if the action cannot be apply to the dependence instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# For autoscalinggroup instance and service instance:
	# throws: ActionError:  if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error 
	# 	or if opennebula throw an Exception.
	def action(url, action, request)
		url = url.split("/")
		kind = url[0]
		mixin = url.last
		if self.verifKind(kind)
			resources = self.getManagerOf("mixin").listResources(kind, mixin)
			resources.each do |resource|
				id = resource[0].split("/").last;
				self.getControlerOf(kind).action(id, action, request)
			end
			return ""
		end
	end
end
