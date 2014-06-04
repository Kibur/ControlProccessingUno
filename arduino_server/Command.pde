// Created by D.Manuel 17/05/2014
// Conceived for byte operations
// Uses 8 digital pins, only for output
// Meant to extend the Arduino library

public class Command {
  // Fields
  private Arduino arduino;
  private final int[] LEDS = {9, 8, 7, 6, 5, 4, 3, 2};
  private int[] ledStates = {
    0, 0, 0, 0,
    0, 0, 0, 0
  };
  
  // Constructor
  public Command(Arduino arduino) {
    this.arduino = arduino;
    
    // Initialize LEDs
    for (int i = 0; i < this.LEDS.length; i++) {
      this.arduino.pinMode(this.LEDS[i], Arduino.OUTPUT);
    }
  }
  
  // Getters
  
  public int[] getLedStates() {
    return this.ledStates;
  }
  
  public int getLedState(int led) {
    return this.ledStates[led];
  }
  
  public int getLength() {
    return this.LEDS.length;
  }
  
  // Setters
  
  public void assignPin(int pin, int bit) {
    LEDS[(LEDS.length - 1) - bit] = pin;
  }
  
  // Methods
  
  public int readDigitalOut() {
    int result = 0;
    
    for (int i = 0; i < LEDS.length; i++) {
      if (ledStates[i] == 1) {
        int exp = (LEDS.length - 1) - i;
        
        result += Math.pow(2, exp);
      }
    }
    
    return result;
  }
  
  public void writeDigitalOut(int bin) {
    final String formatPattern = "%8s";
    String binaryString = String.format(
      formatPattern, Integer.toBinaryString(bin))
      .replace(' ', '0');
    char[] bits = new char[8];
    
    bits = binaryString.toCharArray();
    
    for (int i = 0; i < bits.length; i++) {
      if (bits[i] == '0') {
        arduino.digitalWrite(LEDS[i], Arduino.LOW);
        ledStates[i] = 0;
      }
      else {
        arduino.digitalWrite(LEDS[i], Arduino.HIGH);
        ledStates[i] = 1;
      }
    }
    
    println(binaryString + " (" + bin + ")");
  }
  
  public int shiftToLeft() {
    int input = readDigitalOut();
    int shift = input << 1;
    
    if (input >= 128) {
      return input;
    }
    
    return shift;
  }
  
  public int shiftToRight() {
    int input = readDigitalOut();
    int shift = input >> 1;
    
    if ((input % 2) == 1) {
      return input;
    }
    
    return shift;
  }
  
  public int bitLow(int led) {
    int input = readDigitalOut();
    
    // 1 bit to 0
    int resXOR = led ^ 255; // ^ = XOR
    int res = input & resXOR; // & = AND
    
    return res;
  }
  
  public int bitHigh(int led) {
    int input = readDigitalOut();
    
    // 1 bit to 1
    int res = input | led; // | = OR
    
    return res;
  }
  
  public void finish() {
    writeDigitalOut(0);
    arduino.dispose();
  }
}
