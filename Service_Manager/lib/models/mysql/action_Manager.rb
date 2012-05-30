class Action_Manager
	include Manager

	# CRUD
	# =====

	# getList
	# List all the action instances.
	# return: an array of Action.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT action.id, CONCAT(category.scheme,category.term), CONCAT(kind.scheme,kind.term), CONCAT(mixin.scheme,mixin.term)
	FROM action, category, kind, mixin  WHERE action.category = category.id, action.kind = category.kind, action.mixin = category.mixin" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Action.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
end
