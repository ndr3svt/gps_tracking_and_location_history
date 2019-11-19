import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(800,800);
  frameRate(30);
  // change the listening port according to your needs
  oscP5 = new OscP5(this,12000);

  myRemoteLocation = new NetAddress("127.0.0.1",12001);
}

void draw() {
  background(0);
  fill(255);
  text("pitch: "+pitch,50,50);rect(300,40,20*pitch,5);
  text("roll: "+roll,50,65);rect(300,55 , 20*roll,5);
  text("yaw: "+yaw,50,80);rect(300,70 , 20*yaw,5);
  text("north: "+compasRotation,50,95);rect(300,85 , map(compasRotation,0,360,0,2.0)*20,5);
  text("latitude: "+latitude,50,110);
  text("altitude: "+altitude,50,125);
  text("longitude: "+longitude,50,140);
  text("distanceToGround: "+altimeter,50,155);rect(300,145 , map(altimeter,0,2.0,0,2.0)*20,5);
}

//  add more variables if you want to get the values on the osc function and use them somewhere else 
float pitch, roll,yaw, compasRotation, latitude, altitude,longitude, altimeter;

void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gps")==true) {
  	latitude = theOscMessage.get(0).floatValue();
  	longitude = theOscMessage.get(1).floatValue();
  	altitude = theOscMessage.get(2).floatValue();
    // println("lat:",theOscMessage.get(0).floatValue() , "long:",theOscMessage.get(1).floatValue(), "alt:",theOscMessage.get(2).floatValue());

  }

  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gyro")==true){
    //pitch == 0 , roll == 1 , yaw == 2
    pitch=theOscMessage.get(0).floatValue();
    roll = theOscMessage.get(1).floatValue();
    yaw = theOscMessage.get(2).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/comp")==true){
    compasRotation=theOscMessage.get(0).floatValue();

  }

  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/mag")==true){
    // println( "mag x : " + theOscMessage.get(0).floatValue()  + " , mag y : " + theOscMessage.get(1).floatValue() + " , mag z : " + theOscMessage.get(2).floatValue() );
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/alt")==true){
  	// you got it I hope, here you can get the altitude value on its own, differs from the altitude you get from the 
  	// gps positioning, it approximates the distance from the phone to the ground
  	// not crazy accurate but sometimes impressively close
  	altimeter=theOscMessage.get(0).floatValue();
  	// println("distance from phone to ground : "+ theOscMessage.get(0).floatValue());
  }


}
