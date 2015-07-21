package nws.component;
import js.Error;
import nws.core.Controller;
import nws.core.Entity;

/**
 * Base class that implements atomic features only related to their scope.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class Component extends Entity
{
	/**
	 * Reference to the entity that owns this component.
	 */
	public var controller(get, never):Controller;
	private function get_controller():Controller { return m_controller; }
	private var m_controller : Controller;
	
	/**
	 * Flag that indicates this component is enabled and will execute its callbacks.
	 */
	public var enabled(get,set):Bool;
	private function get_enabled():Bool { return m_enabled; }
	private function set_enabled(v:Bool):Bool { return m_enabled=v; }
	private var m_enabled : Bool;
	
	/**
	 * Reference to the running application.
	 */
	public var application(get, never):Application;
	private function get_application():Application { return controller.application; }
	
	/**
	 * Returns this component's entity name.
	 */	
	override private function get_name():String { return controller.name; }
	
	/**
	 * Internal CTOR.
	 */
	private function new()
	{
		super("");
		m_enabled = true;
	}
	
	
	/**
	 * Destroys this component and removes it from its entity container.
	 */
	override public function Destroy():Void
	{
		m_controller.m_components.remove(this);
		super.Destroy();
	}
	
	/**
	 * Throws an error and notifies all entities in the application.
	 * @param	p_error
	 * @param	p_status_code
	 */
	override public function Throw(p_error:Error,p_data:Dynamic=null):Void
	{	
		controller.Throw(p_error, p_data);
	}
	
	/**
	 * Logging method that accept messages and their verbose level.
	 * @param	p_message
	 * @param	p_level
	 */
	inline public function Log(p_message:Dynamic, p_level :Int = 0):Void
	{
		if (p_level <= application.verbose) untyped console.log(GetTypeName()+">",p_message);
	}
	
	/**
	 * Callback called when the component is created and the entity instance is available.
	 */
	public function OnCreate():Void { }
	
	/**
	 * Callback called when a notification is issued in the controller or controller's hierarchy.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function OnNotify(p_path:String,p_event:String,p_data : Dynamic):Void {}
		
	/**
	 * Callback called when some error was thrown in the entity itself or higher hierarchy.
	 * @param	p_error
	 */
	public function OnError(p_error:Error,p_data:Dynamic):Void { }
}