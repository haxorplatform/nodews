package nws.service;
import haxe.Timer;
import js.node.http.IncomingMessage;
import js.node.http.Method;
import js.node.http.ServerResponse;


/**
 * Class that contains the reference for HTTP information during the BaseService execution.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class ServiceSession
{
	/**
	 * Current ServerResponse during a OnRequest event.
	 */
	public var response : ServerResponse;
	
	/**
	 * Current request data during the OnRequest event.
	 */
	public var request : IncomingMessage;
	
	/**
	 * Request method.
	 */
	public var method : Method;
	
	/**
	 * URLData generated during the OnRequest event.
	 */
	public var url : Dynamic;
	
	/**
	 * Parsed data generated during a request. The user don't need to handle the data manually.
	 */
	public var data : Dynamic;

	/**
	 * Creates the service session.
	 */
	public function new() 
	{		
		method = Method.Post;
	}
	
	
	
}