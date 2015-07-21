package nws.component.service;
import haxe.Json;
import js.Error;
import js.node.http.Method;
import nws.component.util.Notification;


/**
 * Class that receive FrontEnd notifications and transparently communicates with clients.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class NotificationService extends Service
{	
	
	/**
	 * Buffer of notifications to be sent.
	 */
	public var notification(get, never): Notification;
	private function get_notification():Notification
	{
		if (m_notification != null) return m_notification;
		return m_notification = cast controller.AddComponent(Notification);
	}
	private var m_notification : Notification;
	
	/**
	 * Auto sends the buffer.
	 */
	public var auto : Bool;
	
	/**
	 * Internal CTOR.
	 */
	override private function new():Void
	{
		super();
		auto   		= true;
		persistent  = true;
	}
	
	/**
	 * Callback called before the routes execution.
	 * @param	p_route
	 */
	override public function OnBeforeAction(p_route:String):Void 
	{	
		notification.Clear();
		
		var n : NotificationData=null;
		
		if (session.method == Method.Get)
		{
			try { n = Json.parse(session.data.json.notification); } catch (err:Error) { n = null; }
		}
		else
		{			
			n = session.data.json;
		}
		
		if (n == null)
		{
			var err : Error = new Error();
			err.name 	= "notification-service-error";
			err.message = "Invalid notification.";
			Throw(err);
			return;
		}
		var invalid_path:Bool = (n.path == null) || (n.path == "");
		if (invalid_path)
		{
			var err : Error = new Error();
			err.name 	= "notification-service-error";
			err.message = "Invalid notification [path].";
			Throw(err);
			return;
		}
		n.event = n.event == null ? "" : n.event;
		n.data  = n.data == null ? { } : n.data;
		controller.Notify(n.path, n.event, n.data);
	}
	
	/**
	 * Callback called after route execution.
	 * @param	p_route
	 */
	override public function OnAfterAction(p_route:String):Void 
	{
		if(auto) End();
	}
	
	/**
	 * Ends the service execution and flushes the notification buffer.
	 * @param	p_code
	 */
	public function End(p_code:Int = 200):Void
	{		
		if (session.finished) return;
		session.response.statusCode = p_code;
		session.response.write(notification.Flush());
		session.response.end();
	}
	
}