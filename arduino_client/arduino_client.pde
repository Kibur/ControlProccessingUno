import controlP5.*;

import processing.net.*;

// CLIENT

private static Client cmdClient;
private static ControlP5 controlP5;

private Button[] bLeds = new Button[8];
private Button[] bShifters = new Button[2];

private Button bClear, bScanner, bCounter, bExecute;

private Textfield txtCommand;

private boolean timerState = false;

private void bLeds_onClick(int theValue) {
  int exp = (bLeds.length - 1) - theValue;
  int led = (int)Math.pow(2, exp);
  
  String data = "b:" + led; // send "Control Bit" command
  
  cmdClient.write(data);
}

private void bLed0_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed1_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed2_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed3_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed4_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed5_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed6_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bLed7_onClick(int theValue) {
  bLeds_onClick(theValue);
}

private void bShiftLeft_onClick(int theValue) {
  String data = "sl"; // send "Shift Left" command
  
  cmdClient.write(data);
}

private void bShiftRight_onClick(int theValue) {
  String data = "sr"; // send "Shift Right" command
  
  cmdClient.write(data);
}

private void bClear_onClick(int theValue) {
  String data = "clr"; // send "Clear" command
  
  cmdClient.write(data);
}

private void scannerButton() {
  if (timerState) {
    bScanner.setColorBackground(color(255, 0, 0));
    bScanner.setCaptionLabel("STOP");
  }
  else {
    bScanner.setColorBackground(color(0, 255, 0));
    bScanner.setCaptionLabel("SCANNER");
  }
}

private void bScanner_onClick(int theValue) {
  String data = "sc:70"; // send "Scanner" command
  
  cmdClient.write(data);
}

private void counterButton() {
  if (timerState) {
    bCounter.setColorBackground(color(255, 0, 0));
    bCounter.setCaptionLabel("STOP");
  }
  else {
    bCounter.setColorBackground(color(0, 255, 0));
    bCounter.setCaptionLabel("COUNTER");
  }
}

private void updateGUI_Controls() {
  scannerButton();
  counterButton();
}

private void bCounter_onClick(int theValue) {
  String data = "cnt:1000"; // send "Counter" command
  
  cmdClient.write(data);
}

private void bExecute_onClick(int theValue) {
  String data = txtCommand.getText();
  
  cmdClient.write(data);
}

private void placeControls() {
  int defaultValue = 0;
  int x = 20;
  int y = 30;
  int size = 20;
  
  // Button foreach LED
  for (int i = 0; i < bLeds.length; i++) {
    bLeds[i] = controlP5.addButton("bLed" + i + "_onClick", i, x + (i * 30), y, size, size);
    bLeds[i].setColorBackground(color(255, 255, 255));
    bLeds[i].setColorLabel(color(0, 0, 255));
    bLeds[i].setCaptionLabel("" + ((bLeds.length - 1) - i));
  }
  
  // Buttons for shifters
  bShifters[0] = controlP5.addButton("bShiftLeft_onClick", defaultValue, x, y + 30, size, size);
  bShifters[0].setCaptionLabel("<<");
  
  bShifters[1] = controlP5.addButton("bShiftRight_onClick", defaultValue, x + (size + 10), y + 30, size, size);
  bShifters[1].setCaptionLabel(">>");
  
  // Button for CLEAR
  bClear = controlP5.addButton("bClear_onClick", defaultValue, x + ((size * 2) + size), y + 30, size + 20, size);
  bClear.setCaptionLabel("CLEAR");
  
  // Button for SCANNER
  bScanner = controlP5.addButton("bScanner_onClick", defaultValue, x + ((size * 3) + size + 30), y + 30, size + 20, size);
  bScanner.setCaptionLabel("SCANNER");
  
  // Button for COUNTER
  bCounter = controlP5.addButton("bCounter_onClick", defaultValue, x + ((size * 4) + (size * 2) + 40), y + 30, size + 20, size);
  bCounter.setCaptionLabel("COUNTER");
  
  // Textfield for executing commands directly
  txtCommand = controlP5.addTextfield("Command", x, y + (30 * 2), (size * 5), size);
  
  // Button for EXECUTE
  bExecute = controlP5.addButton("bExecute_onClick", defaultValue, x + (size * 5) + 10, y + (30 * 2), size + 20, size);
  bExecute.setCaptionLabel("EXECUTE");
}

private void updateGUI_LEDS(String binaryString) {
  char[] bits = binaryString.toCharArray();
  
  for (int i = 0; i < bits.length; i++) {
    if (bits[i] == '1') {
      bLeds[i].setColorBackground(color(255, 0, 0));
    }
    else {
      bLeds[i].setColorBackground(color(255, 255, 255));
    }
  }
}

public void setup() {
  size(300, 150);
  
  cmdClient = new Client(this, "127.0.0.1", 1832);
  controlP5 = new ControlP5(this);
  
  placeControls();
  
  String data = "";
  
  // PIN assignments
  for (int i = 0; i < bLeds.length; i++) {
    data = "a:" + (i + 2) + "-" + i; // send "Pin Assignment" command
    
    cmdClient.write(data);
    
    delay(100);
  }
}

private void responses() {
  String data = cmdClient.readString();
  
  if (data != null && !data.equals("")) {
    println("Server: " + data);
    
    if (data.equals("true") || data.equals("false")) {
      timerState = Boolean.parseBoolean(data);
      
      updateGUI_Controls();
    }
    else {
      updateGUI_LEDS(data);
    }
  }
}

public void draw() {
  responses();
}

public void dispose() {
  String data = "clr";
  
  if (timerState) {
    data = "sc:50"; // Resend "Scanner" command to stop timer
    
    cmdClient.write(data);
    
    delay(100);
    
    data = "clr"; // send "Clear" command
  }
  
  cmdClient.write(data);
  
  super.stop();
}
