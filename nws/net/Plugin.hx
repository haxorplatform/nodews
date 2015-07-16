package nws.net;
import js.Error;
import nws.service.BaseService;

/**
 * Base class for Http application plugins.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class Plugin
{

	/**
	 * Reference to the running Http application.
	 */
	public var application(get, never):HttpApplication;
	private function get_application():HttpApplication { return m_application; }
	private var m_application : HttpApplication;
	
	/**
	 * Creates a new plugin.
	 */
	public function new() { }
	
	/**
	 * Callback called when the plugin is loaded. The application is available.
	 */
	public function OnLoad():Void {	}
	
	/**
	 * Callback called before service.Execute()
	 */
	public function OnServiceBegin(p_service : BaseService):Void { }
	
	/**
	 * Callback called after service.Execute()
	 */
	public function OnServiceEnd(p_service : BaseService):Void { }
	
	/**
	 * Callback called when some error occurs in the application.
	 * @param	p_error
	 */
	public function OnError(p_error:Error):Void { }
	
}