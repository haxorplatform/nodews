package nws.net;
import js.Error;
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
class HttpServiceManager
{
	/**
	 * Create and start listening for a new HTTPServer in a given port.
	 * @param	p_port
	 * @return
	 */
	static public function Create(p_port : Int = 80):HttpServiceManager
	{
		var s : HttpServiceManager = new HttpServiceManager();
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
	private var method : String;
	
	/**
	 * URLData generated during the OnRequest event.
	 */
	private var url : Dynamic;
	
	/**
	 * Parsed data generated during a request. The user don't need to handle the data manually.
	 */
	private var data : Dynamic;
	
	/**
	 * Instantiated service based on the request path. If the path does not map to any service the default one is used.
	 */
	public var service : BaseService;
	
	/**
	 * Default service when the path didn't map to any other services classes.
	 */
	public var defaultService : BaseService;
	
	/**
	 * Instance of the nodejs Server class used for events.
	 */
	private var server : Server;
	
	/**
	 * Web services table that map the request path to a registered service.
	 */
	private var m_services : Map<String,Class<BaseService>>;

	/**
	 * Creates a new HTTPServer without starting the listening.
	 */
	public function new() 
	{
		defaultService = service = new BaseService(this);
		m_services  = new Map < String, Class<BaseService> > ();
		//server 	= HTTP.createServer(RequestHandler);				
		//server.on(HTTPServerEventType.Connection, OnConnection);
		//server.on(HTTPServerEventType.Error, 	  OnError);			
		verbose = 0;
	}
	
	/**
	 * Adds a WebService and maps it to a given request path.
	 * @param	p_id
	 * @param	p_service_class
	 */
	public function Add(p_id:String, p_service_class : Class<BaseService>):Void
	{
		m_services.set(p_id, p_service_class);
	}
	
	/**
	 * Starts listening to a network port.
	 * @param	p_port
	 */
	public function Listen(p_port : Int = 80):Void
	{
		Log("HTTP> Listening Port ["+p_port+"]");
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
		//method   = p_request.method.toUpperCase();		
		//url 	 = URL.Parse(p_request.url);
		
		var service_id 	   : String = url.pathname;
		var service_exists : Bool   = m_services.exists(service_id);
		
		Log("HTTP> RequestHandler url[" + request.url + "] service["+service_id+"] found["+service_exists+"] method[" + method + "] ip["+request.socket.remoteAddress+":"+request.socket.remotePort+"]", 1);						
		
		if (m_services.exists(service_id))
		{
			var c : Class<BaseService> = m_services.get(service_id);
			service = Type.createInstance(c, [this]);			
		}
		else
		{
			service = defaultService;
		}
		
		service.session.request  = request;
		service.session.response = response;
		service.session.method   = method;
		service.session.url      = url;
		
		
		service.OnInitialize();
		response.setHeader("content-type", service.content);
		
		if (service.enabled)
		{
			OnRequest();
		}
		else
		{
			Log("HTTP> RequestHandler service["+service_id+"] disabled.", 1);						
			if(response != null) response.end();
		}
		
	}
	
	/**
	 * Process the Request arrived on the RequestHandler. 
	 * Any data carried in the request will be correctly parsed and passed to the WebService as an object filled with all needed information. 
	 */
	private function OnRequest():Void
	{
		/*
		switch(method)
		{
			case HTTPMethod.Get:								
				var d :Dynamic = null;
				if (url.query != null) d = URL.ParseQuery(url.query);
				OnGETRequest(request, response,d);
				OnRequestComplete();
				
			case HTTPMethod.Post:
				request.on(IncomingMessageEventType.Data, function(data : Dynamic):Void
				{						
					OnPOSTRequest(request, response, URL.ParseQuery(data.toString()));
				});
				
				request.on(IncomingMessageEventType.End, function():Void
				{					
					OnRequestComplete();
				});			
			
			default:
				Log("HTTP> OnRequest Ignored method["+method+"] url[" + request.url + "]", 1);	
				OnRequestComplete();			
		}
		//*/
	}
	
	/**
	 * Callback called when the 'get' and 'post' requests are handled and parsed.  This method can be overriden to handle operations before 'OnExecute' is called on the service.
	 */
	private function OnRequestComplete()
	{
		Log("HTTP> OnRequestComplete [" + Type.getClassName(Type.getClass(service)) + "] url[" + request.url + "]", 1);	
		service.session.data = data;
		service.OnExecute();		
	}
	
	/**
	 * Callback called when a POST request arrives and process the data.  This method can be overriden to handle the generated data before it is passed to the service.
	 * @param	p_request
	 * @param	p_response
	 * @param	p_data
	 */
	private function OnPOSTRequest(p_request : IncomingMessage, p_response : ServerResponse,p_data : Dynamic):Void
	{
		data = p_data;			
	}
	
	/**
	 * Callback called when a GET request arrives and process the data. This method can be overriden to handle the generated data before it is passed to the service.
	 * @param	p_request
	 * @param	p_response
	 * @param	p_data
	 */
	private function OnGETRequest(p_request : IncomingMessage, p_response : ServerResponse,p_data : Dynamic):Void
	{		
		data = p_data;
	}
	
	/**
	 * Callback to handle the started connection before the request.
	 * @param	p_socket
	 */
	private function OnConnection(p_socket : Socket):Void
	{
		Log("HTTP> OnConnection ip["+p_socket.remoteAddress+"]", 2);
	}
	
	/**
	 * Callback to handle errors.
	 * @param	p_error
	 */
	private function OnError(p_error:Error):Void
	{		
		service.OnError(p_error);
		if(response != null) response.end();
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
	
	
}