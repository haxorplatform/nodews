package nws;
import js.Error;
import nws.component.Component;

/**
 * Base class for an element that will contains components responsibles for this application features.
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:allow(nws)
class Entity extends Resource
{
	/**
	 * Reference to the running application.
	 */
	public var app(get, never):Application;
	private function get_app():Application { return Application.instance; }
	
	/**
	 * Returns the number of children in this entity.
	 */
	public var count(get, never):Int;
	private function get_count():Int { return m_children.length; }
	
	/**
	 * Flag that indicates this controller is enabled. If its value is changed, all hierarchy is affected by the new value.
	 */
	public var enabled(get, set):Bool;
	private function get_enabled():Bool { return m_enabled; }
	private function set_enabled(v:Bool):Bool { m_enabled = v; for (c in m_components) c.enabled = v; for (e in m_children) e.enabled = v; return v; }
	private var m_enabled : Bool;
	
	/**
	 * Internals
	 */
	private var m_children		 : Array<Entity>;
	private var m_components	 : Array<Component>;
	
	/**
	 * Creates a new instance.
	 * @param	p_name
	 */	
	public function new(p_name:String="") 
	{		
		super(p_name);
		m_children = [];
		m_components = [];
		m_enabled = true;
	}
	
	/**
	 * Returns a flag indicating a given entity is contained in the hierarchy.
	 * @param	p_entity
	 * @return
	 */
	public function Contains(p_entity:Entity):Bool { return m_children.indexOf(p_entity) >= 0; }
	
	/**
	 * Creates a new child entity with a name and adds the list of components in it.
	 * @param	p_name
	 * @param	p_components
	 */
	public function CreateChild(p_name:String, p_components : Array <Class<Component>>=null):Entity
	{
		var cl : Array<Class<Component>> = p_components == null ? [] : p_components;
		var e : Entity = new Entity(p_name);
		for (cc in cl) e.AddComponent(cc);
		return e;
	}
	
	/**
	 * Adds a child entity in this instance.
	 * @param	p_entity
	 */
	public function AddChild(p_entity:Entity):Void
	{
		if (Contains(p_entity)) return;
		m_children.push(p_entity);
	}
	
	/**
	 * Removes a child entity from this instance.
	 * @param	p_entity
	 */
	public function RemoveChild(p_entity:Entity):Void
	{
		if (!Contains(p_entity)) return;
		m_children.remove(p_entity);
	}
	
	/**
	 * Returns a children in a given index.
	 * @param	p_index
	 * @return
	 */
	public function GetChild(p_index:Int):Entity { return p_index < 0 ? null : (p_index >= m_children.length ? null : m_children[p_index] ); }
	
	/**
	 * Returns a child by its name.
	 * @param	p_name
	 * @return
	 */
	public function GetChildByName(p_name:String):Entity { for (e in m_children) if (e.name == p_name) return e; return null; }
	
	/**
	 * Finds the first entry which matches the path string.
	 * @param	p_path
	 * @return
	 */
	public function Find(p_path : String) : Entity
	{
		var pl : Array<String> = p_path.split(".");
		if (pl.length <= 0) return null;
		var e : Entity = this;
		while (pl.length > 0)
		{
			var n : String = pl.shift();
			e = e.GetChildByName(n);
			if (e == null) return null;
		}
		return e;
	}
	
	/**
	 * Traverses the Entity's hierarchy stopping the recursion when false is returned.
	 * @param	p_callback
	 */
	public function Traverse(p_callback : Entity->Bool):Void
	{
		if (p_callback != null) if (!p_callback(this)) return;
		for (e in m_children)
		{
			e.Traverse(p_callback);
		}
	}
	
	/**
	 * Instantiates and add a new component in this entity.
	 * @param	p_type
	 * @return
	 */
	public function AddComponent(p_type : Class<Component>):Component
	{
		var c : Component = Type.createInstance(p_type,[]);
		c.m_entity = this;
		c.OnCreate();
		m_components.push(c);
		return c;
	}
	
	/**
	 * Returns the first occurence of a give component.
	 * @param	p_type
	 * @return
	 */
	public function GetComponent(p_type : Class<Component>):Component
	{
		for (c in m_components) if (Std.is(c, p_type)) return c;
		return null;	
	}
	
	/**
	 * Returns all occurrences of a component of given type.
	 * @param	p_type
	 * @return
	 */
	public function GetComponents(p_type : Class<Component>):Array<Component>
	{
		var l : Array<Component> = [];
		for (c in m_components) if (Std.is(c, p_type)) l.push(c);
		return l;
	}
	
	/**
	 * Returns the first occurrence of a given component inside this entity's hierarchy.
	 * @param	p_type
	 * @return
	 */
	public function GetComponentInChildren(p_type : Class<Component>):Component
	{
		var res : Component = null;
		Traverse(function(e:Entity):Bool
		{
			if (res != null) return false;
			if (e == this)   return true;
			res = e.GetComponent(p_type);
			return res==null;
		});
		return res;
	}
	
	/**
	 * Returns all occurrences of a given component in this entity's hierarchy.
	 * @param	p_type
	 * @return
	 */
	public function GetComponentsInChildren(p_type : Class<Component>):Array<Component>
	{
		var l : Array<Component> = [];
		Traverse(function(e:Entity):Bool
		{
			if (e == this) return true;
			for (c in e.m_components) if (Std.is(c, p_type)) l.push(c);
			return true;
		});
		return l;
	}
	
	/**
	 * Emits a notification for this controller components and hierarchy.
	 * @param	p_path
	 * @param	p_event
	 * @param	p_data
	 */
	public function Notify(p_path:String, p_event:String, p_data:Dynamic):Void
	{
		for (c in m_components) if(c.enabled)c.OnNotify(p_path, p_event, p_data);
		for (e in m_children) e.Notify(p_path, p_event, p_data);
	}
	
	/**
	 * Destroy this instance.
	 */
	override public function Destroy():Void
	{		
		while (m_components.length > 0) m_components[0].Destroy();
		for (e in m_children) e.Destroy();
		super.Destroy();
	}
	
	/**
	 * Throws an error and notifies all entities in the application.
	 * @param	p_error
	 * @param	p_status_code
	 */
	override public function Throw(p_error:Error,p_data:Dynamic=null):Void
	{	
		if(m_components!=null)for (c in m_components) c.OnError(p_error,p_data);
		if(m_children!=null)for (e in m_children) e.Throw(p_error,p_data);
	}
	
		
}