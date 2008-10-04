import org.zerosum.carnivore.*;
import mx.utils.Delegate;
import mx.controls.UIScrollBar;

/**
 *	A Simple Carnivore Client (uses composition for the MovieClip elements)
 * 
 *	Extend this class or rewrite it depending on the flexibility desired
 *
 */
class org.zerosum.carnivore.SimpleClient implements CarnivoreListener {
	private var server:Carnivore;	// not really the "server" but a server interface
	private var packets:Array;		// packet array
	
	private var host_ip:String = "127.0.0.1";
	private var host_port:Number = 6667;
	private var host_channel:String = "carnivore";
	
	// movie clip elements
	public var textfield:TextField;
	public var scrollbar:UIScrollBar;

	/**
	 * 	Constructor
	 * 
	 * 	@param	target			Target movie clip
	 */
	public function SimpleClient(target:MovieClip) {
		trace("[carnivore-client] started client...");
		this.server = new Carnivore(true);
		this.packets = new Array();
		buildUI(target);

		// add the event listener (listeners must subscribe to onPacket event)
		server.addEventListener('onPacket', Delegate.create(this, onPacket));
	}
	
	/**
	 * 	Build Client User Interface (simple)
	 * 
	 * 	@param	target			Target movie clip
	 */
	public function buildUI(target:MovieClip):Void {
		// textfield
		target.createTextField("textfield_mc", target.getNextHighestDepth(), 0, 0, 550, 400);
		this.textfield = target.textfield_mc;
		this.textfield.multiline = true;
		this.textfield.wordWrap = true;
		this.textfield.border = true;
		
		// scrollbar
		this.scrollbar = UIScrollBar(target.attachMovie("UIScrollBar", "scrollbar_mc", target.getNextHighestDepth()));
		this.scrollbar.move(this.textfield._x+this.textfield._width, this.textfield._y);
		this.scrollbar.setSize(4, this.textfield._height);
		this.scrollbar.setScrollTarget(this.textfield);
	}
	
	/**
	 * 	Connect to the Carnivore service
	 * 
	 * 	@param	host_ip			IP address of Carnivore service
	 * 	@param	host_port		Port number of Carnivore service
	 * 	@param	host_channel	Channel name to connect to (minivore, hexivore, carnivore)
	 */
	public function connect(host_ip:String, host_port:Number, host_channel:String):Void {
		if (host_ip) this.host_ip = host_ip;
		if (host_port) this.host_port = host_port;
		if (host_channel) this.host_channel = host_channel;
		
		server.connect(this.host_ip, this.host_port, this.host_channel);
	}
	
	/**
	 * 	Disconnect from the Carnivore service
	 */
	public function close():Void {
		server.close();
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
		
		this.packets.push(packet);
		trace("[carnivore-client] received packet #" + packet.getId());
		this.textfield.text += packet.getId() + ". Sent at " + packet.getTime().getHours() + ":" + packet.getTime().getMinutes() + ":" + packet.getTime().getSeconds();
		this.textfield.text += " From " + packet.getSender().ip + " Port " + packet.getSender().port;
		this.textfield.text += " To " + packet.getReceiver().ip + " Port " + packet.getReceiver().port + "\n";
		// see Packet.as for other packet object properties
	}
}