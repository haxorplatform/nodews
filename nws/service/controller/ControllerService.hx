package nws.service.controller;
import haxe.Json;
import js.Error;
import js.node.http.Method;
import nws.net.Plugin;
import nws.service.BaseService;


/**
 * Class that describes the JSON data arrived on a request.
 */
extern class ControllerNotification
{
	var path:String;
	var event:String;
	var data:Dynamic;
}

/**
 * Class that receive FrontEnd notifications and transparently communicates with clients.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class ControllerService extends BaseService
{	
	/**
	 * List of Controllers.
	 */
	public var list : Array<Controller>;
	
	/**
	 * Buffer of notifications to be sent.
	 */
	public var buffer : Array<ControllerNotification>;
	
	/**
	 * CTOR
	 */
	override public function new()
	{
		super();
		list 		= [];
		buffer 		= [];
		persistent  = true;
	}
	
	/**
	 * Callback called for route execution.
	 */
	override public function Execute():Void 
	{
		Clear();
		super.Execute();
	}
	
	/**
	 * Adds a controller instance.
	 * @param	p_controller_type
	 * @return
	 */
	public function Add(p_controller_type : Class<Controller>):Controller
	{
		var c : Controller = cast Type.createInstance(p_controller_type, []);
		c.m_service = this;
		c.OnCreate();
		list.push(c);
		return c;
	}
	
	/**
	 * Removes a controller instance.
	 * @param	p_controller
	 * @return
	 */
	public function Remove(p_controller:Controller):Controller
	{
		var c : Controller = p_controller;
		if (list.indexOf(c) < 0) return null;
		list.remove(c);
		return c;
	}
	
	/**
	 * Emmits a notification back to client.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function Dispatch(p_path:String, p_event:String, p_data:Dynamic=null):Void
	{
		for (c in list) c.OnNotification(p_path, p_event, p_data);		
	}
	
	/**
	 * Adds a notification to the response buffer.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function Write(p_path:String, p_event:String, p_data:Dynamic=null):Void
	{
		var n : ControllerNotification = cast { };
		n.path  = p_path;
		n.event = p_event;
		n.data  = p_data==null ? {} : p_data;
		buffer.push(n);
	}
	
	/**
	 * Ends the service execution and flushes the notification buffer.
	 * @param	p_code
	 */
	public function End(p_code:Int = 200):Void
	{
		var json : String = Json.stringify(buffer);
		session.response.statusCode = p_code;
		session.response.write(json);
		session.response.end();		
	}
	
	/**
	 * Clears the notification buffer.
	 */
	public function Clear():Void
	{
		buffer = [];
	}
	
	/**
	 * Method to be overriden and handle the incoming notifications from client.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function OnNotification(p_path:String,p_event:String,p_data : Dynamic):Void {}
	
	/**
	 * Method called to handle a session based on notifications.
	 */
	public function Notify():Void
	{		
		var n : ControllerNotification = cast (session.request.method == Method.Get ? Json.parse(session.data.notification) : session.data);		
		if (n.path == null) 
		{ 
			var err : Error = new Error("Notification Path is not defined. At least send { path: 'some.path' }");
			err.name = "controller_invalid_path";
			application.Throw(err);
			return;
		}		
		if (n.event == null) n.event = "";
		if (n.data  == null) n.data  = {};		
		OnNotification(n.path, n.event, n.data);		
		for (c in list)
		{			
			if(c.route.match(n.path)) c.OnNotification(n.path, n.event, n.data);
		}
	}
	
}