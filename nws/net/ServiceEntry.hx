package nws.net;
import nws.service.BaseService;

/**
 * Class that represents a service entry in the manager service's pool.
 * It contains the rule that is macthed against the URL and manages the instance reference and life-time.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class ServiceEntry
{
	/**
	 * Rule that matches the service's route.
	 */
	public var rule : EReg;

	/**
	 * Service associated to the route's rule.
	 */
	public var service : Class<BaseService>;
	
	/**
	 * Currently active instance.
	 */
	public var instance : BaseService;	
	
	/**
	 * Creates a new service's root route.
	 * @param	p_rule
	 * @param	p_service_type
	 */
	public function new(p_rule : EReg,p_service_type : Class<BaseService>) 
	{
		rule	 = p_rule;
		service	 = p_service_type;
		instance = null;
	}
	
	/**
	 * Creates a service instance or returns the currently active one if it is persistent.
	 * @return
	 */
	public function GetInstance():BaseService
	{
		if (instance != null)
		{
			if (instance.persistent)
			{				
				return instance;
			}
			instance.OnDestroy();
		}
		instance = Type.createInstance(service, []);
		instance.route = rule;
		instance.OnCreate();
		return instance;
	}
	
}