require 'curb'

class Autoscalinggroup_Manager
	include Manager

	# CRUD
	# =====

	# create
	# Create a new a autoscalinggroup instance.
	# asg: _Autoscalinggroup_ The Autoscalinggroup instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def create(asg)
		begin
			asg.max = asg.min if asg.max < asg.min
			asg.size = asg.min if asg.size < asg.min
			asg.size = asg.max if asg.size > asg.max

			dao = Dao.getDao
			sql = "INSERT INTO autoscalinggroup (title, summary, size, min, max) VALUES (?, ?, ?, ?, ?)"
			st = dao.prepare(sql)
	  		st.execute(asg.title, asg.summary, asg.size, asg.min, asg.max)
			last = dao.prepare('SELECT id FROM autoscalinggroup ORDER BY id DESC LIMIT 1').execute().fetch[0]
		
			st.close
		
			return last
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# update
	# Update a new a autoscalinggroup instance.
	# asg: _Autoscalinggroup_ The Autoscalinggroup instance.
	# full: _Boolean_ true if we want a full instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def update(asg, full)
		begin
			sql = "UPDATE autoscalinggroup SET"
			vals = []
			first = true

			return asg.id if asg.title == nil && asg.summary == nil && asg.min == nil && asg.max == nil
			asg2 = self.getUnique(asg.id)

			rep = buildSQL("title",asg.title,full)
			if rep != ""
				vals << asg.title
				sql+= rep
				first = false
			end

			rep = buildSQL("summary",asg.summary,full)
			if rep != ""
				vals << asg.summary
				sql+= first ? "": ","
				first = false
				sql+= rep
			
			end

			rep = buildSQL("min",asg.min,full)
			if rep != ""
				# The min cannot be greater than the current size
				asg.min = asg2.size if asg2 != nil && asg.min > asg2.size
				asg.min = 0 if asg.min < 0
				vals << asg.min
				sql+= first ? "": ","
				first = false
				sql+= rep
			
			end

			rep = buildSQL("max",asg.max,full)
			if rep != ""
				# The max cannot be smaller than the current size
				asg.max = asg2.size if asg2 != nil &&  asg.max < asg2.size
				asg.max = 0 if asg.max < 0
				vals << asg.max
				sql+= first ? "": ","
				first = false
				sql+= rep
			
			end

			vals << asg.id
			sql+= " WHERE id = ?"

			dao = Dao.getDao
			st = dao.prepare(sql)
	  		case vals.length
				when 5 : st.execute(vals[0], vals[1], vals[2], vals[3], vals[4])
				when 4 : st.execute(vals[0], vals[1], vals[2], vals[3])
				when 3 : st.execute(vals[0], vals[1], vals[2])
				when 2 : st.execute(vals[0], vals[1])
				else st.execute(vals[0])
			end
			st.close
		
			return asg.id
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getList
	# List all the autoscalinggroup instances.
	# return: an array of Autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getList
		begin
			dao = Dao.getDao
			sql = "SELECT autoscalinggroup.id, autoscalinggroup.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id),  autoscalinggroup.summary, links.url, autoscalinggroup.state, autoscalinggroup.size, autoscalinggroup.min, autoscalinggroup.max, vm.url
FROM autoscalinggroup
LEFT JOIN kind 
	ON kind.term = 'autoscalinggroup'
LEFT JOIN (
	SELECT vm.autoscalinggroup, group_concat(vm.url SEPARATOR ',') AS url 
	FROM vm
	GROUP BY vm.autoscalinggroup) AS vm
	ON autoscalinggroup.id = vm.autoscalinggroup
LEFT JOIN (
	SELECT autoscalinggroup_extension.autoscalinggroup, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM autoscalinggroup_extension, mixin, kind
	WHERE autoscalinggroup_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY autoscalinggroup_extension.autoscalinggroup) AS mixin
	ON autoscalinggroup.id = mixin.autoscalinggroup
