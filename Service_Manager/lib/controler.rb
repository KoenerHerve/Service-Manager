module Controler
	include Manager
	
	def getControlerOf(name)
		return Object.const_get(name.capitalize+"_Controler").new
	end

	# verifKind
	# Ckeck if the kind exist
	# kind: _String_ the kind
	# return: true if the kind exist.
	# throws: KindNotFoundError: throw if the kind does not exist.
	def verifKind(kind)
		case kind
			when "service", "autoscalinggroup", "dependence", "group"
				return true
			else
				raise KindNotFoundError, "KindNotFoundError: This kind does not exist"
		end
	end
end
