package nws.net;
import js.Error;
import js.Node;
import js.node.http.Method;
import js.node.Querystring;
import js.node.stream.Readable;
import js.node.Url;
import nws.service.BaseService;
import js.html.Uint8Array;
import js.node.Http;
import js.node.http.IncomingMessage;
import js.node.http.Server;
import js.node.http.ServerResponse;
import js.node.net.Socket;

/**
 * Wrapper for the HTTP module of nodejs. Handles incoming requests by checking their 'path' and mapping them to registered BaseServices the user created.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class HttpApplication
{
	/**
	 * Create and start listening for a new HTTPServer in a given port.
	 * @param	p_port
	 * @return
	 */
	static public function Create(p_port : Int = 80):HttpApplication
	{
		var s : HttpApplication = new HttpApplication();
		s.Listen(p_port);
		return s;
	}
	
	/**
	 * Verbose level to filter how much logging the server will make.
	 */
	public var verbose : Int;
	
	
	/**
	 * Current ServerResponse during a OnRequest event.
	 */
	private var response : ServerResponse;
	
	/**
	 * Current request data during the OnRequest event.
	 */
	private var request : IncomingMessage;
	
	/**
	 * Request method 'get' or 'post'
	 */
	private var method : Method;
	
	/**
	 * URLData generated during the OnRequest event.
	 */
	private var url : UrlData;
	
	/**
	 * Parsed data generated during a request. The user don't need to handle the data manually.
	 */
	private var data : Dynamic;
	
	/**
	 * Instantiated service based on the request path.
	 */
	public var service : BaseService;
	
	/**
	 * Instance of the nodejs Server class used for events.
	 */
	private var server : Server;
	
	/**
	 * Web services table that map the request path to a registered service.
	 */
	private var m_services : Array<ServiceEntry>;

	/**
	 * Creates a new HTTPServer without starting the listening.
	 */
	public function new() 
	{
		m_services  = [];
		server 	= Http.createServer(RequestHandler);		
		server.on(ServerEvent.Connection,     OnConnection);		
		server.on(ServerEvent.ClientError, 	  OnError);			
		verbose = 0;
	}
	
	/**
	 * Adds a WebService and maps it to a given request path.
	 * @param	p_id
	 * @param	p_service_class
	 */	
	public function Add(p_service_class : Class<BaseService>,p_rule:String,p_opt:String=""):Void
	{
		var ereg : EReg = new EReg(p_rule,p_opt);
		var e : ServiceEntry = new ServiceEntry(ereg, p_service_class);
		m_services.push(e);
	}
	
	/**
	 * Starts listening to a network port.
	 * @param	p_port
	 */
	public function Listen(p_port : Int = 80):Void
	{
		Log("Http> Listening Port ["+p_port+"]");
		server.listen(p_port);
	}
	
	/**	
	 * Method called when a client makes a request. The path of the request will be checked and a BaseService will maybe be created.
	 * If any service is mapped to that path, the default BaseService will be used (only ends the response).
	 * @param	p_request
	 * @param	p_response
	 */
	private function RequestHandler(p_request : IncomingMessage, p_response : ServerResponse):Void
	{
		request  = p_request;
		response = p_response;
		method   = p_request.method;
		url 	 = Url.parse(p_request.url);
		
		var service_path : String = url.pathname;
		
		var el : Array<ServiceEntry> = FindAll(service_path);
		
		Log("Http> RequestHandler url[" + request.url + "] service["+service_path+"] method[" + method + "] ip["+request.socket.remoteAddress+":"+request.socket.remotePort+"]", 1);						
		
		if (el.length>0)
		{
			for (i in 0...el.length)
			{
				var e : ServiceEntry = el[i];
				var s : BaseService  = e.GetInstance();				
				service = s;
				if (s == null) continue;
				s.application	   = this;
				s.session.request  = request;
				s.session.response = response;
				s.session.method   = method;
				s.session.url      = url;				
				
				s.OnInitialize();
				
				//Prepare with intermediate status-code and content
				response.statusCode = s.code;
				response.setHeader("content-type", s.content);
				
				if (s.enabled)
				{
					OnRequest();
				}
				else
				{
					Log("Http> RequestHandler service["+service_path+"] disabled.", 2);					
				}				
			}
							
		}
		else
		{
			//There is no service available
			response.statusCode = 400;
			response.end();
		}
		
	}
	
	/**
	 * Process the Request arrived on the RequestHandler. 
	 * Any data carried in the request will be correctly parsed and passed to the WebService as an object filled with all needed information. 
	 */
	private function OnRequest():Void
	{
		Log("Http> OnRequest method[" + method + "] url[" + request.url + "]", 1);	
		data = null;
		switch(method)
		{
			case Method.Get:
				var d :Dynamic = null;
				if (url.query != null) d = Querystring.parse(url.query);
				data = d;				
				OnRequestLoad();
				OnRequestComplete();
				
			case Method.Post:
				request.on(ReadableEvent.Data, function(p_data : String):Void
				{						
					data = Url.parse(p_data,true);					
				});
				
				request.on(ReadableEvent.End, function():Void
				{					
					OnRequestLoad();
					OnRequestComplete();
				});			
			
			default:	
				var d :Dynamic = null;
				if (url.query != null) d = Querystring.parse(url.query);
				data = d;		
				OnRequestLoad();	
				OnRequestComplete();
		}
		//*/
	}
	
	/**
	 * Callback called when the requests are handled and parsed.  This method can be overriden to handle operations before 'OnExecute' is called on the service.
	 */
	private function OnRequestLoad()
	{
		Log("Http> OnRequestLoad [" + Type.getClassName(Type.getClass(service)) + "]", 2);	
		service.session.data = data;
		service.Execute();
		
	}
	
	/**
	 * Callback called after the request was loaded and the service has executed.
	 */
	private function OnRequestComplete():Void { }
	
	/**
	 * Callback to handle the started connection before the request.
	 * @param	p_socket
	 */
	private function OnConnection(p_socket : Socket):Void
	{
		Log("HTTP> OnConnection ip["+p_socket.remoteAddress+"]", 3);
	}
	
	/**
	 * Callback to handle errors.
	 * @param	p_error
	 */
	private function OnError(p_error:Error,p_socket:Socket):Void
	{		
		service.OnError(p_error);
		if (response != null)
		{
			response.statusCode = 500;
			response.end();
		}
	}
	
	/**
	 * Logging method that accept messages and their verbose level.
	 * @param	p_message
	 * @param	p_level
	 */
	public function Log(p_message:Dynamic, p_level :Int = 0):Void
	{
		if (p_level <= verbose) trace(p_message);
	}
	
	/**
	 * Finds the first entry which matches the path string.
	 * @param	p_path
	 * @return
	 */
	public function Find(p_path : String) : ServiceEntry
	{
		for (i in 0...m_services.length)
		{
			var e : ServiceEntry = m_services[i];
			if (e.rule.match(p_path)) return e;
		}
		return null;
	}
	
	/**
	 * Finds all entries which matches the path string.
	 * @param	p_path
	 * @return
	 */
	public function FindAll(p_path : String) : Array<ServiceEntry>
	{
		var res : Array<ServiceEntry> = [];
		for (i in 0...m_services.length)
		{
			var e : ServiceEntry = m_services[i];
			if (e.rule.match(p_path)) res.push(e);
		}
		return res;
	}
}
