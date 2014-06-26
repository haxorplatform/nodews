package nws;

import js.html.Event;
import nws.net.HTTPServiceManager;
import js.Error;
import nodejs.fs.File;
import nodejs.mongodb.MongoDatabase;
import nodejs.mongodb.MongoOption.MongoCursorOption;
import nodejs.mongodb.MongoServer;
import nodejs.mongodb.ReadPreference;
import nodejs.NodeJS;
import js.Lib;
import nodejs.mongodb.MongoClient;
import nodejs.mongodb.ObjectID;
import nodejs.net.TCPSocket;
import nodejs.OS;
import nodejs.Process;

/**
 * Entry point for the website services daemon.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class SimpleServiceDaemon 
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
	static function OnError(p_error:Event):Void
	{
		trace("Process> [error] Uncaught[" + p_error + "]");
	}
	
}