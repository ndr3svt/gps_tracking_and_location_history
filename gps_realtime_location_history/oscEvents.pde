float liveLatitude=0.0;
float liveLongitude=0.0;
float liveAltitude =0.0;
PVector livePosition;
PGraphics livePosGraphic;
float dynamicSize=100;
float dynSizeSmooth=100;
void makeLiveGraphic(){
  if(dynamicSize<400){
    dynamicSize+=5.0;
  }else{
    dynamicSize=100;
  }
  dynSizeSmooth=dynSizeSmooth*0.85 + dynamicSize*0.15;
  livePosition= new PVector(map(liveLongitude,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn +shiftX,height-150,map(liveLatitude,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn + shiftZ);
  livePosGraphic.beginDraw();
  livePosGraphic.clear();
  livePosGraphic.rotateX(radians(rotX));
  livePosGraphic.rotateZ(radians(rotZ));
  livePosGraphic.stroke(50,50,255,150);
  livePosGraphic.strokeWeight(dynSizeSmooth*scaleOutIn);
  livePosGraphic.point(livePosition.x,livePosition.y,livePosition.z);
  livePosGraphic.endDraw();

}
void displayLiveGraphic(){
  image(livePosGraphic,0,0,width,height);
}
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gyro")==true){
    //pitch == 0 , roll == 1 , yaw == 2
    // pitch=theOscMessage.get(0).floatValue();
    // roll = theOscMessage.get(1).floatValue();
    // yaw = theOscMessage.get(2).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/comp")==true){
    // println();
    // compasRotation=theOscMessage.get(0).floatValue();
    // println(,theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gps")==true){
    liveLatitude = theOscMessage.get(0).floatValue();
    liveLongitude = theOscMessage.get(1).floatValue();
    liveAltitude = theOscMessage.get(2).floatValue();
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue(),theOscMessage.get(3).floatValue(),theOscMessage.get(4).floatValue(),theOscMessage.get(5).floatValue() );
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/mag")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
    // magx=theOscMessage.get(0).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/alt")==true){
    // println(theOscMessage.get(0).floatValue());
  }
}