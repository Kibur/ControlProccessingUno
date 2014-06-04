ControlProccessingUno
=====================

Controlling an Arduino Uno with Processing with server-client communication.

This contains 2 braches for the server and the client application.
There are standard pin assignments. I'm using pin 2 (bit 0) to pin 9 (bit 7).
Those can be changed with the client with the proper command. (see README in client)
Or you can just change the code in Client.pde. (protocol allows pin 2 to 13)
And it's was conceived with 8 LED's each representing a bit of one byte.

It's using the Arduino library for Processing.

Note: Only tested on Arduino Uno R3 (because I have no other)
