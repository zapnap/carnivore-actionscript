Carnivore Flash/ActionScript 2.0 Client Libraries (v0.3.1)
Last Updated 11/2005

Introduction:

This Carnivore Flash Library is intended to allow Flash developers to easily create new Carnivore clients by either extending (or re-writing) the provided SimpleClient class or implementing the CarnivoreListener interface as demonstrated in the ExampleClient class.

ExampleClient subclasses MovieClip, and the Carnivore_Symbol  in the FLA’s linkage is set up to associate it with the org.zerosum.carnivore.ExampleClient AS2.0 class. SimpleClient takes the alternative approach, using composition to create a dynamic text field on the stage. The method you choose to pursue will depend on what you’re trying to accomplish with your client.

In either case, these libs should take care of all the basic event handling and data parsing required by the Carnivore server, allowing client developers to focus on the interesting part: visualization.

Greets to Brian J. Hall and Jeffrey Crouse, who worked on earlier versions of a Carnivore Client Object for Flash (ActionScript 1.0), including the graphics used in the Example Client.

Installation:

Copy the class library hierarchy (org.zerosum.carnivore) to a location in your ActionScript 2.0 include path or leave them in your current working directory. 

Included Files:

SimpleClient.fla                              Simple client implementation (uses SimpleClient.as)
ExampleClient.fla                             MovieClip sub-class implementation (uses ExampleClient.as)
org/zerosum/carnivore/Carnivore.as            Core Carnivore client handler
org/zerosum/carnivore/CarnivoreListener.as    Interface required of Carnivore clients (listeners)
org/zerosum/carnivore/Packet.as               Carnivore data packet event object
org/zerosum/carnivore/SimpleClient.as         Simple Carnivore client. Extend class to create
                                              simple clients or use composition for more
                                              complex implementations
org/zerosum/carnivore/ExampleClient.as        Example Carnivore client as a MovieClip 
                                              sub-class

Usage should be pretty straightforward. See the FLA files for functional examples. Email questions, suggestions, problems, bug fixes, or whatever else to the address below:

nap -at- zerosum -dot- org

For more information on the Carnivore project, see http://r-s-g.org/carnivore
