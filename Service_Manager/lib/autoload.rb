require 'logger'
Log = Logger.new('service_manager.log', LogRotation)

autoload :Controler, 'lib/controler'
autoload :Dao, 'lib/daoFactory'
autoload :Request, 'lib/request'
autoload :ClientTCP, 'lib/clientTCP'

# Exceptions
# ----------
autoload :ForbiddenError, 'lib/exceptions/forbiddenError'
autoload :ActionError, 'lib/exceptions/actionError'
autoload :MixinError, 'lib/exceptions/mixinError'
autoload :NotFoundError, 'lib/exceptions/notFoundError'
autoload :CategoryError, 'lib/exceptions/categoryError'
autoload :KindNotFoundError, 'lib/exceptions/kindNotFoundError'
autoload :ResourceNotFoundError, 'lib/exceptions/resourceNotFoundError'
autoload :InternalServerError, 'lib/exceptions/internalServerError'
autoload :VmError, 'lib/exceptions/vmError'
autoload :DatabaseError, 'lib/exceptions/databaseError'
autoload :MissingParameterError, 'lib/exceptions/missingParameterError'


# Controlers
# ----------

autoload :Sandbox_Controler,'controlers/sandbox/sandbox_Controler'
autoload :RequestInterface_Controler,'controlers/requestInterface/requestInterface_Controler'
autoload :Kind_Controler,'controlers/kind/kind_Controler'
autoload :Mixin_Controler,'controlers/mixin/mixin_Controler'
autoload :Entity_Controler,'controlers/entity/entity_Controler'
autoload :Autoscalinggroup_Controler,'controlers/autoscalinggroup/autoscalinggroup_Controler'
autoload :Service_Controler,'controlers/service/service_Controler'
autoload :Group_Controler,'controlers/group/group_Controler'
autoload :Dependence_Controler,'controlers/dependence/dependence_Controler'

# Managers
# --------

autoload :Manager, 'lib/manager'
autoload :Category_Manager, 'lib/models/'+SGBD+'/category_Manager'
autoload :Kind_Manager, 'lib/models/'+SGBD+'/kind_Manager'
autoload :Mixin_Manager, 'lib/models/'+SGBD+'/mixin_Manager'
autoload :Action_Manager, 'lib/models/'+SGBD+'/action_Manager'
autoload :Autoscalinggroup_Manager, 'lib/models/'+SGBD+'/autoScalingGroup_Manager'
autoload :Service_Manager, 'lib/models/'+SGBD+'/service_Manager'
autoload :Group_Manager, 'lib/models/'+SGBD+'/group_Manager'
autoload :Dependence_Manager, 'lib/models/'+SGBD+'/dependence_Manager'
autoload :Vm_Manager, 'lib/models/'+Infrastructure_Manager+'/vm_Manager'

# Records
# -------

autoload :Record, 'lib/record'
autoload :Category, 'lib/models/category'
autoload :Kind, 'lib/models/kind'
autoload :Mixin, 'lib/models/mixin'
autoload :Action, 'lib/models/action'
autoload :Entity, 'lib/models/entity'
autoload :Resource, 'lib/models/resource'
autoload :Service, 'lib/models/service'
autoload :Autoscalinggroup, 'lib/models/autoScalingGroup'
autoload :Link, 'lib/models/link'
autoload :Group, 'lib/models/group'
autoload :Dependence, 'lib/models/dependence'

