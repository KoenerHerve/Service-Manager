class Mixin_Manager
	include Manager

	# CRUD
	# =====

	# create
	# Create a new a mixin instance.
	# mixins: _Array_ An array of mixin instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def create(mixins)
		begin
			dao = Dao.getDao
			sql1 = "INSERT INTO mixin (title, scheme, term, attributes, kind) VALUES (?, ?, ?, ?, (SELECT id FROM kind WHERE term = ?))"
			st1 = dao.prepare(sql1)	

	
			mixins.each do |mixin|
				kind = mixin.kind
			

				st1.execute(mixin.title, mixin.scheme, mixin.term, mixin.attributes, kind)

				# the mixin relate to an other mixin
				if mixin.related != nil
					id = dao.prepare('SELECT id FROM mixin ORDER BY id DESC LIMIT 1').execute().fetch[0]
					relateds = mixin.related.split(',')

					sql2 = "INSERT INTO mixin_relation (mixin, related) VALUES (?, ?)"
					st2 = dao.prepare(sql2)	
				
					# for each related mixin, we check if the his kind is the same as the kind of the new mixin
					relateds.each do |related|
						begin
							rel = related.split('/').last.split('#')
							raise MixinError, "MixinError: The kind of the related mixin is different of the kind of the current mixin: "+kind+"!="+rel[0]+"." if kind != rel[0]

							rel = self.getUnique(rel[0], rel.last)
					
							#if the kind does not exist, we throw an excetion
							raise KindNotFoundError, "Kind Error: the related kind doesn't exist: "+related+"." if rel == nil
							st2.execute(id, rel.id)
						rescue KindNotFoundError => e
							Log.warn e.message
						end
					end
					st2.close
				end

			end
			st1.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getList
	# List all the mixin instances.
	# return: an array of Mixin.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT mixin.id, mixin.scheme, mixin.term, mixin.title, mixin.attributes,CONCAT(kind.scheme,kind.term), action.url, CONCAT('"+Hostname+"',kind.term,'/',mixin.term,'/'), related.url
FROM mixin
LEFT JOIN kind
	ON mixin.kind = kind.id
LEFT JOIN (
	SELECT mixin_relation.mixin, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM mixin, mixin_relation
	WHERE mixin_relation.related = mixin.id 
	GROUP BY mixin_relation.mixin) AS related
	ON mixin.id = related.mixin
LEFT JOIN (
	SELECT action.mixin, group_concat(CONCAT(category.scheme,category.term) SEPARATOR ',') AS url 
	FROM category, action 
	WHERE action.category = category.id 
	GROUP BY action.mixin) AS action 
	ON mixin.id = action.mixin" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Mixin.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getUnique
	# Retreive a mixin instance.
	# kind: _String_ The kind term of the mixin.
	# mixin: _String_ The term of the mixin.
	# return: the mixin instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getUnique(kind, mixin)
		begin
			dao = Dao.getDao
			sql = "SELECT mixin.id, mixin.scheme, mixin.term, mixin.title, mixin.attributes,CONCAT(kind.scheme,kind.term), action.url, CONCAT('"+Hostname+"',kind.term,'/',mixin.term,'/'), related.url
FROM mixin
LEFT JOIN kind
	ON mixin.kind = kind.id
LEFT JOIN (
	SELECT mixin_relation.mixin, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM mixin, mixin_relation
	WHERE mixin_relation.related = mixin.id 
	GROUP BY mixin_relation.mixin) AS related
	ON mixin.id = related.mixin
LEFT JOIN (
	SELECT action.mixin, group_concat(CONCAT(category.scheme,category.term) SEPARATOR ',') AS url 
	FROM category, action 
	WHERE action.category = category.id 
	GROUP BY action.mixin) AS action 
	ON mixin.id = action.mixin
