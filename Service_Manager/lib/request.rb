class Request
	Reg_url = '(?:(?:(?:https?://)?(?:(?:(?:(?:2(?:5[0-5]|[0-4][0-9])|1?[0-9]{2}|[0-9])\.){4})|(?:(?:(?:w{3}|[\w_!~\*\'\(\)\-]*)\.)?(?:\w[\w\-]{0,61})?\w\.[a-zA-Z]{2,6})|localhost)(?::[0-9]{1,4})?)|(?:/?\w+))(?:[#/\?][/\w_!~\*\'\(\)\.;\?:@&=\+\$,%#\-]*)?'
	Reg_var = '[\.\-\w]+'
	Reg_val = '(?::|\s|(?:'+Reg_url+')|(?:'+Reg_var+'))+'
	# Category 
	Reg_cat = '\s*([\w\-_]+)\s*;\s*scheme\s*=\s*"('+Reg_url+')"\s*;\s*class\s*=\s*"(kind|mixin)"\s*;(?:\s*title\s*=\s*"('+Reg_val+')"\s*;)?(?:\s*attributes\s*=\s*"((?:'+Reg_var+'|'+Reg_var+'\s*=\s*(?:\\"'+Reg_val+'\\"|\d))(?:\s*,\s*(?:'+Reg_var+'|'+Reg_var+'\s*=\s*(?:\\"'+Reg_val+'\\"|\d)))*)?"\s*;)?(?:\s*actions\s*=\s*"('+Reg_url+'(?:\s*,\s*'+Reg_url+')*)"\s*;)?(?:\s*rel\s*=\s*"('+Reg_url+'(?:\s*,\s*'+Reg_url+')*)"\s*;)?(?:\s*location\s*=\s*"('+Reg_url+')?"\s*;)?'


	Reg_category = '\s*Category\s*:('+Reg_cat+'(?:\s*,'+Reg_cat+')*)'
	# Attribute 
	Reg_att = '\s*('+Reg_var+')\s*=\s*("'+Reg_val+'"|\d)'
	Reg_attribute = '\s*X-OCCI-Attribute\s*:('+Reg_att+'(?:\s*,'+Reg_att+')*)'
	# Link	
	Reg_lk = '\s*<('+Reg_url+')>\s*;\s*rel\s*=\s*"('+Reg_url+')"\s*;(?:\s*self\s*=\s*"('+Reg_url+')"\s*;)?\s*category\s*=\s*"('+Reg_url+')"\s*;((?:\s*(?:'+Reg_var+')\s*=\s*(?:"'+Reg_val+'"|\d)\s*;)+)?'
	Reg_link = '\s*Link\s*:('+Reg_lk+'(?:\s*,'+Reg_lk+')*)'
	# Location 
	Reg_location = '\s*X-OCCI-Location\s*:\s*('+Reg_url+')'+'(?:\s*,\s*('+Reg_url+'))*'

	attr_reader :category, :location, :attribute, :link
    	attr_writer :category, :location, :attribute, :link

	def initialize(row)
		@category, @location, @attribute, @link = row
	end

	# getAttribute
	# Retreive the value of an attribute.
	# name: _String_ the name of the atribute.
	# return: the value of the attribute.
	def getAttribute(name)
		@attribute.each do |att|
			if att[0] == name
				return att[1].gsub(/"/,"")
			end
		end
		return nil
	end

	# getLinkAttribute
	# Retreive the value of an attribute of a link.
	# name: _String_ the name of the atribute.
	# link: _String_ the name of the link.
	# return: the value of the attribute.
	def getLinkAttribute(link, name)
		lk = @link[link]
		if lk[4] != nil
			lk[4].each do |att|
				puts att.inspect
				if att[0] == name
					return att[1].gsub(/"/,"")
				end
			end
		end
		return nil
	end

	#Static

	# process
	# Process a request.
	# request: _String_ the request to process.
	# return: an array containing the processed request.
	def Request.process(request)
		val = []
		# get category datas
		val << getOCCIValues(request,Reg_category,Reg_cat)
		# get location datas
		val << getOCCIValues(request,Reg_location,'('+Reg_url+')')
		# get attribute datas
		val << getOCCIValues(request,Reg_attribute,Reg_att)
		# get link datas
		link =  getOCCIValues(request,Reg_link,Reg_lk)

		link.each_index do |i|
			# get the links attributes
			size = link[i].length-1
			if link[i][size] != nil
				link[i][size] = link[i][size].scan(Regexp.new(Reg_att))
			end
		end
		val << link
		
		return Request.new(val)
	end

	# getOCCIValues
	# Process a string to retreive the OCCI Values.
	# str: _String_ the string to process.
	# regLine: _String_ the regex of the content.
	# regValue: _String_ the regex of the value.
	# return: an array containing the processed string.
	def Request.getOCCIValues(str, regLine, regValue)
		regex = Regexp.new(regLine)
		lines = str.scan(Regexp.new('('+removeCaptureGroup(regLine)+')'))

		matches = []
		# if there are split on different lines. e.g:
		# X-OCCI-Location: http://a.com,http://b.com
		# X-OCCI-Location: http://c.com
		lines.each do |line|
			tmp = ','+regex.match(line[0])[1]
			# get all the OCCI Values separated by a comma
			# e.g: X-OCCI-Location: http://a.com,http://b.com
			matches+= tmp.scan(Regexp.new(','+regValue))
		end
		return matches
	end

	# removeCaptureGroup
	# Remove the Capture Group of a request.
	# regex: _String_ the regex to process.
	# return: the processed regex.
	def Request.removeCaptureGroup(regex)
		# Remove capture group from the regex
		cat = regex.gsub(Regexp.new('\('),'(?:')
		cat = cat.gsub(Regexp.new('\?:\?:'),'?:')
		return cat.gsub(Regexp.new('\\\\\(\?:'),'\(')
	end

	
end
