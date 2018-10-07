import processing.sound.*;
import processing.serial.*;

//*****Xylophone Settings*****//
float minDistance = 10; //minimum distance (CM)from sensor to produce a sound
float noteDistance = 5; //distance between (CM) each note sound

//Xylophone positions and sizes
float xyloMaxHeight = 600;
float xyloWidth = 120;
float xyloStartPos = 300;

//Arrays of colours for each xylophone note
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

//*****Oscillator Settings*****//

//Midi notes to play
int[] scale = { 
  60, 62, 64, 65, 67, 69, 71, 72
}; 

//4 types of oscillaors
Oscillator[] oscillators = {
new SinOsc(this), new TriOsc(this), new SawOsc(this), new SqrOsc(this) 
};

Oscillator currentOsc; //reference current Oscillator to play sound

Env envelope; //sound enevelope for adjusting sound if needed

//****Data and variables*****//
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
float distance;
float roll;

Boolean multipleOscModeOn = false; 
//push button state variables
int MOModeState = 0;
int LastMOModeState = 0;

int note = 0; //determine which note to play

void setup() {
  
  size(1500, 900); //setup canvas size
  
  //read from serial port at baudrate 6900
  String portName = Serial.list()[3]; 
  myPort = new Serial(this, portName, 9600);
  
  //set default oscillator
  currentOsc = oscillators[0];

  //use default envelope so can adjust sound if needed
  envelope = new Env(this);
  
}

void draw() {

  background(240);
  
  //Draw the Visuals on Screen
  drawOscTypeMeter();
  drawXylophone();
  
  //Show title at the top
  textSize(85);
  fill(20);
  text("Xylosonic",600,90);
  
  //read from serial port if port is available
  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n'); // read it and store it in val
  } 
  print(val);
  //Only proceed if data from serial is not null or is not an empty string
  if(val != null && !val.isEmpty()){
    //unpack the data
    String[] data = val.split(",");
    if(data.length >2){ //proceed only if data received is complete to avoid crash
      distance = float(data[0]); //first value is distane from ultrasonic distance sensor
      roll = float(data[1]); //second value is the roll value from IMU
    
      //the third value is push button value, it sends 0 by default but if pressed, 1 is sent
      MOModeState = int(data[2]);
      if(MOModeState != LastMOModeState && MOModeState > 0){
         multipleOscModeOn = !multipleOscModeOn;//toggle multipleOscMode
      }
      LastMOModeState = MOModeState; //update Multiple Oscillator Mode State
    
      //update visual to show the text and status of whether mulsitple oscillator mode is on
      showOscMode();
    
      //constrain and map roll: value is constrained as we do not need user to rotate imu 360 degrees
      //so constrain to the main usevalues and map it between 0-1 for simpler spliting
      roll = map(constrain(roll,-1,3),-1,3.0,0,1.0);
      showRoll(roll); //update visual to indicate value of roll in the meter
    
      //determine which 'note' would be played based on the distance value
      note = floor((distance-minDistance)/noteDistance);
    
      //check that distance is within the sound range (10cm-50cm):
      // - note is 0 if it is less than the minimum and 
      // - note is greater than the scale array length if it longer than max sound range
      if(note >=0 && note < scale.length){
      colourNotePlayed(note);
      
      if(!multipleOscModeOn){
        //if multiple Oscillator mode is OFF, stop all the other oscillators
        stopAllOscExcept(currentOsc); 
      }
      
      //determine which oscillator to use based on adjusted Roll value
      if(roll < 0.25){
        currentOsc = oscillators[0];
      }else if(roll < 0.5){
        currentOsc = oscillators[1];
      }else if(roll < 0.75){
        currentOsc = oscillators[2];
      }else{
        currentOsc = oscillators[3];
      }
      
      //Play the note
       currentOsc.play(translateMIDI(scale[note]), volume());

    } else {
      stopAllOsc(); //if distance is out of sound range, stop all oscilators
    }
    
    }
  }
    
      
}

void stopAllOsc(){
  //stop all the Oscillators form playing
  for(Oscillator osc: oscillators){
    osc.stop();
  }
}

void stopAllOscExcept(Oscillator currentOsc){
  //only have the current oscillator playing
  for(Oscillator osc: oscillators){
    if(osc != currentOsc){
      osc.stop();
    }
  }
}

void showOscMode(){
  //show visuals to indicate whether muliple Oscillator mode is on or off
  textSize(30);
    if(multipleOscModeOn){
      fill(0, 179, 60);
      text("Multi Oscillator mode: ON",1000,770);
    } else {
      fill(230, 0, 0);
      text("Multi Oscillator mode: OFF",1000,770);
    }
}

float volume(){
  //square and saw oscillators are considerable louder than others so tone them down a bit 
  if(currentOsc == oscillators[2] || currentOsc == oscillators[3]){
      return 0.3;
   } else {
      return 1.0;
   }
}
    
//translate note MIDI numbers to frequency for Oscillator Object
float translateMIDI(int note) {
  return pow(2, ((note-69)/12.0))*440;
}

//Draw visuals to show which oscillator type is selected
void drawOscTypeMeter(){
  
  rectMode(CENTER);
  
  float start = 200;
  
  noStroke();
  textSize(30);
  
  fill(51, 173, 255);
  rect(65,start,35,xyloMaxHeight/4);
  text("Square",100,start);
  
  fill(133, 51, 255);
  rect(65,start + xyloMaxHeight/4,35,xyloMaxHeight/4);
  text("Saw",100,start + xyloMaxHeight/4);
  
  fill(255, 51, 51);
  rect(65,start + xyloMaxHeight/2,35,xyloMaxHeight/4);
  text("Triangle",100,start + xyloMaxHeight/2);
  
  fill(255, 156, 51);
  rect(65,start + xyloMaxHeight/4*3,35,xyloMaxHeight/4);
  text("Sine",100,start + xyloMaxHeight/4*3);
  
  //Write the type
  fill(20);
  text("Oscillator",40,770);
  text("Type",70,800);
  
  
}

//draw the xylophone with updated Values
void drawXylophone(){
  
  rectMode(CENTER);
  noStroke();
  
  //draw base of Xylophone
  fill(130);
  rect(820,250,1200,30);
  rect(820,600,1200,30);
  
  color[] colorArray;
  
  //determine colour of the xylophone from selected oscillator type
  if(currentOsc == oscillators[0]){
    colorArray = orangeColors;
  } else if(currentOsc == oscillators[1]){
    colorArray = redColors;
  } else if(currentOsc == oscillators[2]){
    colorArray = purpleColors;
  } else{
    colorArray = blueColors;
  }
  
  //draw wach key of the xylophone
  for(int i = 0; i < scale.length; i++){
    fill(colorArray[i]);
    rect(xyloStartPos + i*xyloWidth*1.25,420,xyloWidth,xyloMaxHeight - 15*i);
  }
  
}

//draw indicator to show the roll changing
void showRoll(float adjustedRoll){
  float yPos = map(adjustedRoll,0.0,1.0,130 + xyloMaxHeight,130);
  fill(24);
  triangle(45,yPos,25,yPos+10,25,yPos-10);
}

//darken the corresponding note being played on teh Xylophone
void colourNotePlayed(int note){
  fill(20,60);//128, 66, 0);
  rect(xyloStartPos + note*xyloWidth*1.25,420,xyloWidth,xyloMaxHeight - 15*note);
}
