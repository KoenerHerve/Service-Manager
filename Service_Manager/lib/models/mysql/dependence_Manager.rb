class Dependence_Manager
	include Manager

	# CRUD
	# =====

	# create
	# Create a new a dependence instance.
	# dependence: _Dependence_ The Dependence instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def create(dependence)
		begin
			source = dependence.source.split("/").last
			target = dependence.target.split("/").last

			dao = Dao.getDao
			sql = "INSERT INTO dependence (title, source, target) VALUES (?, ?, ?)"
			st = dao.prepare(sql)
	  		st.execute(dependence.title, source, target)
			last = dao.prepare('SELECT id FROM dependence ORDER BY id DESC LIMIT 1').execute().fetch[0]
			st.close
		
			return last
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# update
	# Update a dependence instance.
	# dependence: _Dependence_ The Dependence instance.
	# full: _Boolean_ true if we want a full instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def update(dependence, full)
		begin
			sql = "UPDATE dependence SET"
			vals = []
			first = true

			return dependence.id if dependence.title == nil && dependence.source == nil && dependence.target == nil
		
			source = dependence.source == nil ? nil : dependence.source.split("/").last
			target = dependence.target == nil ? nil : dependence.target.split("/").last
		
			rep = buildSQL("title",dependence.title,full)
			if rep != ""
				vals << dependence.title
				sql+= rep
				first = false
			end

			rep = buildSQL("source",source,full)
			if rep != ""
				vals << source
				sql+= first ? "": ","
				first = false
				sql+= rep
			end

			rep = buildSQL("target",target,full)
			if rep != ""
				vals << target
				sql+= first ? "": ","
				first = false
				sql+= rep
			end

			vals << dependence.id
			sql+= " WHERE id = ?"
		
			dao = Dao.getDao
			st = dao.prepare(sql)
			case vals.length
				when 4 : st.execute(vals[0], vals[1], vals[2], vals[3])
				when 3 : st.execute(vals[0], vals[1], vals[2])
				when 2 : st.execute(vals[0], vals[1])
				else st.execute(vals[0])
			end

			st.close
		
			return dependence.id
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getList
	# List all the dependence instances.
	# return: an array of Dependence.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT dependence.id, dependence.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',dependence.id), source.url, target.url
FROM dependence
LEFT JOIN kind 
	ON kind.term = 'dependence'
LEFT JOIN (
	SELECT dependence_extension.dependence, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM dependence_extension, mixin, kind
	WHERE dependence_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY dependence_extension.dependence) AS mixin
	ON dependence.id = mixin.dependence
LEFT JOIN (
	SELECT autoscalinggroup.id, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id) AS url 
	FROM autoscalinggroup, kind
	WHERE kind.term = 'autoscalinggroup'
	) AS source
	ON dependence.source = source.id
LEFT JOIN (
	SELECT autoscalinggroup.id, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id) AS url 
	FROM autoscalinggroup, kind
	WHERE kind.term = 'autoscalinggroup'
	) AS target
	ON dependence.target = target.id" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Dependence.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getUnique
	# Retreive a dependence instance.
	# id: _String_ The id of the dependence.
	# return: the dependence instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getUnique(id)
		begin
			dao = Dao.getDao
			sql = "SELECT dependence.id, dependence.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',dependence.id), source.url, target.url
FROM dependence
LEFT JOIN kind 
	ON kind.term = 'dependence'
LEFT JOIN (
	SELECT dependence_extension.dependence, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM dependence_extension, mixin, kind
	WHERE dependence_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY dependence_extension.dependence) AS mixin
	ON dependence.id = mixin.dependence
LEFT JOIN (
	SELECT autoscalinggroup.id, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id) AS url 
	FROM autoscalinggroup, kind
	WHERE kind.term = 'autoscalinggroup'
	) AS source
	ON dependence.source = source.id
LEFT JOIN (
	SELECT autoscalinggroup.id, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id) AS url 
	FROM autoscalinggroup, kind
	WHERE kind.term = 'autoscalinggroup'
	) AS target
	ON dependence.target = target.id
WHERE dependence.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			result = nil
	  		while row = st.fetch do
				result = Dependence.new(row)
			end
			st.close
			return result
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# delete
	# delete a dependence instance.
	# id: _Integer_ The dependence instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(id)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM dependence
	WHERE dependence.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# deleteAll
	# delete all the dependence instances.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		begin
			dao = Dao.getDao
			sql = "DELETE FROM dependence" 
	 		st = dao.prepare(sql).execute()
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end


	# Others
	# =======


	# dissociateAllMixin
	# Dissociate a dependence of all mixin.
	# id: _String_ The id of the dependence.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def dissociateAllMixin(id)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM dependence_extension WHERE dependence = ?" 
	 		st = dao.prepare(sql).execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
end
