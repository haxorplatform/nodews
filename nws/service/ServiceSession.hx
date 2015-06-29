package nws.service;
import haxe.Timer;
import js.node.http.IncomingMessage;
import js.node.http.Method;
import js.node.http.ServerResponse;
import js.node.Url.UrlData;


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
	public var url : UrlData;
	
	/**
	 * Parsed data generated during a request. The user don't need to handle the data manually.
	 */
	public var data : Dynamic;

	/**
	 * Http Status Code.
	 */
	public var status(get, set):Int;
	private function get_status():Int { return response == null ? 400 : response.statusCode; }
	private function set_status(v:Int):Int { if (response != null) response.statusCode = v; return v; }
	
	/**
	 * Response content type.
	 */
	public var content(get, set):String;
	private function get_content():String 			{ return response == null ? "text/plain" : response.getHeader("content-type"); }
	private function set_content(v:String):String 	{ if (response != null) response.setHeader("content-type", v); return v; }
	
	/**
	 * Response content length.
	 */
	public var length(get, set):Int;
	private function get_length():Int 			{ return response == null ? 0 : Std.parseInt(response.getHeader("content-length")); }
	private function set_length(v:Int):Int 		{ if (response != null) response.setHeader("content-length",v+""); return v; }
	
	/**
	 * Creates the service session.
	 */
	public function new() 
	{		
		method = Method.Post;
	}
	
	
	
}