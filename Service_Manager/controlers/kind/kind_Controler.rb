require 'erb'

class Kind_Controler
	include Controler
	def initialize
		@view = File.dirname(__FILE__)+'/views/'
	end

	# show
	# List all the resources instances of a kind
	# kind: _String_ term kind
	# contentType: _String_ the content-type of the response [text/plain, text/occi]
	# return: the list of all the resources instances of a kind
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	def show(kind, contentType)
		if self.verifKind(kind)
			contentType = contentType.sub(/\//,"_")+"_"
			@resources= self.getManagerOf(kind).getList
			erb=ERB.new(File.read(@view+contentType+'index.erb'))
		erb.result(binding)
		end
	end

	# delete
	# delete one or more resource(s) instance(s) of a kind
	# kind: _String_ term kind
	# request: _String_ list of the location url of the resources to delete
	#	 (if empty, all the resources of the kind are deleted)
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(kind, request)
		if self.verifKind(kind)
			resources = Request.process(request).location
			if !resources.empty?
				resources.each do |resource|
					resource = resource[0].split("/").last(2);
					self.getControlerOf(kind).delete(resource.last) if resource[0].downcase == kind
				end
			elsif request == ""
				self.getControlerOf(kind).deleteAll()
				Log.info "All "+kind+" resources are deleted."
			else
				raise KindNotFoundError, "KindNotFoundError: The request is not valid."
			end
			return ""
		end
	end

	# action
	# Apply an action to the resources associated instance with the kind
	# kind: _String_ term kind
	# action: _String_ action to apply
	# request _String_: list of parameters required by the action
	# throws: KindNotFoundError : throw if the kind does not exist
	# throws: ActionError: throw if the action cannot be apply to the resources of the kind
	# 	or if the action cannot be apply to the dependence instance
	# throws: DatabaseError : throw if there is a Mysql Error.
	# For autoscalinggroup instance and service instance:
	# throws: ActionError:  if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def action(kind, action, request)
		if self.verifKind(kind)
			resources = self.getManagerOf(kind).getList
			resources.each do |resource|
				id = resource.id
				self.getControlerOf(kind).action(id, action, request)
			end
			return ""
		end
	end
end
