package ;
import example.service.Contact;
import js.Error;
import nodejs.net.MailServer;
import nodejs.NodeJS;
import nodejs.Process.ProcessEventType;
import nws.net.HTTPServiceManager;

/**
 * Entry point for the website services daemon.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class ServiceDaemon 
{
	/**
	 * Reference to the HTTPServer being used.
	 */
	static public var http : HTTPServiceManager;
	
	/**
	 * Entry point.
	 */
	static function main() 
	{
		trace("Process> Starting WebServiceDaemon");		
		http = HTTPServiceManager.Create(8000);
		
		//Registers the Contact webservice to the [/contact/] web path.
		http.Add("/contact/", Contact);
		
		http.verbose = 0;		
		//Check args for [-vvv...] and set the level of verbose.
		for (a in NodeJS.process.argv) if (a.indexOf("-v") >= 0) http.verbose = a.length - 1;
		
		trace("Process> Verbose Level ["+http.verbose+"]");		
		NodeJS.process.on(ProcessEventType.Exception, OnError);				
	}
	
	/**
	 * Handles bubbled up error events and avoid application closing.
	 * @param	p_error
	 */
	static function OnError(p_error:Error):Void
	{
		trace("Process> [error] Uncaught[" + p_error + "]\n\t"+p_error.stack);
	}
	
}