LEFT JOIN (
	SELECT dependence.source, group_concat(CONCAT('"+Hostname+"',kind.term,'/',dependence.id) SEPARATOR ',') AS url 
	FROM dependence, kind
	WHERE kind.term = 'dependence'
	GROUP BY dependence.source) AS links
	ON autoscalinggroup.id = links.source"

	 		st = dao.prepare(sql)
	  		st.execute
			results = []
	  		while row = st.fetch do
				results << Autoscalinggroup.new(row)
			end
			st.close
			return results
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# getUnique
	# Retreive a autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# return: the autoscalinggroup instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getUnique(id)
		begin
			dao = Dao.getDao
			sql = "SELECT autoscalinggroup.id, autoscalinggroup.title, kind.scheme, mixin.url, CONCAT('"+Hostname+"',kind.term,'/',autoscalinggroup.id),  autoscalinggroup.summary, links.url, autoscalinggroup.state, autoscalinggroup.size, autoscalinggroup.min, autoscalinggroup.max, vm.url
FROM autoscalinggroup
LEFT JOIN kind 
	ON kind.term = 'autoscalinggroup'
LEFT JOIN (
	SELECT vm.autoscalinggroup, group_concat(vm.url SEPARATOR ',') AS url 
	FROM vm
	GROUP BY vm.autoscalinggroup) AS vm
	ON autoscalinggroup.id = vm.autoscalinggroup
LEFT JOIN (
	SELECT autoscalinggroup_extension.autoscalinggroup, group_concat(CONCAT(mixin.scheme,mixin.term) SEPARATOR ',') AS url 
	FROM autoscalinggroup_extension, mixin, kind
	WHERE autoscalinggroup_extension.mixin = mixin.id AND mixin.kind = kind.id
	GROUP BY autoscalinggroup_extension.autoscalinggroup) AS mixin
	ON autoscalinggroup.id = mixin.autoscalinggroup
LEFT JOIN (
	SELECT dependence.source, group_concat(CONCAT('"+Hostname+"',kind.term,'/',dependence.id) SEPARATOR ',') AS url 
	FROM dependence, kind
	WHERE kind.term = 'dependence'
	GROUP BY dependence.source) AS links
	ON autoscalinggroup.id = links.source
