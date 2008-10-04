import org.zerosum.carnivore.Carnivore;

/*
 *	Lists the methods that must be implemented by
 * 	an object that wants to be notified of Carnivore events.
 */
  
interface org.zerosum.carnivore.CarnivoreListener {
	/**
	 * 	Triggered when Carnivore receives new data
	 */ 
	public function onPacket(e:Object):Void;
}