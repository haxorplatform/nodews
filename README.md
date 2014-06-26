![](http://i.imgur.com/zVuvoa8.png)
# NodeJS Webservices

### Overview

This framework wraps the **[HTTP API](http://nodejs.org/api/http.html)** of nodejs and offers a straightforward way to implement web services.  
It adds a layer of abstraction, allowing users to only focus on handling the data arrived from the requests `POST` and/or `GET`.


![workflow.png](https://bitbucket.org/repo/4MbbzR/images/3818944778-workflow.png)

**I'm doing this library as helper for my main projects so it will evolve according to my needs**

### Installation

* Install **[FlashDevelop](http://www.flashdevelop.org/community/viewforum.php?f=11) (not obligatory)**
* Install and make available in the command line **[NodeJS](http://nodejs.org/)**
* Run `haxelib install nodehx`
* Run `haxelib install nodews`


### Development

* Create a Haxe Javascript project.
* In the `main` method add:
```
//Starts the HTTP Server in the port 8000
var http : HTTPServiceManager = HTTPServiceManager.Create(8000);
```
* Create a class `HelloWorldService`
```

class HelloWorldService extends BaseService
{
    override public function OnExecute()
    {
      trace("HelloWorldService "+manager.data.user);
      manager.response.write("success");
    }
}  
```
* Register the `HelloWorld` service in the `HTTPServiceManager`.
```
http.Add("/helloworld/", HelloWorldService);
```
* Compile and run this example `node yourapp.js`
    * The server should be listening on port `8000`
* Open your browser and type `localhost:8000/helloworld/?user=test_user`
* Check the browser response.
* Check the command line log.

### Examples

* There is FlashDevelop projects with examples in the `examples` folder.

### Build and Run

* The installations should make all necessary tools available.
* Develop your application and compile it in a `.js`
* Run `nodejs your_app.js` and you are done!
 
### Dependencies

* Some webservices you make will need extra nodejs packages: **(some examples)**
    * `mongodb`
    * `mailserver`
    * `multiparty` (upload support for webservices)
