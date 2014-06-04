class BackgroundWorker implements Runnable {
  private boolean running; // Is the thread running? Yes or no?
  private int wait; // How many milliseconds should we wait in between executions?
  private String id; // Thread name
  private int count; // Counter
  
  public int getCount() {
    return count;
  }
  
  public int getWait() {
    return wait;
  }
  
  // Constructor, create the thread
  // It is not running by default
  public BackgroundWorker(int w, String s) {
    wait = w;
    running = false;
    id = s;
    count = 0;
  }
  
  // Overriding "start()"
  private void start() {
    // Set running equal to true
    running = true;
    // Print messages
    println("Starting thread (will execute every " + wait + " milliseconds.)");
    // Do whatever start does in Thread, don't forget this!
    new Thread(this).start();
  }
  
  // We must implement run, this gets triggered by start()
  public void run() {
    while(running) {
      println(id + ": " + count);
      count++;
      // Ok, let's wait for however long we should wait
      try {
        new Thread(this).sleep((long)(wait));
        
        if (id.equals("scanner")) {
          scanner();
        }
        else if (id.equals("counter")) {
          counter();
        }
      }
      catch (Exception e) {
      }
    }
    
    System.out.println(id + " thread is done!"); // The thread is done when we get to the end of run()
    
    if (id.equals("scanner")) {
      cmd.writeDigitalOut(0);
      cmdServer.write(intToBinaryString());
      
      delay(100);
    }
    
    cmdServer.write("" + timerState);
  }
  
  // Our method that quits the thread
  private void quit() {
    System.out.println("Quitting.");
    running = false; // Setting running to false ends the loop in run()
    // In case the thread is waiting...
    new Thread(this).interrupt();
    
    timerState = false;
  }
}

import org.firmata.*;
import cc.arduino.*;

import processing.serial.*;

import processing.net.*;

// SERVER

private static Arduino arduino;
private static Command cmd;
private static Server cmdServer;
private static BackgroundWorker bgw;

private boolean timerState = false;

private void controlBit(int ledValue) {
  int ledPosition = (cmd.getLength() - 1) - (int)(log(ledValue) / log(2));
  int bit = 0;
  
  if (cmd.getLedState(ledPosition) == 0) {
    bit = cmd.bitHigh(ledValue);
  }
  else {
    bit = cmd.bitLow(ledValue);
  }
  
  cmd.writeDigitalOut(bit);
  cmdServer.write(intToBinaryString());
}

private void counter() {
  for (int i = 0; i < 256; i++) {
    cmd.writeDigitalOut(i);
    cmdServer.write(intToBinaryString());
    
    delay(bgw.getWait());
    
    // Force to stop
    if (timerState == false) {
      return;
    }
  }
  
  bgw.quit();
}

private void scanner() {
  for (int i = 0; i < cmd.getLength(); i++) {
    int shiftToRight = cmd.shiftToRight();
    
    cmd.writeDigitalOut(shiftToRight);
    cmdServer.write(intToBinaryString());
    
    delay(bgw.getWait());
  }
  
  // Force to stop
  if (timerState == false) {
    return;
  }
  
  for (int i = cmd.getLength() - 1; i >= 0; i--) {
    int shiftToLeft = cmd.shiftToLeft();
    
    cmd.writeDigitalOut(shiftToLeft);
    cmdServer.write(intToBinaryString());
    
    delay(bgw.getWait());
  }
}

private String intToBinaryString() {
  int bin = cmd.readDigitalOut();
  final String formatPattern = "%8s";
  String binaryString = String.format(
    formatPattern, Integer.toBinaryString(bin))
    .replace(' ', '0');

  return binaryString;
}

private boolean tryParseInt(String value) {
  try {
    Integer.parseInt(value);
    
    return true;
  }
  catch (NumberFormatException nfe) {
    return false;
  }
}

private void protocol(String data, Client cmdClient) {
  String[] parts;
  
  try {
    parts = data.split("\\:");
    
    if (parts.length == 2) {
      if (parts[0].equals("a")) {
        parts = parts[1].split("\\-");
        
        if (parts.length == 2) {
          if (tryParseInt(parts[0]) && tryParseInt(parts[1])) {
            int pin = Integer.parseInt(parts[0]);
            int bit = Integer.parseInt(parts[1]);
            
            if (pin >= 2 && pin <= 13) {
              if (bit >= 0 && bit <= 7) {
                cmd.assignPin(pin, bit);
              }
            }
          }
        }
      }
      else if (parts[0].equals("b")) {
        if (tryParseInt(parts[1])) {
          int ledValue = Integer.parseInt(parts[1]);
          
          if (ledValue >= 0 && ledValue <= 255) {
            controlBit(ledValue);
          }
        }
      }
      else if (parts[0].equals("sc")) {
        if (tryParseInt(parts[1])) {
          int wait = Integer.parseInt(parts[1]);
          
          if (wait >= 10 && wait <= 500) {
            if (timerState == false) {
              cmd.writeDigitalOut(128);
              cmdServer.write(intToBinaryString());
              
              timerState = true;
              
              delay(100);
              
              cmdServer.write("" + timerState);
              
              bgw = new BackgroundWorker(wait, "scanner");
              bgw.start();
            }
            else {
              bgw.quit();
            }
          }
        }
      }
      else if (parts[0].equals("cnt")) {
        if (tryParseInt(parts[1])) {
          int wait = Integer.parseInt(parts[1]);
          
          if (wait >= 100 && wait <= 1000) {
            if (timerState == false) {
              cmd.writeDigitalOut(0);
              cmdServer.write(intToBinaryString());
              
              timerState = true;
              
              delay(100);
              
              cmdServer.write("" + timerState);
              
              bgw = new BackgroundWorker(wait, "counter");
              bgw.start();
            }
            else {
              bgw.quit();
            }
          }
        }
      }
    }
    else {
      if (data.equals("clr")) {
        cmd.writeDigitalOut(0);
        cmdServer.write(intToBinaryString());
      }
      else if (data.equals("sl")) {
        int shift = cmd.shiftToLeft();
        
        cmd.writeDigitalOut(shift);
        cmdServer.write(intToBinaryString());
      }
      else if (data.equals("sr")) {
        int shift = cmd.shiftToRight();
        
        cmd.writeDigitalOut(shift);
        cmdServer.write(intToBinaryString());
      }
    }
  }
  catch (Exception e) {
  }
}

private void requests(Client cmdClient) {
  if (cmdClient != null) {
    String data = cmdClient.readString();
    
    if (!data.equals("") && data != null) {
      println("Client: " + data);
      
      protocol(data, cmdClient);
    }
  }
}

public void setup() {  
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  cmd = new Command(arduino);
  cmdServer = new Server(this, 1832);
}

public void draw() {
  Client cmdClient = cmdServer.available();
  
  requests(cmdClient);
}

public void dispose() {
  cmd.finish();
  arduino.dispose();
  cmdServer.stop();
  
  super.stop();
}

/* Communication Protocol
* a:pin-bit <= pin assignments (0, 1, 2, 3, 4, 5, 6 & 7)
* b:ledValue <= bit low/high
* sl <= bit shift to left
* sr <= bit shift to right
* clr <= clear
* cnt:delay <= counter
* sc:delay <= scanner
*/
