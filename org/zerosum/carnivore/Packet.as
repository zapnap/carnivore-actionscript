/**
 *	Carnivore packet message format
 */
class org.zerosum.carnivore.Packet {
	
	private var id:Number = null;
	private var time:Date = null;
	private var senderIP:String = null;
	private var senderPort:Number = null;
	private var receiverIP:String = null;
	private var receiverPort:Number = null;
	private var content:String = null;
	private var raw:String = null;
	
	/**
	 *	Creates packet object to pass to listeners (clients)
	 */
	public function Packet(id:Number, time:Date, sIp:String, sPort:Number, rIp:String, rPort:Number, content:String, raw:String) {
		this.id = id;
		this.time = time;
		this.senderIP = sIp;
		this.senderPort = sPort;
		this.receiverIP = rIp;
		this.receiverPort = rPort;
		this.content = content;
		this.raw = raw;
	}
	
	/**
	 * 	Retrieve packet ID
	 */
	public function getId():Number {
		return this.id;
	}
	
	/**
	 * 	Retrieve packet Time
	 */
	public function getTime():Date {
		return this.time;
	}
	
	/**
	 * 	Retrieve Sender object (ip, port)
	 */
	public function getSender():Object {
		var senderObj = new Object();
		senderObj.ip = this.senderIP;
		senderObj.port = this.senderPort;
		return senderObj;
	}
	
	/**
	 * 	Retrieve Receiver object (ip, port)
	 */
	public function getReceiver():Object {
		var receiverObj = new Object();
		receiverObj.ip = this.receiverIP;
		receiverObj.port = this.receiverPort;
		return receiverObj;
	}
	
	/**
	 * 	Retrieve packet Content (data)
	 */
	public function getContent():String {
		return this.content;
	}

	/**
	 *	Retrieve Raw packet data
	 */
	public function getRaw():String {
		return this.raw;
	}
}