
=== nodews ===

	This framework wraps the HTTP API of nodejs and offer a straightforward way
to implement web services.
	In the nodejs application, just call:
	
	var http : HTTPServiceManager = HTTPServiceManager.Create(port); //Creates the manager and start to listen 'port'
	http.verbose = 4; //Makes it log everything.
	
	http.Add("user/register/",YourUserRegisterService); //class YourUserRegisterService extends BaseService { override function OnExecute():Void {} }
	
	The user only needs to extend the BaseService class, read the 'manager.data' object and
execute the desired actions on the 'OnExecute' callback.
	You can then combine it with IO in the server HD or use any DB library out there.

-- I'm doing this library as helper for my main projects so it will evolve according to my needs --

=== Dependencies ===

 - This library uses [nodehx] to read the class bindings of nodejs.
 
=== Contact ===

Any doubts and/or suggestions and maybe complains:

[author]   Eduardo Pons - eduardo@thelaborat.org
[twitter]  www.twitter.com/EduardoDias
[twitter]  www.twitter.com/HaxorEngine

