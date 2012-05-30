class Category_Manager
	include Manager

	# CRUD
	# =====

	# getList
	# List all the category instances.
	# return: an array of Category.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT id, scheme, term, title, attributes FROM category" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Category.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
end
