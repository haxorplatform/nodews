package nws.service;
import nws.net.HttpServiceManager;

/**
 * Base class for implementing a web service. The user only needs to process the data and write the response for the server.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
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
	public function new(p_server : HttpServiceManager) 
	{
		manager  = p_server;
		session  = new ServiceSession();
		content  = "text/plain";
		code     = 200;		
		enabled  = true;
	}
	
	/**
	 * Method called when a Request arrives on the server and after the Service is instantiated.
	 * Describe the content type and response code that will be used.
	 */
	public function OnInitialize():Void	{}
	
	/**
	 * Method called after all data os processed on server
	 */
	public function OnExecute():Void {}
	
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