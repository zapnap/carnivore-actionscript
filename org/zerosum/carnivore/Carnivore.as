import mx.utils.Delegate;
import mx.events.EventDispatcher;
import org.zerosum.carnivore.Packet;

/**
 * 	A Carnivore Client Library for Flash/AS2.0
 * 	
 *  @author nap@zerosum.org
 * 	@version 0.3.1/05.11.12
 * 
 * 	Based on the original Carnivore Client Object for Flash
 *  by Brian J. Hall and Jeffrey Crouse (v0.2)
 * 
 * 	This program is free software; you can redistribute it and/or modify
 * 	it under the terms of the GNU General Public License as published by
 * 	the Free Software Foundation; either version 2 of the License, or
 * 	(at your option) any later version.
 * 
 * 	This program is distributed in the hope that it will be useful
 * 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 * 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * 	GNU General Public License for more details.
 * 
 * 	You should have received a copy of the GNU General Public License
 * 	along with this program; if not, write to the Free Software
 * 	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */
class org.zerosum.carnivore.Carnivore {

	private var numPackets:Number = 0;
	private var state:String = "disconnected";
	private var ip:String = null;
	private var port:Number = 6667;
	private var channel:String = "minivore";
	private var debug:Boolean = false;
	
	private var intervalId:Number;
	private var socket:XMLSocket;
	
	// the next three functions are required for event dispatching
	// (included here for compiler checking, but provided by EventDispatcher)
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	
	/**
	 *	Constructor
	 *
	 *	@param	debug		Set debug mode to true (defaults to false)
	 */
	public function Carnivore(debug:Boolean) {		
		if (debug) this.debug = true;

		this.socket = new XMLSocket();
		
		// initialize the event dispatcher
		EventDispatcher.initialize(this);

		if (debug) trace("[carnivore] Client initialized");
	}
	
	/**
	 * 	Returns current server state
	 */
	public function connected():Boolean {
		if (this.state != "disconnected") { 
			return true;
		} else {
			return false;
		}
	}

	/**
	 * 	Connect to the Carnivore service
	 * 
	 * 	@param	ip			IP address of the Carnivore service
	 * 	@param	port		Port number
	 * 	@param	channel		Channel name (minivore, carnivore, hexigore)
	 */
	public function connect(ip:String, port:Number, channel:String):Boolean {
		if (this.debug) trace("[carnivore] Connecting...");

		this.ip = ip;
		this.port = port;
		this.channel = channel;

		// delegate responsibility for XMLSocket onConnect and onData callbacks
		// to the appropriate handlers (note how we handle scope here)
		this.socket.onConnect = Delegate.create(this, socketConnectHandler);
		this.socket.onData = Delegate.create(this, socketDataHandler);

		// connect the XMLSocket, then onConnect will do the rest
		this.state = "connecting";
		return this.socket.connect(this.ip, this.port);
	}
	
	/**
	 * 	Forces client timeout if a join does not succeed during a set interval
	 */
	private function joinTimeout():Void {
		if (this.state != "data") {
			if (this.debug) trace("[carnivore] Join operation timed out");
			this.close();
		} else {
			clearInterval(this.intervalId);
		}
	}

	/**
	 * 	Socket Connect callback handler
	 */
	private function socketConnectHandler(ok:Object):Void {
		if (ok) {
			if (this.debug) trace("[carnivore] Connection established");
			this.state = "join";
			this.socket.send("JOIN #" + this.channel + "\n");	// ??
			if (this.debug) trace("[carnivore] Joining #" + this.channel + " channel");
			this.intervalId = setInterval(this, "joinTimeout", 1000);
		} else {
			if (this.debug) trace("[carnivore] Error: Could not connect to server");
			
			// return a data packet to tell client that we've disconnected
			var newPacket:Packet = new Packet(null);				
			dispatchEvent({target:this, type:'onPacket', packet: newPacket})

			this.state = "disconnected";
		}
	}

	/** * 	Socket Data callback handler */ 
	private function socketDataHandler(raw:Object):Void { switch(this.state) {

			// received data (packets) from Carnivore
	 			case "data": var part = raw.split(" ", 5);

				// make sure this is actual Carnivore data
		 			//if (part[0].substring(0, 13) == ":CarnivorePE:") { 
		 			var id:Number = this.numPackets++;;

					// parse the date string
			 		var t:String = part[0].split(":"); 
					var time:Date = new Date(); 
					time.setHours(t[0]); 
					time.setMinutes(t[1]); 
					time.setSeconds(t[2]); 
					time.setMilliseconds(t[3]);

					if (this.debug) trace("[carnivore] Packet " + id + " received at " + time);				

					var sIpAndPort:String	= part[1].split(":");
			 		var sIP:String = sIpAndPort[0];	
			 		var sPort:Number 			= parseInt(sIpAndPort[1]);

					var rIpAndPort:String	= part[3].split(":");
					var rIP:String 				= rIpAndPort[0];	
					var rPort:Number 			= parseInt(rIpAndPort[1]);
					
					var content:String = raw.slice(part.join(" ").length);
					//var content = part[5];
				
					if (this.debug) {
						trace("\tSender: " + sIP + ", Port: " + sPort);
						trace("\tReceiver: " + rIP + ", Port: " + rPort);
						if (this.channel != "minivore") trace("\tPacket: " + content);
					}

					// create packet object and broadcast it to all our listeners
					var newPacket:Packet = new Packet(id, time, sIP, sPort, rIP, rPort, content, String(raw));				
					dispatchEvent({target:this, type:'onPacket', packet: newPacket})

				//} else if (this.debug) trace("[carnivore] Received invalid packet");
			break;

			// channel join confirmation
			case "join":
				if(raw.substring(0,6)  == "JOINED") {
					if (this.debug) { 
						trace("[carnivore] Join successful.");
						trace("[carnivore] Ready to receive packets");
					}
					this.state = "data";

				} else {
					// invalid packet?
				}
				break;
		}
	}

	/**
	 *	Closes connection to the Carnivore service and cleans up
	 */
	public function close():Void {
		if (this.debug) trace("[carnivore] Closed connection");
		if (this.intervalId) clearInterval(this.intervalId);
		this.socket.close();
		this.state = "disconnected";
		// TODO: probably more cleanup here
	}
	
	/*
	 * 	Destroys the Carnivore instance
	 */ 
	public function destroy():Void {
		delete this;
	}
}
