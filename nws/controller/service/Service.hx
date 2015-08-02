package nws.controller.service;
import nws.controller.Controller;
import nws.Resource;
import js.Error;
import nws.component.Component;
import nws.component.net.HttpComponent;
import nws.component.net.HttpSession;
import nws.component.net.IHttpHandler;
import nws.Entity;
import nws.Resource.MetaData;

/**
 * Base class for web services that executes routed methods using the metadata "route(methods,regexp)"
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Service extends Controller implements IHttpHandler
{
	/**
	 * Flag that indicates this service will not be reset when a new request arrives.
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
	 * Reference to the currently active HttpComponent.
	 */
	public var http(get, never):HttpComponent;
	private function get_http():HttpComponent { return m_http; }
	private var m_http:HttpComponent;
	
	/**
	 * Reference to the session which spawned this service.
	 */
	public var session(get, never):HttpSession;
	private function get_session():HttpSession { return m_session; }
	private var m_session:HttpSession;
	
	/**
	 * Flag that indicates if this Service is valid for execution.
	 */
	public var valid(get, never):Bool;
	private function get_valid():Bool { return (http != null) && (!session.finished); }
	
	/**
	 * Flag that indicates this service executed 1 or more routes.
	 */
	public var found(get, never):Bool;
	private function get_found():Bool { return m_found; }
	private var m_found : Bool;
	
	
	/**
	 * Internal CTOR.
	 */
	override private function new():Void
	{
		super();		
		allowOrigin = "*";		
		persistent  = false;
		m_found		= false;
	}
	
	/**
	 * Creation callback.
	 */
	override public function OnCreate():Void 
	{
		//Log("Create!", 4);
	}
	
	/**
	 * Callback called on a request arrives on a HttpComponent in this component's hierarchy.
	 * @param	p_target
	 */
	public function OnRequest(p_target:HttpComponent):Void 
	{
		if (!enabled) return;
		if (route == null) return;
		m_http    = p_target;		
		m_session = m_http.session;
		if (!route.match(m_http.path))
		{			
			return;
		}		
		if (!valid) return;
		
		//Log("OnRequest ["+(untyped route.r)+"]",5);
		
		var md : Array<MetaData> = cast metadata;
		var has_found : Bool  = false;
		var ref : Dynamic = this;
		for (it in md)
		{
			var route_data:Array<Dynamic> = it.data.route;			
			if (route_data == null) continue;			
			if (route_data.length <= 1) continue;
			if (!valid) continue;
			var route_methods : String = route_data[0];
			var method 		  : String = (cast http.request.method).toLowerCase();			
			if (route_methods.indexOf(method) < 0) continue;
			var route_rule	  : EReg = new EReg(route_data[1],route_data.length<=2 ? "" : route_data[2]);
			if (route_rule.match(http.url.pathname))
			{
				has_found = true;
				var validated : Bool = 
				OnValidateMetadata(it, function()
				{ 
					if(!session.finished) OnBeforeAction(route_data[1]);
					if(!session.finished) untyped ref[it.field](); 				
					if(!session.finished) OnAfterAction(route_data[1]);
				});
				
				if (validated)
				{
					if(!session.finished) OnBeforeAction(route_data[1]);
					if(!session.finished) untyped ref[it.field](); 				
					if(!session.finished) OnAfterAction(route_data[1]);							
				}
			}			
		}	
		
		m_found = has_found;
		
		if (!has_found)
		{
			OnRouteFail();		
		}
		else
		{
			if (!session.response.headersSent)
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
		}
		
		http.found = http.found || has_found;
	}
	
	/**
	 * Callback called on a request is finished on a HttpComponent in this component hierarchy.
	 * @param	p_target
	 */
	public function OnFinish(p_target:HttpComponent):Void 
	{	
		//If not persistent, kill this instance and add another of same type in the controller.		
		if(found)
		if (!persistent)
		{
			var e : Entity = entity;
			Destroy();
			e.AddComponent(cast GetType());
		}
	}
	
	/**
	 * Throws an error.
	 * @param	p_error
	 * @param	p_data
	 */
	override public function Throw(p_error:Error, p_data:Dynamic = null):Void 
	{		
		app.Throw(p_error, p_data);
	}
	
	/**
	 * Error callback.
	 * @param	p_error
	 * @param	p_data
	 */
	override public function OnError(p_error:Error, p_data:Dynamic):Void 
	{
		
	}
	
	/**
	 * Callback called before a route execution.
	 * @param	p_route
	 */
	public function OnBeforeAction(p_route:String):Void { }
	
	/**
	 * Callback called after a route execution.
	 * @param	p_route
	 */
	public function OnAfterAction(p_route:String):Void { }	
	
	/**
	 * Callback called when a request fails to find any route on this service.
	 */
	public function OnRouteFail():Void {}
	
	/**
	 * Callback called before metadata validation, allowing users to process async or sync data and notify 'onready' when the service can resume execution.
	 * @param	p_meta
	 * @param	p_onready
	 * @return
	 */
	public function OnValidateMetadata(p_meta:MetaData, p_onready : Void->Void) : Bool { return true; }
}