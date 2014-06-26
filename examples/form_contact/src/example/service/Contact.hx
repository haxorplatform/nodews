package example.service;
import haxe.Json;
import js.Error;
import nodejs.fs.File;
import nodejs.http.URL;
import nodejs.net.MailServer;
import nws.service.BaseService;

/**
 * Contact data from the form.
 */
extern class ContactData
{
	var name    : String;
	
	var email   : String;
	
	var subject : String;
	
	var message : String;
}

/**
 * Operation status enumeration.
 */
class ContactStatus
{
	/**
	 * 
	 */
	static public var Success 	 : String = "success";
	
	/**
	 * 
	 */
	static public var Error		 : String = "error";	
	
	/**
	 * 
	 */
	static public var InvalidEmail	 : String = "invalid_email";	
	
	/**
	 * 
	 */
	static public var InvalidName	 : String = "invalid_name";	
	
	/**
	 * 
	 */
	static public var InvalidContent : String = "invalid_content";	
}

/**
 * Service that receives the user contact data and sends an email to the mail target
 * @author Eduardo Pons - eduardo@thelaborat.org
 */
class Contact extends BaseService
{
	
	/**
	 * 
	 */
	override public function OnInitialize():Void 
	{
		content = "application/json";
	}
	
	/**
	 * When the webpage  /contact is processed by the manager, this method is called after all data is ready.
	 */
	override public function OnExecute():Void 
	{	
		var resp : Dynamic = { };
		var status : String = ContactStatus.Error;
		
		manager.response.setHeader("Access-Control-Allow-Origin", "*");
		
		if (manager.data == null)
		{
			resp.success = false;					
			resp.error   = 1;
			resp.message = "No Data.";
		}
		else
		{		
			var mode :String 	= manager.data.mode == null ? "contact" : manager.data.mode;
			
			manager.Log("Contact> mode[" + mode+"]", 2);
			
			switch(mode)
			{
				case "contact":
					status = SendContact(manager.data);	
			}
			
			resp.success = false;
			resp.error   = 1;
			
			switch(status)
			{
				case ContactStatus.Success:
					resp.success = true;
					resp.error   = 0;
					resp.message = "Contact Sent!";					
				case ContactStatus.Error:		   resp.message = "Unknown Error.";					
				case ContactStatus.InvalidName:    resp.message = "Invalid Name.";				
				case ContactStatus.InvalidEmail:   resp.message = "Invalid Email.";				
				case ContactStatus.InvalidContent: resp.message = "Invalid Content.";
			}
		}
		
		var json_resp : String = Json.stringify(resp);
				
		manager.response.write(json_resp);
	}
	
	public function SendContact(p_data:ContactData):String
	{		
		if (p_data == null) return ContactStatus.Error;
		
		var c_name    : String = p_data.name    == null ? ""	 : p_data.name;
		var c_email   : String = p_data.email   == null ? ""     : p_data.email;
		var c_subject : String = p_data.subject == null ? ""     : p_data.subject;
		var c_message : String = p_data.message == null ? ""     : p_data.message;
		
		if (c_name == "") return ContactStatus.InvalidName;
		
		var email_regexp : EReg = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?/i;
		
		if (!email_regexp.match(c_email)) return ContactStatus.InvalidEmail;
		
		if (c_message == "") return ContactStatus.InvalidContent;
		
		if (c_subject == "") c_subject = "Contact " + Date.now().toString();
		
		manager.Log("Contact> Sent name[" + c_name+"] mail[" + c_email + "] subject[" + c_subject + "] content[" + c_message.substr(0, 10) + "...]");
		
		var esopt : MailServerOption = cast { };
		esopt.ssl 	   = true;
		esopt.host 	   = "smtp.gmail.com";
		esopt.user 	   = "YOUR_EMAIL_USER";
		esopt.password = "YOUR_EMAIL_PASSWORD";
		esopt.timeout  = 20000;
		
		var msg : MailMessage = cast { };
		msg.from = "Contact";
		msg.to	 = "TARGET@EMAIL.COM";
		msg.subject = "[contact] "+c_subject;
		msg.text 	= c_message;
		msg.text += "\n\n";
		msg.text += "From: "+c_name+" - "+c_email;
		
		MailServer.connect(esopt).send(msg, function(p_error:Error, p_message:MessageResponse):Void
		{
			if (p_error != null)
			{
				manager.Log("Contact> Mail Error ["+p_error+"]");
			}
			else
			{
				manager.Log("Contact> Mail from["+msg.from+"] Sent!");
			}
		});
		
		return ContactStatus.Success;
	}
	
}