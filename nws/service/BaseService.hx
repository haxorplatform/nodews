package nws.service;
import haxe.rtti.Meta;
import haxe.rtti.Rtti;
import js.node.http.Method;
import nws.net.HttpServiceManager;

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
	public var manager : HttpServiceManager;
	
	/**
	 * Contains information from the service in execution.
	 */
	public var session : ServiceSession;
	
	/**
	 * Content Type
	 */
	public var content : String;
	
	/**
	 * Response Code
	 */
	public var code : Int;
	
	/**
	 * Flag that indicates if the service will run.
	 */
	public var enabled : Bool;
	
	/**
	 * Flag that indicates this instance will be stored after creation.
	 */
	public var persistent : Bool;

	/**
	 * Creates a new web service.
	 * @param	p_server
	 */
	public function new()
	{		
		session  = new ServiceSession();
		content  = "text/plain";
		code     = 200;		
		enabled  = true;
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
	 * Method called after all data os processed on server
	 */
	public function OnExecute():Void { }
	
	/**
	 * Method called when this instance will be destroyed before a new one is created.
	 */
	public function OnDestroy():Void {}
	
	/**
	 * Executes all methods related to the desired route and http-method.
	 */
	public function Execute():Void 
	{
		//fetches the RTTI and execute the functions
		var c : Class<BaseService> = Type.getClass(this);
		var d : Array<Dynamic> = cast Meta.getFields(c);
		if (d != null)
		{
			var ref : Dynamic = this;
			var ms  : String = cast session.method;
			ms = ms.toLowerCase();
			var meta_field : String = "";
			untyped __js__('for (var s in d) { meta_field = s;');
			
			var fn    : Dynamic = untyped ref[meta_field];
			var route : Dynamic = untyped d[meta_field].route;
			//if has route metadata				
			if (route != null)
			{
				//has sufficient args
				if (route.length > 1)
				{
					var ml : String = route[0];
					ml = ml.toLowerCase();
					
					//http-method is supported by route				
					if (ml.indexOf(ms) >= 0)
					{
						var opt  : String = route.length >= 3 ? route[2] : "";
						var rule : String = route[1];
						var er : EReg = new EReg(rule, opt);	
						trace(er);
						if (session.url != null)
						{
							if (er.match(session.url.pathname))
							{
								fn();
							}
						}
					}					
				}
			}				
			untyped __js__('}');
			
		}
		
		//Call execution callback.
		OnExecute();
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
	public function Log(p_msg:Dynamic, p_level:Int = 0):Void { manager.Log(p_msg, p_level); }
	
	
	/**
	 * Called when the server detects an error.
	 * @param	p_error
	 */
	public function OnError(p_error : Dynamic):Void	{	}
}