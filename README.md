ControlProccessingUno
=====================

This is the client.
The GUI is made with the ControlP5 libary.
The client never communicates with the Arduino.

I have created my own communication protocol which is:

a:pin-bit <= pin assignments
b:ledValue <= bit low/high
(makes it possible to display integers from 0 to 255 on the LED's)
sl <= bit shift to left
sr <= bit shift to right
clr <= clear
cnt:delay <= counter (counting from 0 to 255)
sc:delay <= scanner (knight rider like effect without PWN)

Note: delays are in milliseconds
