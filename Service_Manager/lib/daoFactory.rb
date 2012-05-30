require "mysql"

class Dao 
	@@connect = nil
	
	# getDao
	# Retreive the Database Object.
	# return: the Database Object.
	# throws: DatabaseError : throw if there is a Mysql Error.
	def Dao.getDao
		if(@@connect.nil?)
			@@connect = Mysql.new(DB_hostname , DB_user, DB_password, DB_name)	
		end
		return @@connect
	end
end


