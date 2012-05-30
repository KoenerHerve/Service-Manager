# Service Manager
# ================
Hostname = "http://localhost:9292/"

# Log rotation ["monthly", "weekly", "daily"]
LogRotation = "weekly"

# type of the SQGB [mysql]
SGBD = "mysql"

# name of the infrastructure manager [opennebula]
Infrastructure_Manager = "opennebula"
# number of second between two request when checking if a vm is started
Refresh = 10

# Max size of the AutoScaling Group dependence chain
MaxRecursive = 5

# Service network configuration
NetworkSize = "C"
NetworkAdress = "192.168.8.0"

# Service storage configuration
Default_instanceType = "small"
Default_imageName = "ttylinux"

# Database
# ==========
DB_hostname = "localhost"
DB_user = "root"
DB_password = "servicemanager"
DB_name = "service_manager"

# Opennebula
# ===========
ONE_login = "oneadmin"
ONE_password = "oneadmin"
ONE_server = "http://localhost:4567/"
#ONE_hostName = "127.0.0.1"

require "lib/app"

run App.new
