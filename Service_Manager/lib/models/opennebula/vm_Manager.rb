require 'digest/sha1'
require 'curb'
require 'nokogiri'
require 'ping'

class Vm_Manager
	include Manager

	@@network = nil
	@@storage = nil

	# CRUD
	# =====

	# create
	# Create a new instance of vm.
	# id: _String_ The id of the vm.
	# instanceType:  _String_ The instance type of the vm.
	# storage_name:  _String_ The name of the storage instance.
	# return: the url of the new instance of vm.
	# throws: VmError : throw if there is a connection error or if opennebula throw an Exception.
	def create(id, instanceType, storage_name)
		begin
			network = Vm_Manager.getNetwork
			xml = "<COMPUTE>
				<NAME>VM"+id+"</NAME>
				<INSTANCE_TYPE   href='http://localhost:4567/instance_type/"+instanceType+"' />
				<DISK>
					<STORAGE href='"+Vm_Manager.getStorage(storage_name)+"'/>
				</DISK>
				<NIC>
					<NETWORK href='"+network+"'/>
				</NIC>
				<CONTEXT>
					<HOSTNAME>$name</HOSTNAME>
					<IP>$NIC[IP, NETWORK_ID="+network.split('/').last+"]</IP>
					<NETMASK>255.255.255.0</NETMASK>
					<FILES>"+File.expand_path("images/"+storage_name+"/init.sh")+" "+File.expand_path("~/.ssh/id_rsa.pub")+" "+File.expand_path("images/context/service.rb")+" "+File.expand_path("images/context/cmd.sh")+" "+File.expand_path("images/context/client.rb")+"</FILES>
					<ROOT_PUBKEY>id_rsa.pub</ROOT_PUBKEY>
					<TARGET>hdc</TARGET>
				</CONTEXT>
				</COMPUTE>"
			rep = Vm_Manager.send(ONE_server+"compute", "post", xml)
			xml = Nokogiri::XML(rep)
			raise VmError, "VmError: the above xml have no tag COMPUTE \n["+rep+"]" if xml.xpath('//COMPUTE') == nil || xml.xpath('//COMPUTE').last == nil
			url = xml.xpath('//COMPUTE').last["href"]
			while !Vm_Manager.isState?(url,"ACTIVE") do
				sleep Refresh
			end
			return url
		rescue Curl::Err::CurlError => e
			raise VmError, "VmError: "+e.message
		end
	end

	# delete
	# Delete an instance of vm.
	# url: _String_ The url of the vm.
	# throws: VmError : throw if there is a connection error or if opennebula throw an Exception.
	def delete(url)
		begin
			Vm_Manager.send(url, "delete","")
		rescue Curl::Err::CurlError => e
			raise VmError, "VmError: "+e.message
		end
	end

	# Actions
	# ========

	# start
	# Start a vm.
	# url: _String_ The url of the vm.
	# throws: VmError : throw if there is a connection error or if opennebula throw an Exception.
	def start(url)
		begin
			Vm_Manager.send(url, "put", "<COMPUTE href='"+url+"'><STATE>RESUME</STATE></COMPUTE>")
			while !Vm_Manager.isState?(url,"ACTIVE") do
				sleep Refresh
			end
		rescue Curl::Err::CurlError => e
			raise VmError, "VmError: "+e
		end
	end

	# stop
	# Stop a vm.
	# url: _String_ The url of the vm.
	# throws: VmError : throw if there is a connection error or if opennebula throw an Exception.
	def stop(url)
		begin
			Vm_Manager.send(url, "put", "<COMPUTE href='"+url+"'><STATE>STOPPED</STATE></COMPUTE>")
		rescue Curl::Err::CurlError => e
			raise VmError, "VmError: "+e.message
		end
	end

	# execute
	# Execute a script on a vm.
	# url: _String_ The url of the vm.
	# script: _String_ The script to execute.
	# throws: VmError : throw if there is a connection error or if opennebula throw an Exception.
	def execute(url, script)
		begin
			rep = Vm_Manager.send(url, "get", "")
			xml = Nokogiri::XML(rep)
			raise VmError, "VmError: the above xml have no tag STATE \n["+rep+"]" if xml.xpath('//STATE') == nil
			state =  xml.xpath('//STATE')[0].content
			self.start(url) if state == "STOPPED"

			ip =  xml.xpath('//IP')[0].content
			i = 0
			while ! Ping.pingecho ip, Refresh do
				raise VmError, "VmError: "+url+" Unreachable" if i > 5
				i+=1
			end			
			ClientTCP.execute(ip, script)
		rescue Curl::Err::CurlError => e
			raise VmError, "VmError: "+e.message
		end
	end

	# getValue
	# Retreive the value of a vm attribute.
	# url: _String_ The url of the vm.
	# attribute: _String_ The vm attribute to retreive.
	# return: the value of the attribute
	# throws: VmError : throw if there is a connection error or if opennebula throw an Exception.
	def getValue(url, attribute)
		begin
			xml = Nokogiri::XML(Vm_Manager.send(url, "get", ""))

			case attribute
				when "IP", "MAC", "ID", "GROUP", "CPU", "MEMORY", "NAME", "INSTANCE_TYPE", "STATE", "NAME", "NAME"
					# COMPUTE ATTRIBUTES
					return xml.xpath('//'+attribute)[0].content

				when "STORAGE_TARGET"
					# DISK TARGET
					return xml.xpath('//'+attribute.gsub(/STORAGE_/, ''))[0].content

				when "STORAGE_NAME", "STORAGE_ID", "STORAGE_GROUP", "STORAGE_STATE", "STORAGE_TYPE", "STORAGE_SIZE", "STORAGE_PUBLIC", "STORAGE_PERSISTENT"
					# STORAGE ATTRIBUT
					storage = xml.xpath('//STORAGE').last["href"]
					storage = Nokogiri::XML(Vm_Manager.send(storage, "get", ""))
			
					return storage.xpath('//'+attribute.gsub(/STORAGE_/, ''))[0].content

				when "NETWORK_NAME", "NETWORK_ID", "NETWORK_GROUP", "NETWORK_ADDRESS", "NETWORK_SIZE", "NETWORK_USED_LEASES", "NETWORK_PUBLIC"
					# NETWORK ATTRIBUT
					network = xml.xpath('//NETWORK').last["href"]
					network = Nokogiri::XML(Vm_Manager.send(network, "get", ""))

					return network.xpath('//'+attribute.gsub(/NETWORK_/, ''))[0].content

				else
					raise VmError, "VmError: the attribute \""+attribute+"\" cannot be found"
			end
		rescue Curl::Err::CurlError => e
			raise VmError, "VmError: "+e.message
		end
		
	end


	# getNetwork
	# Retreive the network instance.
	# return: the network instance url.
	# throws: Curl::Err::CurlError : throw if there is a connection error.
	# throws: VmError : throw if opennebula throw an Exception.
	def Vm_Manager.getNetwork
		if @@network == nil
			xml = Nokogiri::XML(Vm_Manager.send(ONE_server+"network", "get",""))
			xml.xpath('//NETWORK').each do |network|
				@@network = network["href"] if network["name"] == "Service_Manager_Network"
			end
			# if the network resource does't exist
			# (when it's the first time we launch the service manager)
			if @@network == nil
				rep = Vm_Manager.send(ONE_server+"network", "post","<NETWORK>
							<NAME>Service_Manager_Network</NAME>
							<ADDRESS>"+NetworkAdress+"</ADDRESS>
							<SIZE>"+NetworkSize.to_s+"</SIZE>
						</NETWORK>")
				xml = Nokogiri::XML(rep)
				raise VmError, "VmError: the above xml have no tag NETWORK \n["+rep+"]" if xml.xpath('//NETWORK') == nil || xml.xpath('//NETWORK').last == nil
				@@network = xml.xpath('//NETWORK').last["href"]
			end
			
		end
		return @@network
	end

	# getStorage
	# Retreive the storage instance url.
	# name: _String_ The name of the storage instance.
	# return: the storage instance url.
	# throws: Curl::Err::CurlError : throw if there is a connection error.
	# throws: VmError : throw if opennebula throw an Exception.
	def Vm_Manager.getStorage(name)
		if @@storage == nil

			xml = Nokogiri::XML(Vm_Manager.send(ONE_server+"storage", "get",""))
			xml.xpath('//STORAGE').each do |storage|
				@@storage = storage["href"] if storage["name"] == "Service_Manager_storage_"+name
			end
			# if the storage resource does't exist
			# (when it's the first time we launch the service manager)
			if @@storage == nil
				occixml = "<STORAGE>
						<NAME>Service_Manager_storage_"+name+"</NAME>
						<TYPE>OS</TYPE>
						<URL>file://images/"+name+"/"+name+".img</URL>
						</STORAGE>"
				puts occixml
				occixml = Curl::PostField.content("occixml", occixml)
				file = Curl::PostField.file("file","images/"+name+"/"+name+".img")
				c = Curl::Easy.new(ONE_server+"storage")
				c.http_auth_types = :basic
				c.username = ONE_login
				c.password = Digest::SHA1.hexdigest ONE_password
				c.multipart_form_post =true

				c.http_post(occixml, file)
				
				rep = c.body_str
				xml = Nokogiri::XML(rep)
				raise VmError, "VmError: the above xml have no tag STORAGE \n["+rep+"]" if xml.xpath('//STORAGE') == nil || xml.xpath('//STORAGE').last == nil
				@@storage = xml.xpath('//STORAGE').last["href"]

				while !Vm_Manager.isState?(@@storage,"READY") do
					sleep Refresh
				end
			end
		end
		return @@storage
	end

	private

	# send
	# Send an http request to the OCCI API of Opennebula.
	# url: _String_ The url to send the request.
	# verb: _String_ The http verb of the request.
	# data: _String_ The body of the request.
	# return: the response body.
	# throws: Curl::Err::CurlError : throw if there is a connection error.
	def Vm_Manager.send(url, verb, data)
		c = Curl::Easy.new(url)
		c.http_auth_types = :basic
		c.username = ONE_login
		c.password = Digest::SHA1.hexdigest ONE_password
		case verb
			when "get"
				c.http_get
			when "put"
				c.http_put(data)
			when "delete"
				c.http_delete
			else
				c.http_post(data)
				
		end
		return c.body_str
	end

	# isState?
	# Verify the state of an Opennebula resource.
	# url: _String_ The url of the resource.
	# state: _String_ The state.
	# return: true if the state correspond to the state attribute, false otherwise
	# throws: Curl::Err::CurlError : throw if there is a connection error.
	def Vm_Manager.isState?(url, state)
		rep = Vm_Manager.send(url, "get", "")
		xml = Nokogiri::XML(rep)
		raise VmError, "VmError: the above xml have no tag STATE \n["+rep+"]" if xml.xpath('//STATE') == nil
		cstate =  xml.xpath('//STATE')[0].content
		return cstate == state
	end

end
