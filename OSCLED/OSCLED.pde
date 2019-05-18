import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;
import cc.arduino.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress arduinoAddress;
Minim minim;
AudioPlayer song;
AudioOutput out;
BeatDetect beat;
BeatListener bl;
Arduino arduino;
PFont font;
PImage bg;
color oscillatorColor = color(0,0,0);

void setup()
{
  size(367, 550, P3D);
  frameRate(25);
  String oscillatorColor = "";
  bg = loadImage("../data/simonneLive.jpg");
  font = loadFont("../data/Consolas-48.vlw");
  
  minim = new Minim(this); 
  out = minim.getLineOut(); 
  
  song = minim.loadFile("C:\\Users\\nick\\Documents\\Processing\\audio_test\\data\\RedSkyAtNight.mp3");

 beat = new BeatDetect(song.bufferSize(), song.sampleRate());
 //for SOUND_ENERGY mode
 // beat = new BeatDetect();
 
  beat.setSensitivity(10);  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);
  
  oscP5 = new OscP5(this,10000);
  arduinoAddress = new NetAddress("192.168.1.17",9999);
}

void draw()
{
  background(0);
  image(bg,0,0);
  fill(255,0,0);
  //stop/pause button
  noStroke();
  rect(30, 500, 20, 20);
  textFont(font, 15);
  fill(100, 255, 0);
  //Print Artist/SongName to top of window
  text(song.getMetaData().author() + " - " + song.getMetaData().title(), 40, 40);
  //InSOUND_ENERGY mode just check for beat
  /*if (beat.isOnset()){
    pinMsg.add(6);
  } else {
    pinMsg.add(100);
  }*/
  //Create OSC Message object
  OscMessage pinMsg = new OscMessage("/ard/player");
  if ( beat.isKick() ) {
    println("kick");
    oscillatorColor = color(0,0,255);
    //send OSC message - send 3 to activate blue LED
    pinMsg.add(3);
  }
  else if ( beat.isSnare() ) {
    println("snare");
    oscillatorColor = color(255,0,0);
    //send OSC message - send 1 to activate red LED
    //pinMsg.add(1);    
  }
  else if ( beat.isHat() ) {
    println("hat");
    oscillatorColor = color(0,255,0);
    //send OSC message - send 2 to activate green LED
   // pinMsg.add(2);
  } else {
   //send OSC message - all Off
    pinMsg.add(100);
  }
  //send the OSC message to arduino
  println(pinMsg);
  oscP5.send(pinMsg, arduinoAddress);
  for(int i = 0; i < out.bufferSize() - 1; i++)
  {
    stroke(oscillatorColor);
    //line(i, 240 + song.left.get(i)*250, i+1, 245 + song.left.get(i+1)*250);
    //line(i, 310 + song.right.get(i)*250, i+1, 310 + song.right.get(i+1)*250);
    line(i, 310 + song.mix.get(i)*250, i+1, 310 + song.mix.get(i+1)*250);
  }
}

void mousePressed() {
  if(mouseX>30 && mouseX<50) //co-ordinates for button area
    if(mouseY>500 && mouseY<520)
      if (song.isPlaying()){  //button function, ie play/pause
        song.pause();
      }
    else{
      song.play();
    }
}

void oscEvent(OscMessage theOscMessage) {
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
  println(" value: " +theOscMessage.get(0).intValue());
  if (theOscMessage.get(0).intValue() == 1) {
     song.play();
     println("hello yess");
 // } else if (theOscMessage.addrPattern() == "/proc/player" && theOscMessage.get(0).intValue() == 0) {
 } else if (theOscMessage.get(0).intValue() == 0) {
    song.pause();
    println("hello yess");
  }
}

void stop()
{
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}