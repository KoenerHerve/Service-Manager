class Group_Manager
	include Manager

	# CRUD
	# =====

	# create
	# Create a new a group instance.
	# group: _Group_ The Group instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def create(group)
		begin
			source = group.source.split("/").last
			target = group.target.split("/").last
			dao = Dao.getDao
			sql = "INSERT INTO service_manager.group (group.title, group.source, group.target) VALUES (?, ?, ?)"
			st = dao.prepare(sql)
	  		st.execute(group.title, source, target)
			last = dao.prepare('SELECT group.id FROM service_manager.group ORDER BY group.id DESC LIMIT 1').execute().fetch[0]
			st.close
		
			return last
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# update
	# Update a group instance.
	# group: _Group_ The Group instance.
	# full: _Boolean_ true if we want a full instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def update(group, full)
		begin
			sql = "UPDATE service_manager.group SET"
			vals = []
			first = true
		
			return group.id if group.title == nil && group.source == nil && group.target == nil

			source = group.source == nil ? nil : group.source.split("/").last
			target = group.target == nil ? nil : group.target.split("/").last
		
			rep = buildSQL("title",group.title,full)
			if rep != ""
				vals << group.title
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

			vals << group.id
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
		
			return group.id
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getList
	# List all the group instances.
	# return: an array of Group.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT group.id, group.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',group.id), source.url, target.url
FROM service_manager.group
LEFT JOIN kind 
	ON kind.term = 'group'
LEFT JOIN (
	SELECT group_extension.group, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM group_extension, mixin, kind
	WHERE group_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY group_extension.group) AS mixin
	ON group.id = mixin.group
LEFT JOIN (
	SELECT service.id, CONCAT('"+Hostname+"',kind.term,'/',service.id) AS url 
	FROM service, kind
	WHERE kind.term = 'service'
	) AS source
	ON group.source = source.id
LEFT JOIN (
	SELECT autoscalinggroup.id, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id) AS url 
	FROM autoscalinggroup, kind
	WHERE kind.term = 'autoscalinggroup'
	) AS target
	ON group.target = target.id" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Group.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getUnique
	# Retreive a group instance.
	# id: _String_ The id of the group.
	# return: the group instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getUnique(id)
		begin
			dao = Dao.getDao
			sql = "SELECT group.id, group.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',group.id), source.url, target.url
FROM service_manager.group
LEFT JOIN kind 
	ON kind.term = 'group'
LEFT JOIN (
	SELECT group_extension.group, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM group_extension, mixin, kind
	WHERE group_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY group_extension.group) AS mixin
	ON group.id = mixin.group
LEFT JOIN (
	SELECT service.id, CONCAT('"+Hostname+"',kind.term,'/',service.id) AS url 
	FROM service, kind
	WHERE kind.term = 'service'
	) AS source
	ON group.source = source.id
LEFT JOIN (
	SELECT autoscalinggroup.id, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id) AS url 
	FROM autoscalinggroup, kind
	WHERE kind.term = 'autoscalinggroup'
	) AS target
	ON group.target = target.id
WHERE group.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			result = nil
	  		while row = st.fetch do
				result = Group.new(row)
			end
			st.close
			return result
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# delete
	# delete a group instance.
	# id: _Integer_ The group instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(id)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM service_manager.group
	WHERE group.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# deleteAll
	# delete all the group instances.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		begin
			dao = Dao.getDao
			sql = "DELETE FROM service_manager.group" 
	 		st = dao.prepare(sql).execute()
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end


	# Others
	# =======


	# dissociateAllMixin
	# Dissociate a group of all mixin.
	# id: _String_ The id of the group.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def dissociateAllMixin(id)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM group_extension WHERE group = ?" 
	 		st = dao.prepare(sql).execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
end
