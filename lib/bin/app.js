(function () { "use strict";
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var Main = function() { };
Main.__name__ = ["Main"];
Main.main = function() {
};
var IMap = function() { };
IMap.__name__ = ["IMap"];
var Std = function() { };
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js.Boot.__string_rec(s,"");
};
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null;
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
Type.getClassName = function(c) {
	var a = c.__name__;
	return a.join(".");
};
Type.createInstance = function(cl,args) {
	var _g = args.length;
	switch(_g) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw "Too many arguments";
	}
	return null;
};
var haxe = {};
haxe.ds = {};
haxe.ds.StringMap = function() {
	this.h = { };
};
haxe.ds.StringMap.__name__ = ["haxe","ds","StringMap"];
haxe.ds.StringMap.__interfaces__ = [IMap];
haxe.ds.StringMap.prototype = {
	set: function(key,value) {
		this.h["$" + key] = value;
	}
	,get: function(key) {
		return this.h["$" + key];
	}
	,exists: function(key) {
		return this.h.hasOwnProperty("$" + key);
	}
	,__class__: haxe.ds.StringMap
};
var js = {};
js.Boot = function() { };
js.Boot.__name__ = ["js","Boot"];
js.Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else return o.__class__;
};
js.Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i = _g1++;
					if(i != 2) str += "," + js.Boot.__string_rec(o[i],s); else str += js.Boot.__string_rec(o[i],s);
				}
				return str + ")";
			}
			var l = o.length;
			var i1;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js.Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			return "???";
		}
		if(tostr != null && tostr != Object.toString) {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str2 = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str2.length != 2) str2 += ", \n";
		str2 += s + k + " : " + js.Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str2 += "\n" + s + "}";
		return str2;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js.Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js.Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js.Boot.__interfLoop(cc.__super__,cl);
};
js.Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js.Boot.__interfLoop(js.Boot.getClass(o),cl)) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
var nodejs = {};
nodejs.NodeJS = function() { };
nodejs.NodeJS.__name__ = ["nodejs","NodeJS"];
nodejs.NodeJS.get_dirname = function() {
	return __dirname;
};
nodejs.NodeJS.get_filename = function() {
	return __filename;
};
nodejs.NodeJS.require = function(p_lib) {
	return require(p_lib);
};
nodejs.NodeJS.get_process = function() {
	return process;
};
nodejs.NodeJS.setTimeout = function(cb,ms) {
	return setTimeout(cb,ms);
};
nodejs.NodeJS.clearTimeout = function(t) {
	return clearTimeout(t);
};
nodejs.NodeJS.setInterval = function(cb,ms) {
	return setInterval(cb,ms);
};
nodejs.NodeJS.clearInterval = function(t) {
	return clearInterval(t);
};
nodejs.NodeJS.assert = function(value,message) {
	require('assert')(value,message);
};
nodejs.NodeJS.get_global = function() {
	return global;
};
nodejs.NodeJS.resolve = function() {
	return require.resolve();
};
nodejs.NodeJS.get_cache = function() {
	return require.cache;
};
nodejs.NodeJS.get_extensions = function() {
	return require.extensions;
};
nodejs.NodeJS.get_module = function() {
	return module;
};
nodejs.NodeJS.get_exports = function() {
	return exports;
};
nodejs.NodeJS.get_domain = function() {
	return domain.create();
};
nodejs.NodeJS.get_repl = function() {
	return require('repl');
};
nodejs.ProcessEventType = function() { };
nodejs.ProcessEventType.__name__ = ["nodejs","ProcessEventType"];
nodejs.REPLEventType = function() { };
nodejs.REPLEventType.__name__ = ["nodejs","REPLEventType"];
nodejs.events = {};
nodejs.events.EventEmitterEventType = function() { };
nodejs.events.EventEmitterEventType.__name__ = ["nodejs","events","EventEmitterEventType"];
nodejs.fs = {};
nodejs.fs.FSWatcherEventType = function() { };
nodejs.fs.FSWatcherEventType.__name__ = ["nodejs","fs","FSWatcherEventType"];
nodejs.fs.FileLinkType = function() { };
nodejs.fs.FileLinkType.__name__ = ["nodejs","fs","FileLinkType"];
nodejs.fs.FileIOFlag = function() { };
nodejs.fs.FileIOFlag.__name__ = ["nodejs","fs","FileIOFlag"];
nodejs.fs.ReadStreamEventType = function() { };
nodejs.fs.ReadStreamEventType.__name__ = ["nodejs","fs","ReadStreamEventType"];
nodejs.fs.WriteStreamEventType = function() { };
nodejs.fs.WriteStreamEventType.__name__ = ["nodejs","fs","WriteStreamEventType"];
nodejs.http = {};
nodejs.http.HTTPMethod = function() { };
nodejs.http.HTTPMethod.__name__ = ["nodejs","http","HTTPMethod"];
nodejs.http.HTTPServerEventType = function() { };
nodejs.http.HTTPServerEventType.__name__ = ["nodejs","http","HTTPServerEventType"];
nodejs.stream = {};
nodejs.stream.ReadableEventType = function() { };
nodejs.stream.ReadableEventType.__name__ = ["nodejs","stream","ReadableEventType"];
nodejs.http.IncomingMessageEventType = function() { };
nodejs.http.IncomingMessageEventType.__name__ = ["nodejs","http","IncomingMessageEventType"];
nodejs.http.IncomingMessageEventType.__super__ = nodejs.stream.ReadableEventType;
nodejs.http.IncomingMessageEventType.prototype = $extend(nodejs.stream.ReadableEventType.prototype,{
	__class__: nodejs.http.IncomingMessageEventType
});
nodejs.http.MultipartFormEventType = function() { };
nodejs.http.MultipartFormEventType.__name__ = ["nodejs","http","MultipartFormEventType"];
nodejs.http.ServerResponseEventType = function() { };
nodejs.http.ServerResponseEventType.__name__ = ["nodejs","http","ServerResponseEventType"];
nodejs.http.URL = function() { };
nodejs.http.URL.__name__ = ["nodejs","http","URL"];
nodejs.http.URL.get_url = function() {
	if(nodejs.http.URL.m_url == null) return nodejs.http.URL.m_url = nodejs.NodeJS.require("url"); else return nodejs.http.URL.m_url;
};
nodejs.http.URL.get_qs = function() {
	if(nodejs.http.URL.m_qs == null) return nodejs.http.URL.m_qs = nodejs.NodeJS.require("querystring"); else return nodejs.http.URL.m_qs;
};
nodejs.http.URL.get_mp = function() {
	if(nodejs.http.URL.m_mp == null) return nodejs.http.URL.m_mp = nodejs.NodeJS.require("multiparty"); else return nodejs.http.URL.m_mp;
};
nodejs.http.URL.Parse = function(p_url) {
	var d = nodejs.http.URL.get_url().parse(p_url);
	return d;
};
nodejs.http.URL.ParseQuery = function(p_query,p_separator,p_assigment,p_max_keys) {
	if(p_max_keys == null) p_max_keys = 1000;
	if(p_assigment == null) p_assigment = "=";
	if(p_separator == null) p_separator = "&";
	if(p_query == null) return { };
	if(p_query == "") return { };
	return nodejs.http.URL.get_qs().parse(p_query,p_separator,p_assigment,{ maxKeys : p_max_keys});
};
nodejs.http.URL.ToQuery = function(p_target,p_separator,p_assigment) {
	if(p_assigment == null) p_assigment = "=";
	if(p_separator == null) p_separator = "&";
	if(p_target == null) return "null";
	return nodejs.http.URL.get_qs().stringify(p_target,p_separator,p_assigment);
};
nodejs.http.URL.ParseMultipart = function(p_request,p_callback,p_options) {
	var opt;
	if(p_options == null) opt = { }; else opt = p_options;
	var multipart = nodejs.http.URL.get_mp();
	var options = opt;
	var f = new multipart.Form(opt);
	if(p_callback == null) try {
		f.parse(p_request);
	} catch( e ) {
		if( js.Boot.__instanceof(e,Error) ) {
			console.log("URL> " + Std.string(e) + "\n\t" + e.stack);
		} else throw(e);
	} else try {
		f.parse(p_request,p_callback);
	} catch( e1 ) {
		console.log("!!! " + Std.string(e1));
	}
	return f;
};
nodejs.http.URL.Resolve = function(p_from,p_to) {
	return nodejs.http.URL.get_url().resolve(p_from,p_to);
};
nodejs.mongodb = {};
nodejs.mongodb.MongoAuthOption = function() {
	this.authMechanism = "MONGODB - CR";
};
nodejs.mongodb.MongoAuthOption.__name__ = ["nodejs","mongodb","MongoAuthOption"];
nodejs.mongodb.MongoAuthOption.prototype = {
	__class__: nodejs.mongodb.MongoAuthOption
};
nodejs.net = {};
nodejs.net.TCPServerEventType = function() { };
nodejs.net.TCPServerEventType.__name__ = ["nodejs","net","TCPServerEventType"];
nodejs.net.TCPSocketEventType = function() { };
nodejs.net.TCPSocketEventType.__name__ = ["nodejs","net","TCPSocketEventType"];
nodejs.stream.WritableEventType = function() { };
nodejs.stream.WritableEventType.__name__ = ["nodejs","stream","WritableEventType"];
var nws = {};
nws.SimpleServiceDaemon = function() { };
nws.SimpleServiceDaemon.__name__ = ["nws","SimpleServiceDaemon"];
nws.SimpleServiceDaemon.main = function() {
	console.log("Process> Starting WebServiceDaemon");
	nws.SimpleServiceDaemon.http = nws.net.HTTPServiceManager.Create(8000);
	nws.SimpleServiceDaemon.http.verbose = 0;
	var _g = 0;
	var _g1 = nodejs.NodeJS.get_process().argv;
	while(_g < _g1.length) {
		var a = _g1[_g];
		++_g;
		if(a.indexOf("-v") >= 0) nws.SimpleServiceDaemon.http.verbose = a.length - 1;
	}
	console.log("Process> Verbose Level [" + nws.SimpleServiceDaemon.http.verbose + "]");
	nodejs.NodeJS.get_process().on(nodejs.ProcessEventType.Exception,nws.SimpleServiceDaemon.OnError);
};
nws.SimpleServiceDaemon.OnError = function(p_error) {
	console.log("Process> [error] Uncaught[" + Std.string(p_error) + "]");
};
nws.net = {};
nws.net.HTTPServiceManager = function() {
	this.defaultService = this.service = new nws.service.BaseService(this);
	this.m_services = new haxe.ds.StringMap();
	this.server = (require('http')).createServer($bind(this,this.RequestHandler));
	this.server.on(nodejs.http.HTTPServerEventType.Connection,$bind(this,this.OnConnection));
	this.server.on(nodejs.http.HTTPServerEventType.Error,$bind(this,this.OnError));
	this.multipart = { };
	this.multipart.uploadDir = "uploads";
	this.verbose = 0;
};
nws.net.HTTPServiceManager.__name__ = ["nws","net","HTTPServiceManager"];
nws.net.HTTPServiceManager.Create = function(p_port) {
	if(p_port == null) p_port = 80;
	var s = new nws.net.HTTPServiceManager();
	s.Listen(p_port);
	return s;
};
nws.net.HTTPServiceManager.prototype = {
	Add: function(p_id,p_service_class) {
		this.m_services.set(p_id,p_service_class);
	}
	,Listen: function(p_port) {
		if(p_port == null) p_port = 80;
		this.Log("HTTP> Listening Port [" + p_port + "]");
		this.server.listen(p_port);
	}
	,RequestHandler: function(p_request,p_response) {
		this.request = p_request;
		this.response = p_response;
		this.method = p_request.method.toUpperCase();
		this.url = nodejs.http.URL.Parse(p_request.url);
		var service_id = this.url.pathname;
		var service_exists = this.m_services.exists(service_id);
		this.Log("HTTP> RequestHandler url[" + this.request.url + "] service[" + service_id + "] found[" + (service_exists == null?"null":"" + service_exists) + "] method[" + this.method + "] ip[" + this.request.socket.remoteAddress + ":" + this.request.socket.remotePort + "]",1);
		if(this.m_services.exists(service_id)) {
			var c = this.m_services.get(service_id);
			this.service = Type.createInstance(c,[this]);
		} else this.service = this.defaultService;
		this.service.OnInitialize();
		this.response.setHeader("content-type",this.service.content);
		if(this.service.enabled) this.OnRequest(); else {
			this.Log("HTTP> RequestHandler service[" + service_id + "] disabled.",1);
			if(this.response != null) this.response.end();
		}
	}
	,OnRequest: function() {
		var _g1 = this;
		var _g = this.method;
		switch(_g) {
		case nodejs.http.HTTPMethod.Get:
			var d = null;
			if(this.url.query != null) d = nodejs.http.URL.ParseQuery(this.url.query);
			this.OnGETRequest(this.request,this.response,d);
			this.OnRequestComplete();
			break;
		case nodejs.http.HTTPMethod.Post:
			var content_type = this.request.headers["content-type"];
			if(content_type.toLowerCase().indexOf("multipart") >= 0) try {
				this.ProcessMultipart(this.request,this.response);
			} catch( e ) {
				if( js.Boot.__instanceof(e,Error) ) {
					this.Log("HTTP> [error] OnRequest [" + Std.string(e) + "]");
					this.Log("\t" + e.stack,1);
					this.OnError(e);
				} else throw(e);
			} else {
				this.request.on(nodejs.http.IncomingMessageEventType.Data,function(data) {
					_g1.OnPOSTRequest(_g1.request,_g1.response,nodejs.http.URL.ParseQuery(data.toString()));
				});
				this.request.on(nodejs.http.IncomingMessageEventType.End,function() {
					_g1.OnRequestComplete();
				});
			}
			break;
		default:
			this.Log("HTTP> OnRequest Ignored method[" + this.method + "] url[" + this.request.url + "]",1);
			this.OnRequestComplete();
		}
	}
	,OnRequestComplete: function() {
		this.Log("HTTP> OnRequestComplete [" + Type.getClassName(Type.getClass(this.service)) + "] url[" + this.request.url + "]",1);
		this.service.OnExecute();
		this.response.end();
	}
	,OnPOSTRequest: function(p_request,p_response,p_data) {
		this.data = p_data;
	}
	,OnGETRequest: function(p_request,p_response,p_data) {
		this.data = p_data;
	}
	,ProcessMultipart: function(p_request,p_response) {
		var _g = this;
		this.Log("HTTP> ProcessMultipart",3);
		var d = { };
		var f = nodejs.http.URL.ParseMultipart(p_request,null,this.multipart);
		f.on(nodejs.http.MultipartFormEventType.Error,function(p_error) {
			_g.Log("HTTP> [error] ProcessMultiPart [" + Std.string(p_error) + "]");
			_g.OnError(p_error);
		});
		f.on(nodejs.http.MultipartFormEventType.Progress,function(l,t) {
			_g.Log("HTTP> Multipart Progress [" + l + "/" + t + "]",2);
		});
		f.on(nodejs.http.MultipartFormEventType.Field,function(p_key,p_value) {
			_g.Log("HTTP> \t" + p_key + " = " + p_value,3);
			d[p_key] = p_value;
		});
		f.on(nodejs.http.MultipartFormEventType.File,function(p_name,p_file) {
			_g.Log("HTTP> \t file[" + p_name + "]\n\t" + Std.string(p_file),3);
			d[p_name] = p_file;
		});
		f.on(nodejs.http.MultipartFormEventType.Close,function() {
			_g.OnPOSTRequest(p_request,p_response,d);
			_g.OnRequestComplete();
		});
	}
	,OnConnection: function(p_socket) {
		this.Log("HTTP> OnConnection ip[" + p_socket.remoteAddress + "]",2);
	}
	,OnError: function(p_error) {
		this.service.OnError(p_error);
		this.response.end();
	}
	,Log: function(p_message,p_level) {
		if(p_level == null) p_level = 0;
		if(p_level <= this.verbose) console.log(p_message);
	}
	,__class__: nws.net.HTTPServiceManager
};
nws.service = {};
nws.service.BaseService = function(p_server) {
	this.manager = p_server;
	this.content = "text/plain";
	this.code = 200;
	this.enabled = true;
};
nws.service.BaseService.__name__ = ["nws","service","BaseService"];
nws.service.BaseService.prototype = {
	OnInitialize: function() {
	}
	,OnExecute: function() {
	}
	,OnError: function(p_error) {
	}
	,__class__: nws.service.BaseService
};
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
String.prototype.__class__ = String;
String.__name__ = ["String"];
Array.__name__ = ["Array"];
var Int = { __name__ : ["Int"]};
var Dynamic = { __name__ : ["Dynamic"]};
var Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = { __name__ : ["Class"]};
var Enum = { };
nodejs.ProcessEventType.Exit = "exit";
nodejs.ProcessEventType.Exception = "uncaughtException";
nodejs.REPLEventType.Exit = "exit";
nodejs.events.EventEmitterEventType.NewListener = "newListener";
nodejs.events.EventEmitterEventType.RemoveListener = "removeListener";
nodejs.fs.FSWatcherEventType.Change = "change";
nodejs.fs.FSWatcherEventType.Error = "error";
nodejs.fs.FileLinkType.Dir = "dir";
nodejs.fs.FileLinkType.File = "file";
nodejs.fs.FileLinkType.Junction = "junction";
nodejs.fs.FileIOFlag.Read = "r";
nodejs.fs.FileIOFlag.ReadWrite = "r+";
nodejs.fs.FileIOFlag.ReadSync = "rs";
nodejs.fs.FileIOFlag.ReadWriteSync = "rs+";
nodejs.fs.FileIOFlag.WriteCreate = "w";
nodejs.fs.FileIOFlag.WriteCheck = "wx";
nodejs.fs.FileIOFlag.WriteReadCreate = "w+";
nodejs.fs.FileIOFlag.WriteReadCheck = "wx+";
nodejs.fs.FileIOFlag.AppendCreate = "a";
nodejs.fs.FileIOFlag.AppendCheck = "ax";
nodejs.fs.FileIOFlag.AppendReadCreate = "a+";
nodejs.fs.FileIOFlag.AppendReadCheck = "ax+";
nodejs.fs.ReadStreamEventType.Open = "open";
nodejs.fs.WriteStreamEventType.Open = "open";
nodejs.http.HTTPMethod.Get = "GET";
nodejs.http.HTTPMethod.Post = "POST";
nodejs.http.HTTPMethod.Options = "OPTIONS";
nodejs.http.HTTPMethod.Head = "HEAD";
nodejs.http.HTTPMethod.Put = "PUT";
nodejs.http.HTTPMethod.Delete = "DELETE";
nodejs.http.HTTPMethod.Trace = "TRACE";
nodejs.http.HTTPMethod.Connect = "CONNECT";
nodejs.http.HTTPServerEventType.Listening = "listening";
nodejs.http.HTTPServerEventType.Connection = "connection";
nodejs.http.HTTPServerEventType.Close = "close";
nodejs.http.HTTPServerEventType.Error = "error";
nodejs.http.HTTPServerEventType.Request = "request";
nodejs.http.HTTPServerEventType.CheckContinue = "checkContinue";
nodejs.http.HTTPServerEventType.Connect = "connect";
nodejs.http.HTTPServerEventType.Upgrade = "upgrade";
nodejs.http.HTTPServerEventType.ClientError = "clientError";
nodejs.stream.ReadableEventType.Readable = "readable";
nodejs.stream.ReadableEventType.Data = "data";
nodejs.stream.ReadableEventType.End = "end";
nodejs.stream.ReadableEventType.Close = "close";
nodejs.stream.ReadableEventType.Error = "error";
nodejs.http.IncomingMessageEventType.Data = "data";
nodejs.http.IncomingMessageEventType.Close = "close";
nodejs.http.IncomingMessageEventType.End = "end";
nodejs.http.MultipartFormEventType.Part = "part";
nodejs.http.MultipartFormEventType.Aborted = "aborted";
nodejs.http.MultipartFormEventType.Error = "error";
nodejs.http.MultipartFormEventType.Progress = "progress";
nodejs.http.MultipartFormEventType.Field = "field";
nodejs.http.MultipartFormEventType.File = "file";
nodejs.http.MultipartFormEventType.Close = "close";
nodejs.http.ServerResponseEventType.Close = "close";
nodejs.http.ServerResponseEventType.Finish = "finish";
nodejs.mongodb.MongoAuthOption.MONGO_CR = "MONGODB - CR";
nodejs.mongodb.MongoAuthOption.GSSAPI = "GSSAPI";
nodejs.net.TCPServerEventType.Listening = "listening";
nodejs.net.TCPServerEventType.Connection = "connection";
nodejs.net.TCPServerEventType.Close = "close";
nodejs.net.TCPServerEventType.Error = "error";
nodejs.net.TCPSocketEventType.Connect = "connect";
nodejs.net.TCPSocketEventType.Data = "data";
nodejs.net.TCPSocketEventType.End = "end";
nodejs.net.TCPSocketEventType.TimeOut = "timeout";
nodejs.net.TCPSocketEventType.Drain = "drain";
nodejs.net.TCPSocketEventType.Error = "error";
nodejs.net.TCPSocketEventType.Close = "close";
nodejs.stream.WritableEventType.Drain = "drain";
nodejs.stream.WritableEventType.Finish = "finish";
nodejs.stream.WritableEventType.Pipe = "pipe";
nodejs.stream.WritableEventType.Unpipe = "unpipe";
nodejs.stream.WritableEventType.Error = "error";
Main.main();
})();
