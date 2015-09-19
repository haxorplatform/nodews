package nws;
import js.Error;
import js.Node;
import js.node.Os;
import js.node.Process.ProcessEvent;
import js.RegExp;
import nws.Entity;

/**
 * Base class for MVC applications. The root MVC instances must be informed.
 */
class ApplicationMVC<M,V,C> extends Application
{
	public var model      : M;
	public var view       : V;
	public var controller : C;
}

/**
 * Base class that describes a web application.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class Application extends Entity
{
	/**
	 * Global reference to the application created.
	 */
	static var instance : Application;

	/**
	 * Verbose level.
	 */
	public var verbose : Int;
	
	/**
	 * Returns the hostname.
	 */
	public var host(get, never):String;
	private function get_host():String { return Os.hostname(); }
	
	/**
	 * Flag that indicates the platform is unix.
	 */
	public var unix(get, never):Bool;
	private function get_unix():Bool { return !(new RegExp("^win").test(Node.process.platform)); }
	
	/**
	 * CTOR.
	 */
	public function new() 
	{
		super("application");
		
		instance = this;
		
		verbose = 4;
		
		//Check args for [-vvv...] and set the level of verbose.
		for (a in Node.process.argv) if (a.indexOf("-v") >= 0) verbose = a.length - 1;
		
		Node.process.on(ProcessEvent.UncaughtException, function(err:Error)
		{
			OnProcessError(err);
			Throw(err);
		});		
		
		untyped console.log(GetTypeName() + "> Initialize verbose[" + verbose+"] hostname[" + host + "]");		
		
		OnInitialize();
	}
	
	/**
	 * Checks if a given 'require' module exists.
	 * @param	p_module
	 * @return
	 */
	public function HasModule(p_module:String):Bool
	{
		var exists : Bool = true;		
		try { Node.require(p_module); }
		catch (err:Error) { exists = false; }
		return exists;		
	}
	
	/**
	 * Throws an error and log it.
	 * @param	p_error
	 */
	override public function Throw(p_error:Error,p_data:Dynamic=null):Void 
	{
		var en : String = p_error == null ? "" : "[" + p_error.name+"]";
		var em : String = p_error == null ? "" : "[" + p_error.message+"]";		
		Log("Error " + en + em);
		if (p_error != null) untyped console.log(p_error.stack);
		super.Throw(p_error);
	}
	
	/**
	 * Logs a message if the level is smaller or equal than 'verbose.'
	 * @param	p_msg
	 * @param	p_level
	 */
	public function Log(p_msg:Dynamic, p_level:Int = 0):Void { if (p_level <= verbose) untyped console.log(GetTypeName()+">",p_msg); }
	
	/**
	 * Callback called on everything is initialized and ready to run.
	 */
	public function OnInitialize():Void { }
	
	/**
	 * Callback called when the running process emits an error.
	 * @param	p_error
	 */
	public function OnProcessError(p_error:Error):Void { }
	
}
