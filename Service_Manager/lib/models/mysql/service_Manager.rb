class Service_Manager
	include Manager

	# CRUD
	# =====

	# create
	# Create a new a service instance.
	# service: _Service_ The Service instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def create(service)
		begin
			dao = Dao.getDao
			sql = "INSERT INTO service (title, summary) VALUES (?, ?)"
			st = dao.prepare(sql)
	  		st.execute(service.title, service.summary)
			last = dao.prepare('SELECT id FROM service ORDER BY id DESC LIMIT 1').execute().fetch[0]
			st.close
		
			return last
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# update
	# Update a new a service instance.
	# service: _Service_ The Service instance.
	# full: _Boolean_ true if we want a full instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def update(service, full)
		begin
			sql = "UPDATE service SET"
			vals = []
			first = true

			return service.id if service.title == nil && service.summary == nil

			rep = buildSQL("title",service.title,full)
			if rep != ""
				vals << service.title
				sql+= rep
				first = false
			end

			rep = buildSQL("summary",service.summary,full)
			if rep != ""
				vals << service.summary
				sql+= first ? "": ","
				first = false
				sql+= rep
			
			end

			vals << service.id
			sql+= " WHERE id = ?"
			dao = Dao.getDao
			st = dao.prepare(sql)
	  		case vals.length
				when 3 : st.execute(vals[0], vals[1], vals[2])
				when 2 : st.execute(vals[0], vals[1])
				else st.execute(vals[0])
			end
			st.close
		
			return service.id
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getList
	# List all the service instances.
	# return: an array of Service.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT service.id, service.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',service.id),  service.summary, links.url, service.state
FROM service
LEFT JOIN kind 
	ON kind.term = 'service'
LEFT JOIN (
	SELECT service_extension.service, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM service_extension, mixin, kind
	WHERE service_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY service_extension.service) AS mixin
	ON service.id = mixin.service
LEFT JOIN (
	SELECT group.source, group_concat(CONCAT('"+Hostname+"',kind.term,'/',group.id) SEPARATOR ',') AS url 
	FROM service_manager.group, kind
	WHERE kind.term = 'group'
	GROUP BY group.source) AS links
	ON service.id = links.source" 
	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Service.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getUnique
	# Retreive a service instance.
	# id: _String_ The id of the service.
	# return: the service instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getUnique(id)
		begin
			dao = Dao.getDao
			sql = "SELECT service.id, service.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',service.id),  service.summary, links.url, service.state
FROM service
LEFT JOIN kind 
	ON kind.term = 'service'
LEFT JOIN (
	SELECT service_extension.service, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM service_extension, mixin, kind
	WHERE service_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY service_extension.service) AS mixin
	ON service.id = mixin.service
LEFT JOIN (
	SELECT group.source, group_concat(CONCAT('"+Hostname+"',kind.term,'/',group.id) SEPARATOR ',') AS url 
	FROM service_manager.group, kind
	WHERE kind.term = 'group'
	GROUP BY group.source) AS links
	ON service.id = links.source
WHERE service.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			result = nil
	  		while row = st.fetch do
				result = Service.new(row)
			end
			st.close
			return result
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# delete
	# delete a service instance.
	# id: _Integer_ The service instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(id)
		begin
			# we stop the service
			begin
				self.stop(id)
			rescue DatabaseError => err
				Log.warn e.message+" Service :"+id
			end

			dao = Dao.getDao
			sql = "DELETE FROM service
	WHERE service.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# deleteAll
	# delete all the service instances.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		begin
			# we stop all active Services
			servs = self.getList()
			servs.each do |serv|
				begin
					self.stop(serv.id)
				rescue DatabaseError => err
					Log.warn e.message+" Service :"+serv.id
				end
			end

			dao = Dao.getDao
			sql = "DELETE FROM service" 
	 		st = dao.prepare(sql).execute()
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# ACTIONS
	# ========


	# start
	# Start a service instance.
	# id: _String_ The id of the service.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if the service is empty
	#	 or there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def start(id)
		begin
			service = self.getUnique(id)
			raise ActionError, "Action Error: The service doesn't exist." if service == nil
			if service.state != "active"
				if service.links != nil
					links = service.links.split(",")
					links.each do |link|
						# We start the autoscaling groups of the service
						idg = link.split("/").last
						group = getManagerOf("group").getUnique(idg)
						idg = group.target.split("/").last
						getManagerOf("autoscalinggroup").start(idg, 0)
					end
					dao = Dao.getDao
					sql = "UPDATE service SET state = 'active' WHERE id = ?"
					st = dao.prepare(sql).execute(id)
					st.close
				else
					raise ActionError, "Action Error: cannot start empty service"
				end
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end


	# stop
	# Stop a service instance.
	# id: _String_ The id of the service.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if the service is empty.
	def stop(id)
		begin
			service = self.getUnique(id)
			raise ActionError, "Action Error: The service doesn't exist." if service == nil
			if service.state != "inactive"
				if service.links != nil
					links = service.links.split(",")
					links.each do |link|
						# We stop the autoscaling groups of the service
						idg = link.split("/").last
						group = getManagerOf("group").getUnique(idg)
						idg = group.target.split("/").last
						getManagerOf("autoscalinggroup").stop(idg, 0)
					end
					dao = Dao.getDao
					sql = "UPDATE service SET state = 'inactive' WHERE id = ?"
					st = dao.prepare(sql).execute(id)
					st.close
				else
					raise ActionError, "Action Error: cannot stop empty service"
				end
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end


	# restart
	# Restart a service instance.
	# id: _String_ The id of the service.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if the service is empty
	#	 or there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def restart(id)
		self.stop(id)
		self.start(id)
	end

	# Others
	# =======


	# dissociateAllMixin
	# Dissociate a service of all mixin.
	# id: _String_ The id of the service.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def dissociateAllMixin(id)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM service_extension WHERE service = ?" 
	 		st = dao.prepare(sql).execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
end
