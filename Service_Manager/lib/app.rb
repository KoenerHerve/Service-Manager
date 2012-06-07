require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'
require 'lib/autoload'
require 'lib/daoFactory'
require 'logger'



class App < Sinatra::Base
	
	# Request Interface
	# -----------------


	get '/-/' do
		# Show capabilities
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = RequestInterface_Controler.new
			view.show(contentType)
			
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	post '/-/' do
		# Add a user mixin
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = RequestInterface_Controler.new
			view.addMixin(request.env["rack.input"].read)
		rescue KindNotFoundError => e
			Log.error e.message
			status = 404
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	delete '/-/' do
		# Remove a user mixin
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = RequestInterface_Controler.new
			view.removeMixin(request.env["rack.input"].read)
		rescue KindNotFoundError => e
			Log.error e.message
			status = 404
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	
	# Kind
	# ----


	get '/:kind/' do
		# retrieve all
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Kind_Controler.new
			view.show("#{params[:kind]}", contentType)
		rescue KindNotFoundError => e
			Log.error e.message
			status = 404
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	post '/:kind/' do
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		if request["action"] == nil
			# create/full update
			begin
				view = Entity_Controler.new
				view.create("#{params[:kind]}", request.env["rack.input"].read, contentType)
			rescue MissingParameterError => e
				status = 400
				Log.error e.message
			rescue MixinError, ActionError  => e
				#if the resource cannot be associate with the mixin.
				status = 403
				Log.error e.message
			rescue ResourceNotFoundError, CategoryError, KindNotFoundError  => e
				# if the kind does not exist
				status = 404
				Log.error e.message
			rescue VmError, DatabaseError => e
				Log.error e.message
				Log.error e.backtrace.join("\n")
				status = 500
			end
		else
			# execute action on all resources
			begin
				view = Kind_Controler.new
				view.action("#{params[:kind]}", request["action"], request.env["rack.input"].read)
			rescue KindNotFoundError  => e
				# if the kind does not exist
				status = 404
				Log.error e.message
			rescue ActionError  => e
				#if the resource cannot be associate with the mixin.
				status = 403
				Log.error e.message
			rescue VmError, DatabaseError => e
				Log.error e.message
				Log.error e.backtrace.join("\n")
				status = 500
			end
		end
	end

	put '/:kind/' do
		# create/full update
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Entity_Controler.new
			view.create("#{params[:kind]}", request.env["rack.input"].read, contentType)
		rescue MissingParameterError => e
			status = 400
			Log.error e.message
		rescue MixinError, ActionError  => e
			#if the resource cannot be associate with the mixin.
			status = 403
			Log.error e.message
		rescue ResourceNotFoundError, CategoryError, KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue VmError, DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
		
	end

	delete '/:kind/' do
		# delete all/some
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Kind_Controler.new
			view.delete("#{params[:kind]}",request.env["rack.input"].read)
		rescue KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	
	# Resource and Link
	# ------------------


	get %r{/([\w]+)/([\d]+)} do |kind, id|
		# retrieve
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Entity_Controler.new
			view.show("#{kind}", "#{id}", contentType)
		rescue ResourceNotFoundError, KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue  DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	post %r{/([\w]+)/([\d]+)} do |kind, id|
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		view = Entity_Controler.new
		if request["action"] == nil
			begin
				# update
				view.update("#{kind}", "#{id}", request.env["rack.input"].read, false)
			rescue  ActionError, MixinError  => e
				#if the resource cannot be associate with the mixin.
				status = 403
				Log.error e.message
			rescue KindNotFoundError, CategoryError  => e
				# if the kind does not exist
				status = 404
				Log.error e.message
			rescue VmError, DatabaseError => e
				Log.error e.message
				Log.error e.backtrace.join("\n")
				status = 500
			end
		else
			begin
				# execute action
				view.action("#{kind}", "#{id}", request["action"], request.env["rack.input"].read)
			rescue  ActionError  => e
				#if the resource cannot be associate with the mixin.
				status = 403
				Log.error e.message
			rescue KindNotFoundError  => e
				# if the kind does not exist
				status = 404
				Log.error e.message
			rescue VmError, DatabaseError => e
				Log.error e.message
				Log.error e.backtrace.join("\n")
				status = 500
			end
		end
	end

	put %r{/([\w]+)/([\d]+)} do |kind, id|
		# full update
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Entity_Controler.new
			view.update("#{kind}", "#{id}", request.env["rack.input"].read, true)
		rescue MissingParameterError => e
			status = 400
			Log.error e.message
		rescue  ActionError, MixinError  => e
			#if the resource cannot be associate with the mixin.
			status = 403
			Log.error e.message
		rescue KindNotFoundError, CategoryError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue VmError, DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end
	
	delete %r{/([\w]+)/([\d]+)} do |kind, id|
		# delete
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Entity_Controler.new
			view.delete("#{kind}", "#{id}")
		rescue  ActionError  => e
			#if the resource does not exist.
			status = 403
			Log.error e.message
		rescue KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	
	# Mixin
	# -----


	get %r{/(service|autoscalinggroup)/([\w]+)/} do |kind, mixin|
		# retrieve all
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Mixin_Controler.new
			view.show("#{kind}/#{mixin}", contentType)
		rescue KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end

	post %r{/(service|autoscalinggroup)/([\w]+)/} do |kind, mixin|
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		view = Mixin_Controler.new
		if request["action"] == nil
			# Associate
			begin
				view.add("#{kind}/#{mixin}",request.env["rack.input"].read)
			rescue ActionError, MixinError  => e
				#if the resource cannot be associate with the mixin.
				status = 403
				Log.error e.message
			rescue KindNotFoundError  => e
				# if the kind does not exist
				status = 404
				Log.error e.message
			rescue VmError, DatabaseError => e
				Log.error e.message
				Log.error e.backtrace.join("\n")
				status = 500
			end
		else
			# execute action
			begin
				view.action("#{kind}/#{mixin}", request["action"], request.env["rack.input"].read)
			rescue ActionError  => e
				#if the resource cannot be associate with the mixin.
				status = 403
				Log.error e.message
			rescue KindNotFoundError  => e
				# if the kind does not exist
				status = 404
				Log.error e.message
			rescue VmError, DatabaseError => e
				Log.error e.message
				Log.error e.backtrace.join("\n")
				status = 500
			end
		end
	end

	put %r{/(service|autoscalinggroup)/([\w]+)/} do |kind, mixin|
		# Full Update of the Mixin
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Mixin_Controler.new
			view.remove("#{kind}/#{mixin}","")
			view.add("#{kind}/#{mixin}",request.env["rack.input"].read)
		rescue ActionError, MixinError  => e
			#if the resource cannot be associate with the mixin.
			status = 403
			Log.error e.message
		rescue KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue VmError, DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end


	delete %r{/(service|autoscalinggroup)/([\w]+)/} do |kind, mixin|
		# Dissociate
		contentType = (request.content_type == "text/occi")? "text/occi":"text/plain"
	 	# content type of the response
		content_type contentType

		begin
			view = Mixin_Controler.new
			view.remove("#{kind}/#{mixin}",request.env["rack.input"].read)
		rescue ActionError, MixinError  => e
			#if the resource cannot be associate with the mixin.
			status = 403
			Log.error e.message
		rescue KindNotFoundError  => e
			# if the kind does not exist
			status = 404
			Log.error e.message
		rescue VmError, DatabaseError => e
			Log.error e.message
			Log.error e.backtrace.join("\n")
			status = 500
		end
	end


	# Sandbox
	# -------


	get "/sandbox" do
		# Testing		
		view = Sandbox_Controler.new
		view.show()
	end

end
