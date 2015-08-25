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
	//private var request : IncomingMessage;
	
	/**
	 * Reference for the currently active request.
	 */
	//private var response : ServerResponse;
	
	/**
	 * Reference to the current executing session scope.
	 */
	//private var session:HttpSession;
	
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
	//public var url : UrlData;
	
	/**
	 * Current request path.
	 */
	//public var path : String;
	
	/**
	 * Container of the incoming request data in different formats.
	 */
	//public var data : SessionData;
	
	/**
	 * Flag that indicates a Http handler was found and executed successfully.
	 */
	//public var found : Bool;
	
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
	public function Abort(p_code:Int = 500,p_path:String=""):Void
	{				
		var err :Error = new Error();
		err.name    = "http-abort";		
		err.message = "Request request[" + p_path + "] aborted code[" + p_code+"]";
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
			Log("[error] name[" + p_error.name+"] msg[" + p_error.message+"]");
			/*
			if (response != null)
			{
				response.statusCode = (p_error.name == "http-abort") ? p_data : 500;
				response.end();
			}
			//*/
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
		var req : IncomingMessage = p_request;
		var res : ServerResponse  = p_response;
		
		OnRequest(req, res);
				
		
		var s : HttpSession = new HttpSession();
				
		try
		{
			s.url = Url.parse(req.url);
		}
		catch (err:Error)
		{
			Log("[error] ["+err.name+"]["+err.message+"]");			
			s.url = cast { pathname:"" };
		}
				
		s.http		 = this;
		s.request    = req;
		s.response   = res;
		
		untyped res.__id__  = Math.floor(Math.random() * 0xffffff) + "";
		untyped req.__id__  = res.__id__;
		
		var on_finish : Void->Void = null;
		on_finish = function()
		{			
			Log("Response Finish ["+s.path+"]",5);			
			OnFinish(res);
			TraverseInterfaces(function(n:IHttpHandler):Void { n.OnFinish(s); } );			
			res.removeListener("finish", on_finish);
		};		
		res.on("finish",on_finish);
		
		ProcessSession(s);
		
	}
	
	/**
	 * Process the session that arrived.
	 * @param	p_session
	 */
	private function ProcessSession(p_session:HttpSession):Void
	{
		var s   : HttpSession 	  = p_session;
		var req : IncomingMessage = s.request;
		var res : ServerResponse  = s.response;
		Log("OnRequest method[" + req.method + "] url[" + req.url + "] id["+(untyped res.__id__)+"]", 1);			
		var d : SessionData = s.data = cast { };
		switch(req.method)
		{
			case Method.Get:				
				d.text = s.url.query==null ? "" : s.url.query;
				d.json = d.text == "" ? { } : Querystring.parse(d.text);				
				RequestParsed(s);
				
			case Method.Post:
				
				//If request has multipart content, let the user handle it with his module of choice.
				if (s.multipart)
				{
					RequestParsed(s);
				}
				else
				{
					req.on(ReadableEvent.Data, function(p_data : haxe.extern.EitherType<Buffer,String>):Void
					{	
						try
						{
							
							if (Std.is(p_data, String))
							{				
								d.text = p_data;
								d.json = Url.parse(cast p_data, true);								
							}
							else
							if (Std.is(p_data, Buffer))
							{
								var b : Buffer = cast p_data;
								if (d.buffer == null) d.buffer = b;
								else
								{
									var b0 : Buffer = d.buffer;
									var b1 : Buffer = b;
									d.buffer = Buffer.concat([b0, b1]);									
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
					
					req.on(ReadableEvent.End, function():Void
					{			
						d.text   = d.buffer.toString();
						try { d.json = Json.parse(d.text); } 
						catch (err:Error) 
						{									
							d.json = Url.parse(d.text, true);
						}
						RequestParsed(s);
					});		
				}
			
			default:	
				d.text = s.url.query==null ? "" : s.url.query;
				d.json = d.text=="" ? {} : Querystring.parse(d.text);	
				RequestParsed(s);
		}
	}
	
	/**
	 * Followup after the request's data is parsed.
	 */
	private function RequestParsed(p_session:HttpSession):Void
	{
		var s : HttpSession = p_session;
		if (!s.multipart)
		{
			//Log("Request Parsed text[" + data.text.substr(0, 20) + "...]", 5);
			//s.m_data = data;
		}
		else
		{
			//s.m_data = cast { };
			//s.m_data.text = "";
			//s.m_data.json = {};
		}
		OnRequestParse();
		TraverseInterfaces(function(n:IHttpHandler):Void { n.OnRequest(s); } );		
		if (!s.found)
		{
			//There is no service available
			Log("No service found path[" + s.path + "].", 3);
			s.response.statusCode = 400;
			s.response.end();
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