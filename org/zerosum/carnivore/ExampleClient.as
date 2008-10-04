import org.zerosum.carnivore.*;
import mx.utils.Delegate;
import mx.controls.scrollClasses.ScrollBar;

/**
 *	A slightly more sophisticated (example) Carnivore Client (subclasses MovieClip)
 * 
 *	This demonstrates how to implement the CarnivoreListener if you need to 
 * 	subclass another object instead of extending or rewriting SimpleClient. 
 * 	In this case, we demonstrate how to inherit from MovieClip and implement
 * 	CarnivoreListener.
 * 
 * 	It's worth noting that another (probably better) way to achieve this same 
 * 	effect would be to rewrite or extend SimpleClient, using composition for 
 *	the MovieClip elements. This is included just as an example (since you might
 *  be subclassing something other than MovieClip, after all!)
 * 
 */
class org.zerosum.carnivore.ExampleClient extends MovieClip implements CarnivoreListener {
	private var server:Carnivore;	// not really the "server" but a server interface
	private var packets:Array;		// packet array
	
	private var host_ip:String = "127.0.0.1";
	private var host_port:Number = 6667;
	private var host_channel:String = "carnivore";
	
	public var traffic_txt:TextField;
	public var traffic_scroller:ScrollBar;
	public var host_ip_txt:TextField;
	public var host_port_txt:TextField;
	public var host_channel_txt:TextField;
	public var connect_btn:MovieClip;
	
	public function CarnivoreClient() {
		//
	}
	
	/**
	 * 	Create the Carnivore Client
	 * 
	 * 	@param	name		Name for the new Carnivore Client MovieClip
	 * 	@param	target		Target Movie to attach Carnivore Client to
	 * 	@param	depth		Depth of new Carnivore Client MovieClip
	 * 	@param	x			Horizontal (x) location of Carnivore Client MovieClip
	 * 	@param	y			Vertical (y) location of Carnivore Client MovieClip
	 * 	@param 	debug		Turn debugging on/off
	 */
	public static function createCarnivore(name:String, target:MovieClip, depth:Number, x:Number, y:Number, debug:Boolean):ExampleClient {
		trace("[carnivore-client] Started client.");
		var c:ExampleClient = ExampleClient(target.attachMovie("Carnivore_Symbol", name, depth));
		c.buildUI();
		c.init(x, y);
		return c;
	}
	
	/**
	 * 	Initialize the Carnivore Client
	 * 
	 * 	@param	x			Horizontal (x) location
	 * 	@param	y			Vertical (y) location
	 */
	public function init(x:Number, y:Number, debug:Boolean):Void {
		this._x = x;
		this._y = y;
		
		if (debug != true) debug = false;
		this.server = new Carnivore(debug);
		this.packets = new Array();
		
		this.host_ip_txt.text = this.host_ip;
		this.host_port_txt.text = this.host_port.toString();
		this.host_channel_txt.text = this.host_channel;
		
		// add the event listener (listeners must subscribe to onPacket event)
		server.addEventListener('onPacket', Delegate.create(this, onPacket));
	}
	
	/**
	 * 	Build Client User Interface
	 */
	public function buildUI():Void {
		var thisClient:ExampleClient = this;
		
		this.traffic_scroller._visible = false;
		
		// connect button
		this.connect_btn.onPress = function() { 
			if (!thisClient.server.connected()) {
				this.gotoAndPlay("connected");
				thisClient.host_ip = thisClient.host_ip_txt.text;
				thisClient.host_port = Number(thisClient.host_port_txt.text);
				thisClient.host_channel = thisClient.host_channel_txt.text;
				if (!thisClient.connect()) this.gotoAndPlay("disconnected");
			} else {
				this.gotoAndPlay("disconnected");
				thisClient.close();
			}
		};
	}
	
	/**
	 * 	Connect to the Carnivore service
	 * 
	 * 	@param	host_ip			IP address of Carnivore service
	 * 	@param	host_port		Port number of Carnivore service
	 * 	@param	host_channel	Channel name to connect to (minivore, hexivore, carnivore)
	 */
	public function connect(host_ip:String, host_port:Number, host_channel:String):Boolean {
		trace("[carnivore-client] Connecting...");
		if (host_ip) this.host_ip = host_ip;
		if (host_port) this.host_port = host_port;
		if (host_channel) this.host_channel = host_channel;

		return server.connect(this.host_ip, this.host_port, this.host_channel);
	}
	
	/**
	 * 	Disconnect from the Carnivore service
	 */
	public function close() {
		trace("[carnivore-client] Disconnected.");
		this.connect_btn.gotoAndPlay("disconnected");
		server.close();
	}
	
	/**
	 * 	Destroy the client and clean up
	 */
	public function destroy() {
		server.removeEventListener(this);
		delete this;
	}
	
	/**
	 *	Triggered when Carnivore receives new data
	 */
	public function onPacket(e:Object):Void {
		var packet:Packet = Packet(e.packet);
		
		// null ID means a connect failure or disconnect
		if (packet.getId() == null) {
			this.close();
			return;
		}
		
		this.packets.push(packet.getContent());
		trace("[carnivore-client] received packet #" + packet.getId());
		
		this.traffic_txt.text += packet.getId() + ". Sent at " + packet.getTime().getHours() + ":" + packet.getTime().getMinutes() + ":" + packet.getTime().getSeconds();
		this.traffic_txt.text += " From " + packet.getSender().ip + " Port " + packet.getSender().port;
		this.traffic_txt.text += " To " + packet.getReceiver().ip + " Port " + packet.getReceiver().port + "\n";
		this.traffic_txt.text += "\t\tPacket: " + packet.getContent() + "\n";
		this.traffic_scroller._visible = (this.traffic_txt.maxscroll > 1);
	}
}