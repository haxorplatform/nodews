package nws.component.util;
import haxe.Json;
import js.Error;
import js.node.http.Method;


/**
 * Class that describes the JSON data arrived on a request.
 */
extern class NotificationData
{
	var path:String;
	var event:String;
	var data:Dynamic;
}

/**
 * Class that handles a notification buffer.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Notification extends Component
{	
	
	/**
	 * Notification buffer.
	 */
	public var buffer : Array<NotificationData>;
	
	/**
	 * Internal CTOR.
	 */
	override private function new():Void
	{
		super();
		buffer 		= [];		
	}
	
	/**
	 * Adds a notification to the response buffer.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function Write(p_path:String, p_event:String, p_data:Dynamic=null):Void
	{
		var n : NotificationData = cast { };
		n.path  = p_path;
		n.event = p_event;
		n.data  = p_data==null ? {} : p_data;
		buffer.push(n);
	}
	
	/**
	 * Flushes the buffer clearing it and returning the resulting json.
	 * @param	p_code
	 */
	public function Flush():String
	{
		var str : String = Json.stringify(buffer);		
		Clear();
		return str;
	}
	
	/**
	 * Clears the notification buffer.
	 */
	public function Clear():Void { buffer = [];	}	
	
}