WHERE kind.term = ? AND kind.id = mixin.kind AND mixin.term = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(kind, mixin)
			result = nil
	  		while row = st.fetch do
				result = Mixin.new(row)
			end
			st.close
			return result
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# delete
	# delete one or more mixins instances.
	# mixin: _Array_ An array containing the mixins instances.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(mixins)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM mixin
	WHERE scheme = ? AND term = ? and userMixin = 1" 
	 		st = dao.prepare(sql)
			mixins.each do |mixin|
	  			st.execute(mixin.scheme, mixin.term)
			end
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# deleteAll
	# delete all the mixin instances.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		begin
			dao = Dao.getDao
			sql = "DELETE FROM mixin WHERE userMixin = 1" 
	 		st = dao.prepare(sql).execute()
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# OTHERS
	# =======

	# listResources
	# Retreive all resources instances associate with a mixin.
	# kind: _String_ The kind term of the mixin.
	# mixin: _String_ The term of the mixin.
	# return: An array of the resource instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def listResources(kind, mixin)
		begin
			raise DatabaseError, "DatabaseError: The mixin \""+mixin+"\" does'nt exist" if !exist?(kind, mixin)
			results = []
			dao = Dao.getDao
			sql = "SELECT CONCAT('"+Hostname+"',kind.term,'/',"+kind+".id)
			FROM "+kind+", kind, mixin, "+kind+"_extension
			WHERE 	"+kind+"_extension."+kind+" = "+kind+".id AND
				"+kind+"_extension.mixin = mixin.id AND
				kind.term = ? AND kind.id = mixin.kind  AND mixin.term = ?"
	 		st = dao.prepare(sql)
	  		st.execute(kind, mixin)

	  		while row = st.fetch do
				results << row
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# add
	# Associate one or more resource instance with a mixin.
	# kind: _String_ The kind term of the mixin.
	# mixin: _String_ The term of the mixin.
	# resources: _Array_ An array of resources to associate with the mixin.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	#	 (when we add an autoscaling group or a service)
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	#	 (when we add an autoscaling group or a service)
	def add(kind, mixin, resources)
		begin
			raise DatabaseError, "DatabaseError: The mixin \""+mixin+"\" does'nt exist" if !exist?(kind, mixin)
			dao = Dao.getDao
			sql = "INSERT INTO "+kind+"_extension (mixin, "+kind+") VALUES ((SELECT mixin.id FROM mixin, kind WHERE kind.term = ? AND kind.id = mixin.kind AND mixin.term = ?),?)"
	 		st = dao.prepare(sql)
			st2 = dao.prepare("SELECT "+kind+"_extension.id FROM "+kind+"_extension, mixin, kind WHERE 
kind.term = ? 
AND kind.id = mixin.kind  
AND mixin.term = ? 
AND mixin.id = "+kind+"_extension.mixin 
AND "+kind+"_extension."+kind+" = ? ")

			resources.each do |resource|
				resource = resource[0].split("/")
				# We check if the ressource kind is compatible with the mixin kind
				rsKind = resource.last(2)[0]
				begin
					if rsKind == kind
						id = resource.last
						resource = self.getManagerOf(kind).getUnique(id)
						raise MixinError, "MixinError: The resource ("+id+") does not exist." if resource == nil

						st2.execute(kind, mixin, id)
						# IF there is no association, we can associate the resource with the mixin
			  			if st2.fetch == nil 
							st.execute(kind, mixin, id)
							# We restart if necessary
							self.getManagerOf(kind).restart(id) if resource.state == "active" && (rsKind == "autoscalinggroup" || rsKind == "service" )
						end
					else
						st.close
						raise MixinError, "MixinError: The ressource kind isn't compatible with the mixin kind."
					end
				rescue MixinError => e
					Log.warn e.message
				end
			end

			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# remove
	# Dissociate one or more resource instance with a mixin.
	# kind: _String_ The kind term of the mixin.
	# mixin: _String_ The term of the mixin.
	# resources: _Array_ An array of resources to dissociate with the mixin.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	#	 (when we add an autoscaling group or a service)
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	#	 (when we add an autoscaling group or a service)
	def remove(kind, mixin, resources)
		begin
			raise DatabaseError, "DatabaseError: The mixin \""+mixin+"\" does'nt exist" if !exist?(kind, mixin)
			dao = Dao.getDao
			sql = "DELETE FROM "+kind+"_extension WHERE mixin = (SELECT mixin.id FROM mixin, kind WHERE kind.term = ? AND kind.id = mixin.kind AND mixin.term = ?) AND "+kind+" = ?"
	 		st = dao.prepare(sql)

			resources.each do |resource|
				resource = resource[0].split("/")
				rsKind = resource.last(2)[0]
				begin
					if rsKind == kind
						id = resource.last
						resource = self.getManagerOf(kind).getUnique(id)
						raise MixinError, "MixinError: The resource ("+id+") does not exist." if resource == nil

			  			st.execute(kind, mixin, id)
						# We restart if necessary
						self.getManagerOf(kind).restart(id) if resource.state == "active" && (rsKind == "autoscalinggroup" || rsKind == "service" )
					else
						st.close
						raise MixinError, "MixinError: The resource kind isn't compatible with the mixin kind."
					end
				rescue MixinError => e
					Log.warn e.message
				end
			end

			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# removeAll
	# Dissociate all resources from mixins.
	# kind: _String_ The kind term of the mixin.
	# mixin: _String_ The term of the mixin.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def removeAll(kind, mixin)
		begin
			raise DatabaseError, "DatabaseError: The mixin \""+mixin+"\" does'nt exist" if !exist?(kind, mixin)
			dao = Dao.getDao
			sql = "DELETE FROM "+kind+"_extension WHERE mixin = (SELECT mixin.id FROM mixin, kind WHERE kind.term = ? AND kind.id = mixin.kind AND mixin.term = ?)"
	 		st = dao.prepare(sql)
			st.execute(kind, mixin)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# relatedTo?
	# Retreive all the related mixins.
	# mixin: _String_ The location of the mixin.
	# related: _String_ The location of the related mixin.
	# return: an array of related mixin
	# throws: DatabaseError : throw if there is a Mysql Error.
	def relatedTo?(mixin, related)
		arr = Array.new

		mixin = self.getUnique(mixin.split('/').last.split('#')[0], mixin.split('#').last)

		return arr if mixin == nil || mixin.related == nil
		rels = mixin.related.split(',')
		
		rels.each do |rel|
			if rel == related
				arr << mixin
				return arr
			end

			arr += self.relatedTo?(rel, related)
		end

		return arr
	end

	private

	# exist?
	# Check if the mixin exist.
	# kind: _String_ The kind term of the mixin.
	# mixin: _String_ The term of the mixin.
	# return: true if the mixin exist, false otherwise
	# throws: DatabaseError : throw if there is a Mysql Error.
	def exist?(kind, mixin)
		begin
			dao = Dao.getDao
			sql = "SELECT mixin.id FROM mixin, kind WHERE kind.term = ? AND kind.id = mixin.kind AND mixin.term = ?"
	 		st = dao.prepare(sql)
			st.execute(kind, mixin)
			ret = st.fetch != nil
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
		return ret
	end
end
