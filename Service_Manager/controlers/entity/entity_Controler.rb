require 'erb'

class Entity_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# Display the representation of the entity instance
	# kind: _String_ kind term of the entity
	# url: _String_ location url of the entity
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the representation of the entity instance
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ResourceNotFound : throw if the representation of the resource instance does not exist.
	def show(kind, url, contentType)
		if self.verifKind(kind)
			return self.getControlerOf(kind).show(url, contentType)
		end
	end

	# create
	# Create a new entity instance
	# kind: _String_ kind term of the entity
	# request: _String_ the representation of the new entity instance
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# throws: KindNotFoundError: throw if the mixin instances kinds
	# 	or the link instances kinds don't exist
	# throws: MixinError : throw if the resource kind isn't compatible with the mixin kind.
	# throws: CategoryError: throw if the mixin instances kinds
	#	or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group
	#	(if the resource is an autoscaling group or if it's a service and it contain autoscaling group).
	# throws: VmError : throw if there is a connection error
	#	or if opennebula throw an Exception
	#	(if the resource is an autoscaling group or if it's a service and it contain autoscaling group).
	# throws: ResourceNotFound : throw if the representation of the resource instance does not exist.
	def create(kind, request, contentType)
		if self.verifKind(kind)
			return self.getControlerOf(kind).create(request, contentType)
		end
	end

	# update
	# Update an entity instance
	# kind: _String_ kind term of the entity
	# request: _String_ the representation of the entity instance to update
	# full: _Boolean_ true if it's a full update, false either
	# throws: KindNotFoundError: throw if the mixin instances kinds
	#	or the link instances kinds don't exist
	# throws: MixinError : throw if the resource kind isn't compatible with the mixin kind.
	# throws: CategoryError: throw if the mixin instances kinds
	#	or the link instances kinds don't exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group
	# 	(if the resource is an autoscaling group or if it's a service and it contain autoscaling group)
	# 	or if we want to change the size of an autoscaling group instance and if it isn't a full update.
	# throws: VmError : throw if there is a connection error
	# 	or if opennebula throw an Exception
	# 	(if the resource is an autoscaling group or if it's a service and it contain autoscaling group).
	def update(kind, url, request, full)
		if self.verifKind(kind)
			self.getControlerOf(kind).update(url, request, full)
			return ""
		end
	end

	# delete
	# delete one entity instance
	# kind: _String_ kind term of the entity
	# url: _String_ location url of the entity instance
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(kind, url)
		if self.verifKind(kind)
			self.getControlerOf(kind).delete(url)
			return ""
		end
	end

	# action
	# Apply an action to the entity instance
	# kind: _String_ kind term of the entity
	# url: _String_ location url of the entity instance
	# action: _String_ action to apply
	# request: _String_ list of parameters required by the action
	# throws: ActionError: throw if the action cannot be apply to the entity instance
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: ActionError: throw if the action cannot be apply to the dependence instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# For autoscalinggroup instance and service instance:
	# throws: ActionError:  if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error 
	# 	or if opennebula throw an Exception.
	def action(kind, url, action , request)
		if self.verifKind(kind)
			self.getControlerOf(kind).action(url, action, request)
			return ""
		end
	end
end
