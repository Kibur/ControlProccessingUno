ControlProcessingUno
=====================

This is the client.<br/>
The GUI is made with the ControlP5 libary.<br/>
The client never communicates with the Arduino.<br/>

I have created my own communication protocol which is:
<ul>
  <li>a:pin-bit := pin assignments</li>
  <li>b:ledValue := bit low/high
  (makes it possible to display integers from 0 to 255 on the LED's)</li>
  <li>sl := bit shift to left</li>
  <li>sr := bit shift to right</li>
  <li>clr := clear</li>
  <li>cnt:delay := counter (counting from 0 to 255)</li>
  <li>sc:delay := scanner (knight rider like effect without PWM)</li>
</ul>
Note: delays are in milliseconds
