import processing.sound.*;
import processing.serial.*;


Oscillator[] oscillators = {
new SinOsc(this), new TriOsc(this), new SawOsc(this), new SqrOsc(this) 
};

Oscillator currentOsc;

Env envelope;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
float distance;
float roll;

float minDistance = 10;
float noteDistance = 5;

int[] scale = { 
  60, 62, 64, 65, 67, 69, 71, 72
}; 



int note = 0;

void setup() {
  
  size(1000, 600); 
  
  String portName = Serial.list()[3]; 
  myPort = new Serial(this, portName, 115200);
  
  currentOsc = oscillators[0];

  //envelope setting
  envelope = new Env(this);
}

void draw() {

  background(240);
  
  drawXylophone();
  
  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n'); // read it and store it in val
  } 
  
  if(val != null && !val.isEmpty()){
    String[] data = val.split(",");
    distance = float(data[0]);
    roll = float(data[1]);
    //constrain and map roll
    roll = map(constrain(roll,-1.0,2.5),-1.0,2.5,0,1.0);
    //print(roll);
    note = floor((distance-minDistance)/noteDistance);
    
    if(note >=0 && note < scale.length){
      colourNotePlayed(note);
      stopAllOscExcept(currentOsc);
      if(roll < 0.25){
        currentOsc = oscillators[0];
      }else if(roll < 0.5){
        currentOsc = oscillators[1];
      }else if(roll < 0.75){
        currentOsc = oscillators[2];
      }else{
        currentOsc = oscillators[3];
      }
     if(currentOsc == oscillators[2] || currentOsc == oscillators[3]){
       currentOsc.play(translateMIDI(scale[note]), volume());
     } else {
       currentOsc.play(translateMIDI(scale[note]), 1);
     }
      
      
    } else {
      stopAllOsc();
    }
    
  }
    
      
}

void stopAllOsc(){
  for(Oscillator osc: oscillators){
    osc.stop();
  }
}

void stopAllOscExcept(Oscillator currentOsc){
  for(Oscillator osc: oscillators){
    if(osc != currentOsc){
      osc.stop();
    }
  }
}

float volume(){
  if(currentOsc == oscillators[2] || currentOsc == oscillators[3]){
      return 0.3;
   } else {
      return 1.0;
   }
}
    

float translateMIDI(int note) {
  return pow(2, ((note-69)/12.0))*440;
}

void drawXylophone(){
  
  rectMode(CENTER);
  noStroke();
  
  fill(230, 119, 0);
  rect(140,300,80,400);
  
  fill(255, 132, 0);
  rect(240,300,80,400);
  
  fill(255,144, 26);
  rect(340,300,80,400);
  
  fill(255, 156, 51);
  rect(440,300,80,400);
  
  fill(255,169, 77);
  rect(540,300,80,400);
  
  fill(255,181, 102);
  rect(640,300,80,400);
  
  fill(255, 193, 128);
  rect(740,300,80,400);
  
  fill(255, 206, 153);
  rect(840,300,80,400);
  
}

void colourNotePlayed(int note){
  fill(20,60);//128, 66, 0);
  rect(140+ (note*100),300,80,400);
}


/*plan
read: distance (freq), orientation (amp), state(from button for sign triangle sine)
maybe colour with amp and shape indication with state

1 oscillator?
vars:
osctype
amplitude

freq array - frequency mapped to midi

each event push button trigger changes oscilator type - otherwise set reverb on off

each distance - check and play different oscillator frequency?

check distance betwen x and y to play - set freq

serial event contains - push button change - when change type or somethign

midi: http://learningprocessing.com/examples/chp20/example-20-07-envelope

volume = float(port.readStringUntil('\n');

1st:
get imu data hrough
get ultrasonic data through
combien them together to print serial
test background colour react
imu volume


26thsept

processing crash lol
distance testing
shorten if statemetns of notes
imu for volume - maybe osc type
found maybe can have modes echo or not
reading serial from 2 inputs string splitting
nulls at teh beginning check

27th
draw rectangeles -test colours
test imu for osc types - test teh types of osc avalable
refactor to reuse code  - current soc instead of just 4 osc and stop for each - found they all Oscillator class
step all and stop all except current

28th
refactor
colours


*/
