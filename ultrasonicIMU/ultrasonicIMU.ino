// Based off Example I2C Setup from ardiuno examples
#include <Wire.h>
#include <SPI.h>
#include <SparkFunLSM9DS1.h>

//////////////////////////
// LSM9DS1 Library Init //
//////////////////////////
// Use the LSM9DS1 class to create an object.
LSM9DS1 imu;

///////////////////////
// Example I2C Setup //
///////////////////////
// SDO_XM and SDO_G are both pulled high, so our addresses are:
#define LSM9DS1_M  0x1E // Would be 0x1C if SDO_M is LOW
#define LSM9DS1_AG  0x6B // Would be 0x6A if SDO_AG is LOW


const int trigPin = 11;    // Trigger
const int echoPin = 12;    // Echo
const int buttonPin = 2;    // pushbutton

long duration, cm;           //for reading distance sensor
int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button

//Ultrasonic sensor reading based off code from:
//https://randomnerdtutorials.com/complete-guide-for-ultrasonic-sensor-hc-sr04/
 
void setup() {
  //Serial Port begin
  Serial.begin (9600);//115200);
    
  // Before initializing the IMU, 
  // se the device's communication mode and addresses:
  imu.settings.device.commInterface = IMU_MODE_I2C;
  imu.settings.device.mAddress = LSM9DS1_M;
  imu.settings.device.agAddress = LSM9DS1_AG;

  //begin IMU check
  if (!imu.begin())
  {
    //show error message/help if IMU does not begin
    Serial.println("Failed to communicate with LSM9DS1.");
    Serial.println("Double-check wiring.");
    Serial.println("Default settings in this sketch will " \
                  "work for an out of the box LSM9DS1 " \
                  "Breakout, but may need to be modified " \
                  "if the board jumpers are.");
    while (1)
      ;
  }

  //Define inputs and outputs Pins
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(buttonPin, INPUT);
}
 
void loop() {
  
  // The sensor is triggered by a HIGH pulse of 10 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  digitalWrite(trigPin, LOW);
  delayMicroseconds(5);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
 
  // Read the signal from the sensor: a HIGH pulse whose
  // duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(echoPin, INPUT);
  duration = pulseIn(echoPin, HIGH);
 
  // Convert the time into a distance
  cm = (duration/2) / 29.1; 

  //print distance in CM
  Serial.print(cm);
  Serial.print(",");

   if ( imu.accelAvailable() )
  {
    // To read from the accelerometer if available, first call readAccel() function to
    // update ax, ay, and az variables with the most current data.
    imu.readAccel();
  }

  //print the roll value
  printRoll(imu.ax,imu.ay,imu.az);
  
  delay(250);
  
}

void checkButton(){
  //read if button is pressed and print to serial status
  buttonState = digitalRead(buttonPin);
   Serial.print(",");
  // compare the buttonState to its previous state
  if (buttonState != lastButtonState) {
    // if the state has changed
    if(buttonState == HIGH){
      Serial.print("1"); //send 1 only once when button is pressed
    }else{
      Serial.print("0"); //keep a neutral 0 on button release
    }
    
    // Delay a little bit to avoid bouncing
    delay(50);
  } else {
    Serial.print("0"); //print 0 when button not pressed
  }
  
  
  // save the current state as the last state, for next time through the loop
  lastButtonState = buttonState;
}

void printRoll(float ax, float ay, float az){
  //calculate roll from acceleration values
  float roll = atan2(ay, az);
  
  //print the roll
  Serial.print(roll, 2);
  
  checkButton(); //check if button is pressed

  //next line for next series of data
  Serial.println();

 
}


