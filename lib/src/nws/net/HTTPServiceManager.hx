package nws.net;
import js.Error;
import nodejs.NodeJS;
import nws.service.BaseService;
import js.html.Uint8Array;
import nodejs.http.HTTP;
import nodejs.http.IncomingMessage;
import nodejs.http.MultipartForm;
import nodejs.http.HTTPServer;
import nodejs.http.ServerResponse;
import nodejs.http.URL;
import nodejs.http.URLData;
import nodejs.net.TCPSocket;

/**
 * Wrapper for the HTTP module of nodejs. Handles incoming requests by checking their 'path' and mapping them to registered BaseServices the user created.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class HTTPServiceManager
{
	/**
	 * Create and start listening for a new HTTPServer in a given port.
	 * @param	p_port
	 * @return
	 */
	static public function Create(p_port : Int = 80):HTTPServiceManager
	{
		var s : HTTPServiceManager = new HTTPServiceManager();
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
	
	/**
	 * Instantiated service based on the request path. If the path does not map to any service the default one is used.
	 */
	public var service : BaseService;
	
	/**
	 * Default service when the path didn't map to any other services classes.
	 */
	public var defaultService : BaseService;
	
	
	/**
	 * Multipart options for this content-type.
	 */
	public var multipart : MultipartFormOption;
	
	/**
	 * Instance of the nodejs Server class used for events.
	 */
	private var server : HTTPServer;
	
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
		server 	= HTTP.createServer(RequestHandler);				
		server.on(HTTPServerEventType.Connection, OnConnection);
		server.on(HTTPServerEventType.Error, 	  OnError);	
		
		multipart = cast { };
		
		multipart.uploadDir = "uploads";
		
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
		method   = p_request.method.toUpperCase();		
		url 	 = URL.Parse(p_request.url);
		
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
		switch(method)
		{
			case HTTPMethod.Get:								
				var d :Dynamic = null;
				if (url.query != null) d = URL.ParseQuery(url.query);
				OnGETRequest(request, response,d);
				OnRequestComplete();
				
			case HTTPMethod.Post:
				var content_type : String = untyped request.headers["content-type"];
				if (content_type.toLowerCase().indexOf("multipart") >= 0)
				{
					try
					{
						ProcessMultipart(request, response);						
					}catch (e:Error) 
					{ 
						Log("HTTP> [error] OnRequest [" + e+"]");
						Log("\t"+e.stack,1);
						OnError(e);
					}
				}
				else
				{				
					request.on(IncomingMessageEventType.Data, function(data : Dynamic):Void
					{						
						OnPOSTRequest(request, response, URL.ParseQuery(data.toString()));
					});
					
					request.on(IncomingMessageEventType.End, function():Void
					{					
						OnRequestComplete();
					});
				}
								
			
			default:
				Log("HTTP> OnRequest Ignored method["+method+"] url[" + request.url + "]", 1);	
				OnRequestComplete();			
		}
		
	}
	
	/**
	 * Callback called when the 'get' and 'post' requests are handled and parsed.  This method can be overriden to handle operations before 'OnExecute' is called on the service.
	 */
	private function OnRequestComplete()
	{
		Log("HTTP> OnRequestComplete ["+Type.getClassName(Type.getClass(service))+"] url[" + request.url + "]", 1);	
		service.OnExecute();
		response.end();
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
	 * Callback used to handle 'post' with 'multi-part' content-type.
	 * @param	p_request
	 * @param	p_response
	 */
	private function ProcessMultipart(p_request : IncomingMessage, p_response : ServerResponse):Void
	{
		Log("HTTP> ProcessMultipart",3);
		var d : Dynamic = { };
		var f : MultipartForm = URL.ParseMultipart(p_request,null,multipart);
		/*
		, function(p_error:String, p_fields : Array<Dynamic>, p_files : Array<FormFile>):Void
		{
			if (p_error != null) if (p_error != "") { Log("HTTP> [error] ProcessMultiPart [" + p_error + "]"); p_response.write("false"); p_response.end(); return; }			
			trace(p_fields);
			
			
		});
		//*/
		
		f.on(MultipartFormEventType.Error, function(p_error : Error)
		{
			Log("HTTP> [error] ProcessMultiPart [" + p_error + "]");
			OnError(p_error);			
		});
		
		f.on(MultipartFormEventType.Progress, function(l:Int, t:Int)
		{
			Log("HTTP> Multipart Progress [" + l + "/" + t + "]",2);
		});
		
		f.on(MultipartFormEventType.Field, function(p_key : String, p_value : String)
		{
			Log("HTTP> \t" + p_key + " = " + p_value, 3);
			//if (p_value != null)
			//{
				untyped d[p_key] = p_value;
			//}
		});
		
		f.on(MultipartFormEventType.File, function(p_name : String, p_file : FormFile)
		{
			Log("HTTP> \t file[" + p_name+"]\n\t" + p_file, 3);			
			//if (p_file != null)
			//{
				untyped d[p_name] = p_file;			
			//}
		});
		
		
		f.on(MultipartFormEventType.Close, function()
		{			
			OnPOSTRequest(p_request, p_response, d);
			OnRequestComplete();
		});
		//*/
	}
	
	/**
	 * Callback to handle the started connection before the request.
	 * @param	p_socket
	 */
	private function OnConnection(p_socket : TCPSocket):Void
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
		response.end();
	}
	
	/**
	 * Logging method that accept messages and their verbose level.
	 * @param	p_message
	 * @param	p_level
	 */
	public function Log(p_message:String, p_level :Int = 0):Void
	{
		if (p_level <= verbose) trace(p_message);
	}
	
	
}