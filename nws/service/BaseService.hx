package nws.service;
import haxe.rtti.Meta;
import haxe.rtti.Rtti;
import js.Error;
import js.node.http.Method;
import nws.net.HttpApplication;

/**
 * Base class for implementing a web service. The user only needs to process the data and write the response for the server.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:rtti
class BaseService
{
	/**
	 * Server running this service.
	 */
	public var application : HttpApplication;
	
	/**
	 * Contains information from the service in execution.
	 */
	public var session : ServiceSession;
		
	/**
	 * Flag that indicates if the service will run.
	 */
	public var enabled : Bool;
	
	/**
	 * Flag that indicates this instance will be stored after creation.
	 */
	public var persistent : Bool;
	
	/**
	 * RegExp that route requests to this service.
	 */
	public var route : EReg;
	
	/**
	 * Origins allowed for this service.
	 */
	public var allowOrigin : String;
	
	/**
	 * Creates a new web service.
	 * @param	p_server
	 */
	public function new()
	{		
		session  = new ServiceSession();			
		enabled  = true;
		route    = new EReg("(.*?)", "");
		allowOrigin	 = "*";
	}
	
	/**
	 * Method called when this service is created for the first time.
	 */
	public function OnCreate():Void { }
	
	/**
	 * Method called when a Request arrives on the server and after the Service is instantiated.
	 * Describe the content type and response code that will be used.
	 */
	public function OnInitialize():Void	{}
	
	/**
	 * Method called after all data and routes was processed.
	 */
	public function OnExecute():Void { }
	
	/**
	 * Method called when this instance will be destroyed before a new one is created.
	 */
	public function OnDestroy():Void { }
	
	/**
	 * Callback called after the response sent all data after .end()
	 */
	public function OnFinish():Void { }
	
	
	/**
	 * Executes all methods related to the desired route and http-method.
	 */
	public function Execute():Void 
	{
		//Sets Allow-Origin headers for this service.
		if (session.response != null)
		{
			if (allowOrigin == "")
			{				
				session.response.removeHeader("Access-Control-Allow-Origin");
			}
			else
			{
				session.response.setHeader("Access-Control-Allow-Origin", allowOrigin);
			}
		}
		
		//fetches the RTTI and execute the functions		
		var c : Class<BaseService> = Type.getClass(this);		
		var has_found : Bool = false; 		
		var cl : Array<Class<BaseService>> = [];
		while (c != null) { cl.push(c); c = cast Type.getSuperClass(c); }
		cl.pop(); 	  //Removes BaseService because it has no routes
		cl.reverse(); //Make it start in base classes and go up.
		for (it in cl)
		{
			var execute_found : Bool = ExecuteRoutes(it);
			has_found = execute_found || has_found;
			//trace("Trying ["+Type.getClassName(it)+"]["+execute_found+"]");
		}
		
		if (!has_found) 
		{
			Log(Type.getClassName(Type.getClass(this)) + "> Route not found.", 1);
			var err : Error = new Error("Route ["+session.url.pathname+"] Not Found.");
			err.name = "route_not_found";
			OnError(err);			
		}
		
		//Call execution callback.
		OnExecute();
	}
	
	/**
	 * Search and execute routes in a given type.
	 * @param	p_type
	 * @return
	 */
	public function ExecuteRoutes(p_type : Class <BaseService>):Bool
	{
		var c : Class<BaseService> = p_type;
		var d : Array<Dynamic> = cast Meta.getFields(c);		
		var has_found : Bool = false;
		//trace(">> execute");
		if (d != null)
		{		
			//trace(">> metas");
			var ref : Dynamic = this;			
			var ms  : String = cast session.method;
			ms = ms.toLowerCase();
			var meta_field : String = "";
			untyped __js__('for (var s in d) { meta_field = s;');
			
			
			var route : Dynamic = untyped d[meta_field].route;
			//if has route metadata				
			if (route != null)
			{
				//trace(">> route");
				//has sufficient args
				if (route.length > 1)
				{
					var ml : String = route[0];
					ml = ml.toLowerCase();
					
					//trace(">> method["+ms+"]["+ml+"]");
					//http-method is supported by route
					if (ml.indexOf(ms) >= 0)
					{
						var opt  : String = route.length >= 3 ? route[2] : "";
						var rule : String = route[1];
						var er : EReg = new EReg(rule, opt);
						//trace(">> url["+(session.url!=null)+"]");
						if (session.url != null)
						{
							//trace(er);
							//trace(session.url.pathname);
							if (er.match(session.url.pathname))
							{
								has_found = true;
								if (OnMeta(untyped d[meta_field], function() { untyped ref[meta_field](); } ))
								{
									untyped ref[meta_field]();
								}
							}
						}
					}					
				}
			}				
			untyped __js__('}');			
		}
		return has_found;
	}
	
	/**
	 * Finishes the service and close the response.
	 */
	public function Close():Void
	{		
		session.response.end();
	}
	
	/**
	 * Logs a message.
	 * @param	p_msg
	 * @param	p_level
	 */
	public function Log(p_msg:Dynamic, p_level:Int = 0):Void { application.Log(p_msg, p_level); }
	
	
	/**
	 * Called when the server detects an error.
	 * @param	p_error
	 */
	public function OnError(p_error : Error):Void	{	}
	
	/**
	 * Callback called when a metadata is processed.
	 * Users can intercept the call of the route's method and do some steps before it.
	 * Execution can be resumed calling the 'onready' callback.
	 * @param	p_meta
	 * @param	p_on_ready
	 * @return
	 */
	public function OnMeta(p_meta:Dynamic, p_onready : Void->Void) : Bool { return true; }
}