WHERE autoscalinggroup.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			result = nil
	  		while row = st.fetch do
				result = Autoscalinggroup.new(row)
			end
			st.close
			return result
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# delete
	# delete a autoscalinggroup instance.
	# id: _Integer_ The autoscalinggroup instance.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def delete(id)
		begin
			# we stop the AutoScaling Group
			begin
				self.stop(id,0)
			rescue DatabaseError => err
				Log.warn e.message+" AutoScaling Group :"+id
			end

			dao = Dao.getDao
			# deletion of the vms
			sql = "Select url FROM vm WHERE autoscalinggroup = ?" 
	 		st = dao.prepare(sql).execute(id)
			while row = st.fetch do
				getManagerOf("vm").delete(row[0])
			end

			sql = "DELETE FROM autoscalinggroup
	WHERE autoscalinggroup.id = ?" 
	 		st = dao.prepare(sql)
	  		st.execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# deleteAll
	# delete all the autoscalinggroup instances.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def deleteAll()
		begin
			# we stop all active AutoScaling Groups
			asgs = self.getList()
		
			asgs.each do |asg|
				begin
					self.stop(asg.id,0)
				rescue DatabaseError => err
					Log.warn e.message+" AutoScaling Group :"+asg.id
				end
			end

			dao = Dao.getDao
			# deletion of all the vms
			sql = "Select url FROM vm" 
	 		st = dao.prepare(sql).execute()
			while row = st.fetch do
				getManagerOf("vm").delete(row[0])
			end
		
			sql = "DELETE FROM autoscalinggroup" 
	 		st = dao.prepare(sql).execute()
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# ACTIONS
	# ========


	# start
	# Start an autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# nbRec: _Integer_ Number of recursive call. 0 if its the first time we call the method.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def start(id, nbRec)
		begin
			asg = self.getUnique(id)
			raise ActionError, "Action Error: The autoscaling group doesn't exist." if asg == nil
			if asg.state != "active"
				if nbRec < MaxRecursive
					nbRec+=1
					if asg.links != nil
						links = asg.links.split(",")
						links.each do |link|
							# We start the dependences
							idg = link.split("/").last
							dependence = getManagerOf("dependence").getUnique(idg)
							idg = dependence.target.split("/").last
							getManagerOf("autoscalinggroup").start(idg, nbRec)
						end
					end
					dao = Dao.getDao
					# if there is no vm linked to this autoscaling group
					# (when it's the first time we launch the service manager)
					if asg.vms == nil
						if asg.size > 0
							# we increase the number of vm
							sql = "INSERT INTO vm (url, autoscalinggroup) VALUES (?,?)"
							st = dao.prepare(sql)
							instanceType = getInstanceType(id)
							storage_name = getOs(id)
							vm_id = 0

							asg.size.times do
								vm = getManagerOf("vm").create(id.to_s+'-'+vm_id.to_s, instanceType, storage_name)
					  			st.execute(vm, id)
								vm_id+=1
								scripts = getScripts(id, 'boot')
								# we execute the script on the vm
								scripts.each do |script|
									getManagerOf("vm").execute(vm, script)
								end
							end

						else
							self.increase(id, 1)
						end
						asg = self.getUnique(id)
					end

					vms = asg.vms.split(",")
					vms.each do |vm|
						# We start the vms
						getManagerOf("vm").start(vm)
						scripts = getScripts(id, 'operational')
						# we execute the script on the vm
						scripts.each do |script|
							getManagerOf("vm").execute(vm, script)
						end
					end

					sql = "UPDATE autoscalinggroup SET state = 'active' WHERE id = ?"
					st = dao.prepare(sql).execute(id)
					st.close
				else
					raise ActionError, "Action Error: The dependence chain is too long. You can change the constant MaxRecursive to resovl this problem."
				end
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end	
	end

	# stop
	# Stop an autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# nbRec: _Integer_ Number of recursive call. 0 if its the first time we call the method.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def stop(id, nbRec)
		begin
			asg = self.getUnique(id)
			raise ActionError, "Action Error: The autoscaling group doesn't exist." if asg == nil
			if asg.state != "inactive"
				if nbRec < MaxRecursive
					nbRec+=1
					if asg.links != nil
						links = asg.links.split(",")
						links.each do |link|
							# We stop the dependences
							idg = link.split("/").last
							dependence = getManagerOf("dependence").getUnique(idg)
							idg = dependence.target.split("/").last
							getManagerOf("autoscalinggroup").stop(idg, nbRec)
						end
					end
					if asg.vms != nil
						vms = asg.vms.split(",")
						vms.each do |vm|
							# we execute the script on the vm
							scripts = getScripts(id, 'decommission')
							scripts.each do |script|
								getManagerOf("vm").execute(vm, script)
							end
							# We stop the vms
							getManagerOf("vm").stop(vm)
						end
					end

					dao = Dao.getDao
					sql = "UPDATE autoscalinggroup SET state = 'inactive' WHERE id = ?"
					st = dao.prepare(sql).execute(id)
					st.close
				else
					raise ActionError, "Action Error: The dependence chain is too long. You can change the constant MaxRecursive to resovl this problem."
				end
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# restart
	# Restart an autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def restart(id)
		self.stop(id, 0)
		self.start(id, 0)
	end

	# increase
	# Increase the size of the autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# size: _Integer_ The number of vm to add to the autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def increase(id, size)
		begin
			asg = self.getUnique(id)
			raise ActionError, "Action Error: The autoscaling group doesn't exist." if asg == nil
			if (asg.size+size) < asg.min || (asg.size+size) > asg.max
				raise ActionError, "Action Error: The size cannot be greater than "+asg.max.to_s+" and smaller than "+asg.min.to_s
			else
				dao = Dao.getDao
				sql = "UPDATE autoscalinggroup SET size = ? WHERE id = ?"
				st = dao.prepare(sql).execute(asg.size+size,id)

				# we increase the number of vm
				sql = "INSERT INTO vm (url, autoscalinggroup) VALUES (?,?)"
				st = dao.prepare(sql) if size > 0
				instanceType = getInstanceType(id)
				storage_name = getOs(id)
				vm_id = asg.size
			
				size.times do
					vm = getManagerOf("vm").create(id.to_s+'-'+vm_id.to_s, instanceType, storage_name)
		  			st.execute(vm, id)
					getManagerOf("vm").stop(vm) if asg.state == "inactive"
					vm_id+=1
					scripts = getScripts(id, 'boot')
					# we execute the script on the vm
					scripts.each do |script|
						getManagerOf("vm").execute(vm, script)
					end
				end
				st.close if size > 0
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# decrease
	# Decrease the size of the autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# size: _Integer_ The number of vm to remove to the autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def decrease(id, size)
		begin
			asg = self.getUnique(id)
			raise ActionError, "Action Error: The autoscaling group doesn't exist." if asg == nil
			if (asg.size-size) < asg.min || (asg.size-size) > asg.max
				raise ActionError, "Action Error: The size cannot be greater than "+asg.max.to_s+" and smaller than "+asg.min.to_s
			else
				dao = Dao.getDao
				sql = "UPDATE autoscalinggroup SET size = ? WHERE id = ?"
				st = dao.prepare(sql).execute(asg.size-size,id)

				# we decrease the number of vm
				vms = asg.vms.split(",")
				sql = "DELETE FROM vm WHERE url = ?"
				st = dao.prepare(sql) if size > 0
				size.times do
					scripts = getScripts(id, 'decomission')
					# we execute the script on the vm
					scripts.each do |script|
						getManagerOf("vm").execute(vm, script)
					end

					getManagerOf("vm").delete(vms.last)
		  			st.execute(vms.last)
				end
				st.close
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end


	# execute
	# Execute a script on a autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# script: _String_ The script to execute.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def execute(id, script)
		begin
			asg = self.getUnique(id)
			raise ActionError, "Action Error: The autoscaling group doesn't exist." if asg == nil
			if asg.size < 0
				vms = asg.vm.split(",")
				vms.each do |vm|
					# We start the vms
					getManagerOf("vm").execute(vm, script)
				end
			else
				raise ActionError, "Action Error: There is no vm to execute this script. size:"+asg.size.to_s
			end
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end
	
	# Others
	# =======

	# dissociateAllMixin
	# Dissociate a autoscalinggroup of all mixin.
	# id: _String_ The id of the autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def dissociateAllMixin(id)
		begin
			dao = Dao.getDao
			sql = "DELETE FROM autoscalinggroup_extension WHERE autoscalinggroup = ?" 
	 		st = dao.prepare(sql).execute(id)
			st.close
		rescue Mysql::Error => e
			raise DatabaseError, "DatabaseError: "+e.message
		end
	end

	# Private Method
	# ==============

	private

	# getScripts
	# Get the scripts list of an autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# type: _String_ The type of the script.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def getScripts(id, type)
		mixins = getMixin(id, "http://schemas.ogf.org/serviceManager/autoscalinggroup#script_tpl")
		scripts = Array.new

		mixins.each do |mixin|
			attributes = mixin.attributes
			regex = Regexp.new('occi\.autoscalinggroup\.script\s*=\s*"((?:[^"]|\\\")*)"\s*,\s*occi\.autoscalinggroup\.url\s*=\s*"([^"]*)"\s*,\s*occi\.autoscalinggroup\.type\s*=\s*"([^"]*)"\s*,\s*occi\.autoscalinggroup\.runlevel\s*=\s*"([^"]*)"((?:\s*,\s*[\w_\-\.]+\s*=\s*"[^"]*")*)')

			mainAttributes = regex.match(attributes)
			# the script have the good type
			if mainAttributes != nil && mainAttributes[3] == type
				vars = mainAttributes[5].scan(Regexp.new('\s*,\s*([\w_\-\.]+)\s*=\s*"(.*)"'))
				script = ""
				vars.each do |var|
					mx = Regexp.new('Mx\[(.*),(\w*)\]').match(var[1])
					if mx != nil
						# linked attribute
						mxvals = getMxValue(id, mx[1], mx[2])
						script+= var[0]+"=("
						mxvals.each do |mxval|
							script+= " "+mxval
						end
						script+=")\n"				
					else
						script+= var[0]+"="+var[1]+"\n"
					end

				end

				if mainAttributes[2] != ""
					# occi.autoscalinggroup.url is not null
					begin
						c = Curl::Easy.perform(mainAttributes[2])
						script+= c.body_str
					rescue Curl::Err::CurlError => e
						raise VmError, "VmError: "+e.message+"\nURL: "+mainAttributes[2]
					end
				else
					script+= mainAttributes[1].gsub(/\\\"/,'"')
				end

				scripts << script

			end
		end

		return scripts
	end
	
	# getOs
	# Get the os type of an autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getOs(id)
		mixins = getMixin(id, "http://schemas.ogf.org/occi/infrastructure#os_tpl")
		return !mixins.empty? ? mixins[0].term : Default_imageName
	end

	# getInstanceType
	# Get the instance type of an autoscalinggroup instance.
	# id: _String_ The id of the autoscalinggroup.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getInstanceType(id)
		mixins = getMixin(id, "http://schemas.ogf.org/occi/infrastructure#resource_tpl")
		return !mixins.empty? ? mixins[0].term : Default_instanceType
	end

	# getMixin
	# Get the mixin list related to a certain mixin.
	# id: _String_ The id of the autoscalinggroup.
	# related: _String_ The related mixin.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def getMixin(id, related)
		arr = Array.new
		mixins = self.getUnique(id).mixins
		return arr if mixins == nil
		mixins = mixins.split(',')
		mixins.each do |mixin|
			arr += getManagerOf("mixin").relatedTo?(mixin, related)
		end
		return arr
	end

	# getMxValue
	# Get the value of a linked attribute.
	# id: _String_ The id of the autoscalinggroup.
	# mixin: _String_ The mixin of the attribute.
	# attribute: _String_ The attribute name.
	# related: _String_ The related mixin.
	# throws: DatabaseError : throw if there is a Mysql Error.
	# throws: ActionError : throw if there is a problem with the dependence of the autoscaling group.
	# throws: VmError : throw if there is a connection error
	#	 or if opennebula throw an Exception.
	def getMxValue(id, mixin, attribute)
		values = Array.new
		resource = self.getUnique(id)
		dependences = resource.links
		if dependences != nil
			dependences = dependences.split(',')
			find = false
			asg = nil
			#for each dependences
			dependences.each do |dependence|
				dependence = dependence.split('/').last
				dependence = getManagerOf("dependence").getUnique(dependence)
				idDep = dependence.target.split('/').last
				mixins = getMixin(idDep, mixin)
				(asg=self.getUnique(idDep);break) if !mixins.empty?
			end
			
			if asg != nil
				if asg.vms != nil
					vms = asg.vms.split(",")
					vms.each do |vm|
						# We start the vms
						values << getManagerOf("vm").getValue(vm, attribute)

					end

				else
					raise ActionError, "Action Error: The dependence ("+asg.location+") have no vm"
				end

			else
				raise ActionError, "Action Error: There is no dependence linked to the mixin: "+mixin+" for the ressource: "+resource.location

			end
		else
			raise ActionError, "Action Error: The resource ("+resource.location+") have no dependence"

		end
		return values
	end
end
