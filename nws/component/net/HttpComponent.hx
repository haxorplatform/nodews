package nws.component.net;
import haxe.Json;
import js.Error;
import js.node.Buffer;
import js.node.Http;
import js.node.http.IncomingMessage;
import js.node.http.Method;
import js.node.http.Server;
import js.node.http.ServerResponse;
import js.node.net.Socket;
import js.node.Querystring;
import js.node.stream.Readable.ReadableEvent;
import js.node.Url;
import js.node.Url.UrlData;
import nws.component.Component;
import nws.component.net.HttpSession.SessionData;
import nws.Entity;

/**
 * Class that implements an Http server component.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class HttpComponent extends Component
{	
	/**
	 * Server port.
	 */
	public var port(get, never):Int;
	private function get_port():Int { return m_port; }
	private var m_port : Int;
		
	/**
	 * Reference for the currently active request.
	 */
	private var request : IncomingMessage;
	
	/**
	 * Reference for the currently active request.
	 */
	private var response : ServerResponse;
	
	/**
	 * Reference to the current executing session scope.
	 */
	private var session:HttpSession;
	
	/**
	 * Reference for this component's server.
	 */
	public var server(get, never):Server;
	private function get_server():Server { return m_server; }
	private var m_server : Server;
	
	/**
	 * Returns a flag indicating if this component is listening to a port.
	 */
	public var listening(get, never):Bool;
	private function get_listening():Bool { return m_server != null; }
		
	/**
	 * URL Data incoming from the request.
	 */
	public var url : UrlData;
	
	/**
	 * Current request path.
	 */
	public var path : String;
	
	/**
	 * Container of the incoming request data in different formats.
	 */
	public var data : SessionData;
	
	/**
	 * Flag that indicates a Http handler was found and executed successfully.
	 */
	public var found : Bool;
	
	/**
	 * Creates a HttpServer and start listening.
	 * @param	p_port
	 */
	public function Listen(p_port:Int):Void 
	{
		if (listening)
		{
			Log("[warning] port[" + p_port + "] already active!");
			return;
		}		
		m_port  = p_port;
		m_server 	= Http.createServer(RequestHandler);		
		m_server.on(ServerEvent.Connection,     ConnectionHandler);		
		m_server.on(ServerEvent.ClientError, 	  function(err:Error, s : Socket) { Throw(err, s); }  );
		try
		{
			m_server.listen(p_port);	
			Log("Listening to port["+p_port+"]",1);
		}
		catch (err:Error)
		{
			Throw(err);
		}
	}
	
	/**
	 * Aborts the current request.
	 * @param	p_code
	 */
	public function Abort(p_code:Int = 500):Void
	{				
		var err :Error = new Error();
		err.name    = "http-abort";		
		err.message = "Request request[" + path + "] aborted code[" + p_code+"]";
		Throw(err, p_code);
	}
	
	/**
	 * Callback called when an error arrives from the this component hierarchy.
	 * @param	p_error
	 * @param	p_data
	 */
	override public function OnError(p_error:Error, p_data:Dynamic):Void 
	{	
		if (p_error != null)
		{
			Log("[error] name["+p_error.name+"] msg["+p_error.message+"]");
			if (response != null)
			{
				response.statusCode = (p_error.name == "http-abort") ? p_data : 500;
				response.end();
			}			
		}
	}
	
	/**
	 * Handles an incoming connection.
	 * @param	p_socket
	 */
	private function ConnectionHandler(p_socket:Socket):Void
	{
		Log("OnConnection ip[" + p_socket.remoteAddress + "]", 5);
		OnConnection(p_socket);
	}
	
	/**
	 * 
	 * @param	p_socket
	 */
	private function RequestHandler(p_request:IncomingMessage, p_response:ServerResponse):Void
	{		
		found = false;
		OnRequest(p_request, p_response);
		request   = p_request;
		response  = p_response;		
		
		try
		{
			url = Url.parse(p_request.url);
		}
		catch (err:Error)
		{
			Log("[error] ["+err.name+"]["+err.message+"]");			
			url = cast { pathname:"" };
		}
		
		path = url.pathname;
		
		session = new HttpSession();
		session.method 	   = p_request.method;
		session.request    = p_request;
		session.response   = p_response;
		
		untyped p_response.__id__ = Math.floor(Math.random() * 0xffffff) + "";
		untyped p_request.__id__ = p_response.__id__;
		
		var on_finish : Void->Void = null;
		on_finish = function()
		{			
			Log("Response Finish ["+path+"]",5);			
			OnFinish(response);
			TraverseInterfaces(function(n:IHttpHandler):Void { n.OnFinish(this); } );			
			response.removeListener("finish", on_finish);
		};
		
		response.on("finish",on_finish);
		
		Log("OnRequest method[" + request.method + "] url[" + request.url + "] id["+(untyped p_response.__id__)+"]", 1);			
		data = cast { };
		switch(request.method)
		{
			case Method.Get:				
				data.text = url.query==null ? "" : url.query;
				data.json = data.text == "" ? { } : Querystring.parse(data.text);				
				RequestParsed();
				
			case Method.Post:
				
				//If request has multipart content, let the user handle it with his module of choice.
				if (session.multipart)
				{
					RequestParsed();
				}
				else
				{
					request.on(ReadableEvent.Data, function(p_data : haxe.extern.EitherType<Buffer,String>):Void
					{	
						try
						{
							if (Std.is(p_data, String))
							{				
								data.text = p_data;
								data.json = Url.parse(cast p_data, true);								
							}
							else
							if (Std.is(p_data, Buffer))
							{
								var b : Buffer = cast p_data;
								data.buffer = b;
								data.text   = b.toString();
								
								try { data.json = Json.parse(data.text); } 
								catch (err:Error) 
								{									
									data.json = Url.parse(data.text, true);
								}
							}
						}
						catch (err:Error)
						{
							Log("[error] Fail to parse POST data.");
							Log(p_data);
							Throw(err);
						}
					});
					
					request.on(ReadableEvent.End, function():Void
					{					
						RequestParsed();
					});		
				}
			
			default:	
				data.text = url.query==null ? "" : url.query;
				data.json = data.text=="" ? {} : Querystring.parse(data.text);	
				RequestParsed();
		}
	}
	
	/**
	 * Followup after the request's data is parsed.
	 */
	private function RequestParsed():Void
	{
		if (!session.multipart)
		{
			//Log("Request Parsed text[" + data.text.substr(0, 20) + "...]", 5);
			session.m_data = data;
		}
		else
		{
			session.m_data = cast { };
			session.m_data.text = "";
			session.m_data.json = {};
		}
		OnRequestParse();
		TraverseInterfaces(function(n:IHttpHandler):Void { n.OnRequest(this); } );
		if (!found)
		{
			//There is no service available
			Log("No service found path[" + path + "].", 3);
			response.statusCode = 400;
			response.end();
		}
	}
	
	@:noCompletion
	private function TraverseInterfaces(p_callback : IHttpHandler->Void):Void
	{		
		var cb : Entity->Bool = 
		function(e:Entity):Bool 
		{ 			
			if (Std.is(e, IHttpHandler))
			{
				p_callback(cast e); 
			}
			for (c in e.m_components)
			{				
				if (Std.is(c, IHttpHandler))
				{
					p_callback(cast c);
				}
			}
			return true;
		}		
		entity.Traverse(cb);
	}	
	
	/**
	 * Callback called when the current request has finished.
	 */
	public function OnFinish(p_response:ServerResponse):Void { }
	
	/**
	 * Callback called upon connection.
	 * @param	p_socket
	 */
	public function OnConnection(p_socket:Socket):Void { }
	
	/**
	 * Callback called after the request's data is parsed.
	 */
	public function OnRequestParse():Void { }
	
	/**
	 * Callback called when a request arrives.
	 * @param	p_request
	 * @param	p_response
	 */
	public function OnRequest(p_request:IncomingMessage, p_response:ServerResponse):Void {	}
}