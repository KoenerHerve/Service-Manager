class Kind_Manager
	include Manager

	# CRUD
	# =====

	# getList
	# List all the kind instances.
	# return: an array of Kind.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT kind.id, kind.scheme, kind.term, kind.title, kind.attributes, kind.entity_type, CONCAT(rel.scheme,rel.term), action.url, mixin.url, CONCAT('"+Hostname+"',kind.term,'/') 
FROM kind
LEFT JOIN kind 
	AS rel
	ON kind.related = rel.id
LEFT JOIN (
	SELECT action.kind, group_concat(CONCAT(category.scheme,category.term) SEPARATOR ',') AS url 
	FROM category, action
	WHERE action.category = category.id GROUP BY action.kind) AS action
	ON kind.id = action.kind
LEFT JOIN (
	SELECT mixin.kind, group_concat(CONCAT('"+Hostname+"',kind.term,'/',mixin.term,'/') SEPARATOR ',') AS url
	FROM mixin, kind
	WHERE kind.id = mixin.kind
	GROUP BY mixin.kind) AS mixin
	ON kind.id = mixin.kind" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Kind.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getUnique
	# Retreive a kind instance.
	# url: _String_ The kind term.
	# return: the Kind instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getUnique(url)
		begin
			dao = Dao.getDao
			sql = "SELECT kind.id, kind.scheme, kind.term, kind.title, kind.attributes, kind.entity_type, CONCAT(rel.scheme,rel.term), action.url, mixin.url, CONCAT('"+Hostname+"',kind.term) 
FROM kind
LEFT JOIN kind 
	AS rel
	ON kind.related = rel.id
LEFT JOIN (
	SELECT action.kind, group_concat(CONCAT(category.scheme,category.term) SEPARATOR ',') AS url 
	FROM category, action
	WHERE action.category = category.id GROUP BY action.kind) AS action
	ON kind.id = action.kind
LEFT JOIN (
	SELECT mixin.kind, group_concat(CONCAT('"+Hostname+"',kind.term,'/',mixin.term) SEPARATOR ',') AS url
	FROM mixin, kind
	WHERE kind.id = mixin.kind
	GROUP BY mixin.kind) AS mixin
	ON kind.id = mixin.kind
WHERE kind.term = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(url)
	  		while row = st.fetch do
				results = Kind.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
end
