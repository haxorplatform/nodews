package nws.service;
import haxe.Timer;
import nodejs.crypto.Crypto;
import nodejs.crypto.Hash;
import nodejs.http.IncomingMessage;
import nodejs.http.ServerResponse;
import nodejs.http.URLData;

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
	 * Request method 'get' or 'post'
	 */
	public var method : String;
	
	/**
	 * URLData generated during the OnRequest event.
	 */
	public var url : URLData;
	
	/**
	 * Parsed data generated during a 'get' or 'post' request. The user don't need to handle the data manually.
	 */
	public var data : Dynamic;

	public function new() 
	{
		
	}
	
	
	
}