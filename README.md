ControlProccessingUno
=====================

This is the server (no GUI just a default window because I don't know how hide it).<br/>
The server is connected to the Arduino so everything is processed from server to Arduino.<br/>

The server doesn't necessarily needs a connection of the client to work.<br/>
Because the client sends 1 command at a time. And all commands are triggers.<br/>
So when you use a command it triggers a function of the server and will execute until it's done.<br/>
The client is not needed anymore. You can disconnect the client, the server will still execute it.<br/>
You can also reconnect while the server is busy with the Arduino.<br/>
Because the server just sends out every output even if there's no other client.<br/>
This is also means the client monitors what the server does.<br/>

Note:<br/>
I have made some kind of library which is Command.pde.<br/>
I have conceived this simple little class in a previous version of this, but without server-client communication.<br/>
With this little class I have simplified basic initialization processes and much more...<br/>
It also opens some possibilities to do more things like bit operations which is used for bit shifting.
