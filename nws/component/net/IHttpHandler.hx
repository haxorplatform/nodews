package nws.component.net;
import js.node.http.IncomingMessage;
import js.node.http.ServerResponse;

/**
 * Interface that describes a class that handles Http related callbacks.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
interface IHttpHandler 
{
	/**
	 * Callback called when a request arrives.
	 * @param	p_http
	 * @param	p_request
	 * @param	p_response
	 */
	function OnRequest(p_target:HttpComponent):Void;
	
	/**
	 * Callback called when the request has finished.
	 * @param	p_http
	 */
	function OnFinish(p_target:HttpComponent):Void;
}