module Manager
	def getManagerOf(name)
		return Object.const_get(name.capitalize+"_Manager").new
	end

	# buildSQL
	# Build an SQL request.
	# name: _String_ Name of the column
	# value: _String_ value of the column
	# required: _Boolean_ true if the value is riquired, false otherwise
	# throws: MissingParameterError : throw if the parameter nil and required.
	# return: the SQL request.
	def buildSQL(name,value,required)
		sql = ""
		if value == nil 
			if required
				raise MissingParameterError, name+" is required"
			end
		else
			sql+= " "+name+" = ?"
		end
		return sql
	end
end
