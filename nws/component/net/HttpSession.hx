package nws.component.net;
import js.node.Buffer;
import js.node.http.IncomingMessage;
import js.node.http.Method;
import js.node.http.ServerResponse;
import js.node.Url.UrlData;

/**
 * Class that describes the possible formats of a request data.
 */
extern class SessionData
{
	var text   : String;
	var buffer : Buffer;
	var json   : Dynamic;
}

/**
 * Class that describes a cookie data.
 */
class CookieData
{
	/**
	 * CTOR
	 */
	public function new():Void { }
	
	/**
	 * Returns a flag that tells if a given key exists in the cookie.
	 * @param	p_key
	 * @return
	 */
	public function Contains(p_key:String):Bool { return untyped (this[p_key] != null); }
}

/**
 * Class that contains the reference for HTTP information during the BaseService execution.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class HttpSession
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
	public var data(get,never) : SessionData;
	private function get_data():SessionData { return m_data; }
	private var m_data : SessionData;
	
	/**
	 * Flag that indicates if the incoming content is multipart/form
	 */
	public var multipart(get, null):Bool;
	private function get_multipart():Bool 
	{ 
		if (request == null) return false;
		if (!request.headers.exists("content-type")) return false;		
		return request.headers["content-type"].toLowerCase().indexOf("multipart") >= 0;	
	}
	
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
	 * Flag that indicates the response was sent to client.
	 */
	public var finished(get, never):Bool;
	private function get_finished():Bool { return m_finished; }
	private var m_finished : Bool;
	
	/**
	 * Flag that indicates if the session is still valid and usable.
	 */
	public var valid(get, never):Bool;
	private function get_valid():Bool
	{
		if (request == null) return false;
		if (response == null) return false;		
		if (m_finished) return false;
		return true;
	}
	
	/**
	 * Returns an object filled with cookie informations.
	 */
	public var cookies(get, never) : CookieData;
	private function get_cookies():CookieData
	{
		var c : CookieData = new CookieData();
		var cs : String = untyped request.headers.cookies;		
		if (cs == null) return c;					
		var atrributes : Array<String> = cs.split("; ");			
		for (a in atrributes) 
		{			
			var pair : Array<String> = a.split("=");
			if (pair.length <= 0) continue;
			var k : String  = pair[0];
			var v : Dynamic = pair[1]==null ? {} : pair[1];
			untyped c[k] = v;
		} 		
		return c;
	}
	
	/**
	 * Creates the service session.
	 */
	public function new() 
	{		
		method = Method.Post;
		m_data = cast { };		
		m_finished = false;
	}
	
	
	
}