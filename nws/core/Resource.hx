package nws.core;
import haxe.rtti.Meta;
import js.Error;
import nws.component.Component;

/**
 * Class that describes a metadata instance.
 */
extern class MetaData
{
	var field : String;	
	var data  : Dynamic;
}

/**
 * Base class for all instances in the framework.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class Resource
{	
	/**
	 * Entity's name.
	 */
	public var name(get, set):String;
	private function get_name():String { return m_name; }
	private function set_name(v:String):String { return m_name = v; }
	private var m_name : String;
	
	/**
	 * Flag that indicates this component was destroyed.
	 */
	public var destroyed(get, never):Bool;
	private function get_destroyed():Bool { return m_destroyed; }
	private var m_destroyed		 : Bool;
	
	/**
	 * Internals
	 */
	private var m_type_name_full : String;
	private var m_type_name      : String;
	private var m_type		     : Class<Resource>;
	
	/**
	 * Array of metadata of this instance.
	 */
	public var metadata(get, never) : Array<MetaData>;
	private function get_metadata():Array<MetaData>
	{
		if (m_metadata != null) return m_metadata;
		var ml : Array<Dynamic> = m_metadata = [];
		
		//fetches the RTTI and execute the functions		
		var c : Class<Resource> 		  = Type.getClass(this);				
		var cl : Array<Class<Resource>> = [];
		while (c != null) { cl.push(c); c = cast Type.getSuperClass(c); }
		cl.pop(); 	  //Removes Entity because it has no routes
		cl.reverse(); //Make it start in base classes and go up.
		for (it in cl)
		{
			var d : Array<Dynamic> = cast Meta.getFields(it);
			untyped __js__ ("for (var f in d) { var md = { field: f, data: d[f]==null ? {} : d[f] }; ml.push(md); }"); 
		}
		return m_metadata;
	}
	private var m_metadata : Array<MetaData>;
	
	
	
	/**
	 * Creates a new instance.
	 * @param	p_name
	 */	
	public function new(p_name:String="") 
	{		
		m_type = Type.getClass(this);
		m_type_name_full = Type.getClassName(m_type);
		m_type_name		 = m_type_name_full.split(".").pop();
		m_name = p_name == "" ? m_type_name+Std.int(Math.random() * 0xffffff) : p_name;				
		m_destroyed = false;
	}
	
	/**
	 * Destroy this instance.
	 */
	public function Destroy():Void
	{	
		OnDestroy();
		m_destroyed = true;
	}
	
	/**
	 * Callback called when this resource is destroyed.
	 */
	public function OnDestroy():Void { }
	
	/**
	 * Throws an error.
	 * @param	p_error
	 * @param	p_status_code
	 */
	public function Throw(p_error:Error,p_data:Dynamic=null):Void {	}
	
	/**
	 * Returns this instance's class.
	 * @return
	 */
	public function GetType():Class<Resource> { return m_type; }
	
	/**
	 * Returns this instance class name.
	 * @return
	 */
	public function GetTypeName():String { return m_type_name; }
	
	/**
	 * Returns this instance type name including the package path.
	 * @return
	 */
	public function GetTypeNameFull():String { return m_type_name_full; }
	
	
}