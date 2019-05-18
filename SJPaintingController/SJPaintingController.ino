#include <SPI.h>
#include <Ethernet.h>

#include <ArdOSC.h>

int redPin = 5;
int greenPin = 6;
int bluePin = 3;

byte serverMac[] = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte serverIp[]  = { 192, 168, 1, 17 };
int  serverPort  = 9999; //OSCserver listening port

OSCServer server;
OSCMessage *_mes;

void setup(){ 
  
 Serial.begin(19200);
 
 Ethernet.begin(serverMac ,serverIp); 
 server.begin(serverPort);
 
 //set callback function
 server.addCallback("/ard/red",&red); 
 server.addCallback("/ard/green",&green); 
 server.addCallback("/ard/blue",&blue);
 server.addCallback("/ard/allOff",&allOff);
 server.addCallback("/ard/player",&player);
 server.addCallback("/ard/prog",&prog); 
 //all pins off
 analogWrite(redPin,0);
 analogWrite(greenPin,0);
 analogWrite(bluePin,0);
}
  
void loop(){
  if(server.aviableCheck()>0){
  //  Serial.println("alive! ");
  }
}

void red(OSCMessage *mes){
  int rVal = (int) mes->getArgFloat(0);
  analogWrite(redPin,rVal);
}

void green(OSCMessage *mes){
  int gVal = (int) mes->getArgFloat(0);
  analogWrite(greenPin,gVal);
}

void blue(OSCMessage *mes){
  int bVal = (int) mes->getArgFloat(0);
  analogWrite(bluePin,bVal);
}

void player(OSCMessage *mes){
  if(mes->getArgInt32(0) == 1) {
    analogWrite(redPin,255);
    analogWrite(greenPin,0);
    analogWrite(bluePin,0);
  } else if(mes->getArgInt32(0) == 2) {
    analogWrite(redPin,0);
    analogWrite(greenPin,255);
    analogWrite(bluePin,0);
  } else if(mes->getArgInt32(0) == 3) {
    analogWrite(redPin,0);
    analogWrite(greenPin,0);
    analogWrite(bluePin,255);
  } else {
    allOff(mes);
  }
}

void allOff(OSCMessage *mes){
  analogWrite(redPin,0);
  analogWrite(greenPin,0);
  analogWrite(bluePin,0);
  while (int i = 0) {
  }
}

void prog(OSCMessage *mes){
  int progNum = (int)mes->getArgFloat(0);
  if (progNum == 1) {
    //randRot
    do{
     int r = random(0,255);
     int g = random(0,255);
     int b = random(0,255);
     analogWrite(redPin,r);
     analogWrite(greenPin,g);
     analogWrite(bluePin,b);
     delay(2000);
    } while (progNum != 0);
  } 
  else if (progNum == 2) {
    //random color
    int r = random(0,255);
    int g = random(0,255);
    int b = random(0,255);
    analogWrite(redPin,r);
    analogWrite(greenPin,g);
    analogWrite(bluePin,b);
  } 
  else if (progNum == 3) {
    //White
    analogWrite(redPin,255);
    analogWrite(greenPin,255);
    analogWrite(bluePin,255);
  }
  else if (progNum == 4) {
    //Solar Eclipse
    analogWrite(redPin,255);
    analogWrite(greenPin,50);
    analogWrite(bluePin,0);
  } else if (progNum == 100) {
    allOff(mes);
  } else {
  
  }
}
