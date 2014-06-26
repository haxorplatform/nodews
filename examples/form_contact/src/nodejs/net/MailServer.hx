package nodejs.net;
import js.Error;
import nodejs.fs.WriteStream;
import nodejs.net.MailServer.MailServerOption;
import nodejs.net.MailServer.MessageHeader;

/**
 * headers is an object ('from' and 'to' are required)
 * returns a Message object
 * you can actually pass more message headers than listed, the below are just the
 * most common ones you would want to use
 */
@:native("(require('emailjs').message)")
extern class MailMessage
{
	static var BUFFERSIZE : Int;
	
	var text : String;       					 // text of the email 
    var from : String;       					 // sender of the format (address or name <address> or "name" <address>)
    var to   : String;       					 // recipients (same format as above), multiple recipients are separated by a comma
    var cc   : String;       	 				 // carbon copied recipients (same format as above)
    var bcc  : String;   						 // blind carbon copied recipients (same format as above)
    var subject : String; 						 // string subject of the email
    var attachment : Array<MailAttachment>; 	 // one attachment or array of attachments
	
}

/**
 * 
 */
extern class MailServerOption
{
   var user     : String;   // username for logging into smtp 
   var password : String;	// password for logging into smtp
   var host     : String;   // smtp host
   var port     : Int;	   	// smtp port (if null a standard port number will be used)
   var ssl      : Bool;		// boolean or object {key, ca, cert} (if true or object, ssl connection will be made)
   var tls      : Bool;		// boolean or object (if true or object, starttls will be initiated)
   var timeout  : Int;		// max number of milliseconds to wait for smtp responses (defaults to 5000)
   var domain   : String;	// domain to greet smtp with (defaults to os.hostname)

}

/**
 * can be called multiple times, each adding a new attachment
 * one of these fields is required
 */
extern class MailAttachment
{
	
    var path   :String;   			// string to where the file is located
    var data   :String;				// string of the data you want to attach
    var stream : WriteStream;   	// binary stream that will provide attachment data (make sure it is in the paused state)
									// better performance for binary streams is achieved if buffer.length % (76*6) == 0
									// current max size of buffer must be no larger than Message.BUFFERSIZE     
    
	// optionally these fields are also accepted
    var type        : String;  					// string of the file mime type
    var name        : String;					// name to give the file as perceived by the recipient
    var alternative : Bool;						// if true, will be attached inline as an alternative (also defaults type='text/html')
    //var inline      : Bool;						// if true, will be attached inline
    var encoded     : Bool;						// set this to true if the data is already base64 encoded, (avoid this if possible)
    var headers     : Dynamic;					// object containing header=>value pairs for inclusion in this attachment's header
    var related     : Array<MailAttachment>;	// an array of attachments that you want to be related to the parent attachment
}

/**
 * 
 */
extern class MessageHeader
{
	//var message-id : String;
	
	var date : Date;
	
	var from : String;
	
	var to : String;
	
	var subject : String;
}

/**
 * 
 */
extern class MessageResponse
{
	var attachments : Array<MailAttachment>;
	var alternative : Bool;
	var header : MessageHeader;
	var content : String;
	var text : String;
}

/**
 * Handles the sending of emails
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
@:native("require('emailjs').server")
extern class MailServer
{
	/**
	 * connects to the server
	 * @param	options
	 */
	static function connect(options : MailServerOption):MailServer;
	
	/**
	 * message can be a smtp.Message (as returned by email.message.create)
	 * or an object identical to the first argument accepted by email.message.create
	 * callback will be executed with (err, message)
	 * either when message is sent or an error has occurred
	 * @param	message
	 * @param	callback
	 */
	function send(message:MailMessage, callback : Error->MessageResponse->Void):Void;
}