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

int pushCounter = 0;

int[] scale = { 
  60, 62, 64, 65, 67, 69, 71, 72
}; 

Boolean multipleOscModeOn = false;

float xyloStartPos = 160;

color[] orangeColors = {
  color(230, 119, 0), color(255, 132, 0), color(255,144, 26), color(255, 156, 51), color(255,169, 77),
  color(255,181, 102), color(255, 193, 128), color(255, 206, 153)
};

color[] blueColors = {
  color(0, 138, 230), color(0, 153, 255), color(26, 163, 255), color(51, 173, 255), color(77, 184, 255),
  color(102, 194, 255), color(128, 204, 255), color(153, 214, 255)
};

color[] redColors = {
  color(230, 0, 0), color(255, 0, 0), color(255, 26, 26), color(255, 51, 51), color(255, 77, 77),
  color(255, 102, 102), color(255, 128, 128), color(255, 153, 153)
};

color[] purpleColors = {
  color(92, 0, 230), color(102, 0, 255), color(117, 26, 255), color(133, 51, 255), color(148, 77, 255),
  color(163, 102, 255), color(179, 128, 255), color(194, 153, 255)
};

int note = 0;

void setup() {
  
  size(1000, 600); 
  
  String portName = Serial.list()[3]; 
  myPort = new Serial(this, portName, 9600);
  
  currentOsc = oscillators[0];

  //envelope setting
  envelope = new Env(this);
  
 
}

void draw() {

  background(240);
  drawOscTypeMeter();
  drawXylophone();
  
  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n'); // read it and store it in val
  } 
  
  if(val != null && !val.isEmpty()){
    String[] data = val.split(",");
    distance = float(data[0]);
    roll = float(data[1]);
    
    if(float(data[2]) > 0){
      
      pushCounter++;
      if(pushCounter > 12){
        multipleOscModeOn = !multipleOscModeOn;
        pushCounter = 0;
      }
      
    }
    //constrain and map roll
    //println(roll);
    roll = map(constrain(roll,-1.0,2.5),-1.0,2.5,0,1.0);
    //print(roll);
    note = floor((distance-minDistance)/noteDistance);
    showRoll(roll);
    if(note >=0 && note < scale.length){
      colourNotePlayed(note);
      
      if(!multipleOscModeOn){
        stopAllOscExcept(currentOsc);
      }
      
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

void drawOscTypeMeter(){
  rectMode(CENTER);
  
  fill(51, 173, 255);
  rect(12,150,24,100);
  
  fill(133, 51, 255);
  rect(12,250,24,100);
  
  fill(255, 51, 51);
  rect(12,350,24,100);
  
  fill(255, 156, 51);
  rect(12,450,24,100);
  
  
}

void drawXylophone(){
  
  rectMode(CENTER);
  noStroke();
  
  color[] colorArray;
  
  if(currentOsc == oscillators[0]){
    colorArray = orangeColors;
  } else if(currentOsc == oscillators[1]){
    colorArray = redColors;
  } else if(currentOsc == oscillators[2]){
    colorArray = purpleColors;
  } else{
    colorArray = blueColors;
  }
  
  for(int i = 0; i < scale.length; i++){
    fill(colorArray[i]);
    rect(xyloStartPos + i*100,300,80,400 - 15*i);
  }
  
}

void showRoll(float adjustedRoll){
  float yPos = map(adjustedRoll,0.0,1.0,500,100);
  fill(24);
  triangle(25,yPos,40,yPos+10,40,yPos-10);
}

void colourNotePlayed(int note){
  fill(20,60);//128, 66, 0);
  rect(xyloStartPos + note*100,300,80,400 - 15*note);
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
needed contrast so less wide spectrum of the colour
figure out which colours to show as selected - tried pickinga dark shade or a light shade - but contrast varied too much

decided to go with a grey over lay - worked well

29th
colours
refactor drawing
colors arrays
test pen lever
refactor drawing the xylophone
push button - frame rate faster than receive so get many to trigger- -should debouce there too
why not just debounce whole freaking thing lol
*/
