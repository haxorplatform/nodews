package;

import js.Node;
import nws.net.HttpServiceManager;
import js.node.events.EventEmitter;
import js.node.events.EventEmitter.Event;
import js.Error;
import js.Lib;
import js.node.net.Socket;
import js.node.Os;
import js.node.Process;
import js.node.Process.ProcessEvent;

/**
 * Entry point for the website services daemon.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Main 
{
	/**
	 * Reference to the HTTPServer being used.
	 */
	static public var server : HttpServiceManager;
	
	/**
	 * Entry point.
	 */
	static function main() 
	{
		trace("Process> Starting WebServiceDaemon");		
		server = HttpServiceManager.Create(8000);
		
		server.verbose = 0;
		
		//Check args for [-vvv...] and set the level of verbose.
		for (a in Node.process.argv) if (a.indexOf("-v") >= 0) server.verbose = a.length - 1;
		
		trace("Process> Verbose Level ["+server.verbose+"]");		
		Node.process.on(ProcessEvent.UncaughtException, OnError);
	}
	
	/**
	 * Handles bubbled up error events and avoid application closing.
	 * @param	p_error
	 */
	static function OnError(p_error:Error):Void
	{
		trace("Process> [error] Uncaught[" + p_error + "]");
	}
	
}