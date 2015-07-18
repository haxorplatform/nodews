package nws.service.controller;

/**
 * Base class that handles notifications coming from clients.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class Controller
{
	
	/**
	 * Reference to the root service.
	 */
	public var service(get, never):ControllerService;
	private function get_service():ControllerService { return m_service; }
	private var m_service : ControllerService;
	
	/**
	 * Name of this controller.
	 */
	public var name(get, never) : String;
	private function get_name():String { return m_name; }
	private var m_name:String;
	
	/**
	 * Regular expression for path filtering.
	 */
	public var route : EReg;
	
	/**
	 * CTOR
	 */
	public function new() 
	{ 
		route = new EReg("(.*?)", "");		
	}
	
	/**
	 * Method called after creation.
	 */
	public function OnCreate():Void { }
	
	/**
	 * Method to be overriden and handle the incoming notifications from client.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function OnNotification(p_path:String,p_event:String,p_data : Dynamic):Void {}
	
}