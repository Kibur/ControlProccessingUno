ControlProcessingUno
=====================

Controlling an Arduino Uno with Processing with server-client communication.<br/>

This contains 2 branches for the <b>server</b> and the <b>client</b> application.<br/>
There are standard pin assignments. I'm using pin 2 (bit 0) to pin 9 (bit 7).<br/>
Those can be changed with the client with the proper command. (see README in client)<br/>
Or you can just change the code in Client.pde. (protocol allows pin 2 to 13)<br/>
And it was conceived with 8 LED's each representing a bit of one byte.<br/>

It's using the Arduino library for Processing.<br/>

Note: Only tested on Arduino Uno R3 (because I have no other)
