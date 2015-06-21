![](http://i.imgur.com/zVuvoa8.png)
# NodeJS Webservices

### Overview

This framework wraps the **[Http API](http://nodejs.org/api/http.html)** of nodejs and offers a straightforward way to implement web services.  
It adds a layer of abstraction, allowing users to only focus on handling the data arrived from the Http Requests.

**I'm doing this library as helper for my main projects so it will evolve according to my needs**

### Installation

* Install **[FlashDevelop](http://www.flashdevelop.org/community/viewforum.php?f=11) (not obligatory)**
* Install and make available in the command line **[NodeJS](http://nodejs.org/)**
* Run `haxelib git hxnodejs https://github.com/HaxeFoundation/hxnodejs.git`
* Run `haxelib git nodews https://github.com/haxorplatform/nodews.git`


### Development

* Create a Haxe Javascript project.
* In the `main` method add:
```haxe
//Starts the Http Server in the port 8000
var server : HttpApplication = HttpApplication.Create(8000);
```
* Create a class `HelloWorldService`
```haxe
class HelloWorldService extends BaseService
{
	//Method is routed using the desired URL path and Http Methods
	@route("get,post","/my/path/")
    override public function MyWebservice()
    {
      trace("HelloWorldService "+session.data.user);
	  session.response.statusCode = 200;
      session.response.write("success");
	  session.response.end();
    }
	
	@route("get","/other/path/")
    override public function OtherWebservice()
    {
      trace("HelloWorldService "+session.data.user);
	  session.response.statusCode = 200;
      session.response.write("success");
	  session.response.end();
    }
}  
```
* Register the `HelloWorld` service in the `HttpApplication` associating it with the desired regular expression.
```haxe
server.Add("/[a-zA-Z0-9]/path/", HelloWorldService);
```
* Compile and run this example `node yourapp.js`
    * The server should be listening on port `8000`
* Open your browser and type:
	* `localhost:8000/my/path/?user=my_user`
	* `localhost:8000/other/path/?user=other_user`
* Check the browser response.
* Check the command line log.

### Build and Run

* The installations should make all necessary tools available.
* Develop your application and compile it in a `.js`
* Run `nodejs your_app.js` and you are done!
 
### Dependencies

* Some webservices you make will need extra nodejs packages:
    * `mongodb`
    * `mailserver`
    * `multiparty` (upload support for webservices)
	* `authom`
