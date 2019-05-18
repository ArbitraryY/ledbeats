import ddf.minim.*;
import ddf.minim.analysis.*;
import processing.serial.*;
import cc.arduino.*;

Minim minim;
AudioPlayer song;
AudioOutput out;
BeatDetect beat;
BeatListener bl;
Arduino arduino;
PFont font;
PImage bg;
color oscillatorColor = color(0,0,0);
//for serial only
int redPin = 5;
int greenPin = 6;
int bluePin = 3;

void setup()
{
  size(367, 550, P3D);
  String oscillatorColor = "";
  bg = loadImage("../data/live.jpg");
  font = loadFont("../data/Consolas-48.vlw");
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(redPin, Arduino.OUTPUT);
  arduino.pinMode(greenPin, Arduino.OUTPUT);
  arduino.pinMode(bluePin, Arduino.OUTPUT);
  //start with all off
  arduino.analogWrite(redPin, 255);
  arduino.analogWrite(greenPin, 255);
  arduino.analogWrite(bluePin, 0);
  
  minim = new Minim(this); 
  out = minim.getLineOut();
  //load an mp3 file
  song = minim.loadFile("C:\\Users\\nick\\Documents\\Processing\\audio_test\\data\\questionMarksAndOtherDemonicPunctuation.mp3", 2048);

  beat = new BeatDetect(song.bufferSize(), song.sampleRate());

  beat.setSensitivity(10);  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);
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

  if ( beat.isKick() ) {
    println("kick");
    oscillatorColor = color(255,0,0);
    //Serial write
    arduino.analogWrite(redPin, 255);
    arduino.analogWrite(bluePin, 0);
    arduino.analogWrite(greenPin, 0);
  }
  else if ( beat.isSnare() ) {
    println("snare");
    oscillatorColor = color(0,255,0);
    //Serial write
    arduino.analogWrite(redPin, 0);
    arduino.analogWrite(greenPin, 255);
    arduino.analogWrite(bluePin, 0);
  }
  else if ( beat.isHat() ) {
    println("hat");
    oscillatorColor = color(0,0,255);
    //Serial write
    arduino.analogWrite(redPin, 0);
    arduino.analogWrite(greenPin, 0);
    arduino.analogWrite(bluePin, 255);
  } else {
    //Serial write
    arduino.analogWrite(redPin, 0);
    arduino.analogWrite(bluePin, 0);
    arduino.analogWrite(greenPin, 0);
  }
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

void stop()
{
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}