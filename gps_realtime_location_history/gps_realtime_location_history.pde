// Zurich November 2019
// Reading GPS location from GYROSC
// Reading Google's Location History in KML Format 
// Andrés Villa Torres
import oscP5.*;
import netP5.*;



String [] lines;
int index=0;
String matchedString="";
int matchedIndex = 0;
String cleanedString="";
float longitude=0.0;
float latitude=0.0;


OscP5 oscP5;
NetAddress myRemoteLocation;

PVector mapPointA;
PVector mapPointB;
ArrayList<PVector> points = new ArrayList<PVector>();
PGraphics pointsGraph;
PVector softenPos;
float xMax,xMin,zMax,zMin,yMax,yMin;
void setup(){
	size(displayWidth,displayHeight,P2D);
	background(255);
	smooth(2);
	pixelDensity(2);
	xMax=width*4;xMin=-width*4;zMax=height*2;zMin=-height*4;yMax=height-150;yMin=height-150;
	frameRate(60);
	oscP5 = new OscP5(this,12000);
	//  satellite corner A
	mapPointA = new PVector( 8.447664,47.409515);
	
	// mapPointB = new PVector(8.637451,47.328309);

	// satellite corner B
	mapPointB = new PVector(8.612645,47.337028);

	// mapPointB = new PVector(8.637672,47.328408);
	loadMap();
	createCursorGraphic();
	pointsGraph=createGraphics(width,height,P3D);
	lines = loadStrings("Location History_C.kml");
	println("there are " + lines.length + " lines");
	for (int i = 0; i<lines.length; i ++){
		String [] match1 = match(lines[i] , "<gx:coord>");
		if ( match1 != null && i > (lines.length-111800) ){
			matchedString= lines[i];
			matchedIndex = i;
			cleanedString = matchedString.substring(14, matchedString.length()-11);  // Returns "Ra"
			String [] coordinates = split(cleanedString, ' ');
			latitude = float(coordinates[1]);
			longitude = float(coordinates[0]);
			PVector thisPoint = new PVector(longitude, height-150 ,latitude);
			points.add(thisPoint);
		}
	}
	generateMapGraphic();
	makeMapGraphic();
	makePathGraphic();
	makeLiveGraphic();
	noCursor();
	softenPos= new PVector(0,0,0);
	updatePlaces();
	makePlacesGraphic();
}


void draw(){
	background(255);
	makeLiveGraphic();
	// blendMode(NORMAL);
	displayMap();
	image(pointsGraph,0,0,width,height);
	customCursor();
	if (frameCount % 8 == 0) {
    	thread("comparePoints");
  	}
	displayFocusPoint();
	fill(0,0,0);
	textAlign(LEFT,TOP);
	textSize(16);
	text("FPS:" + (frameRate),50,25);
	text("Recorded GPS points in Google Timeline : " + points.size(),50,50);
	text("brightness value : " + brr  + " , " + pointsMapGenWater.size(), 50,75);
	text("live location ::: long: " + liveLongitude + " , lat: " + liveLatitude + ", alt: " + liveAltitude,50,100);
	
	displayPlaces();
	displayLiveGraphic();
	if(keyPressed){
		ifKeyPressed();
	}
}
float rotX=0.0;
float rotZ=0.0;
float scaleOutIn=1.0;
float shiftX=0.0;
float shiftZ=0.0;
void ifKeyPressed(){
	if(keyCode == UP){
		rotX+=1.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(keyCode == DOWN){
		rotX-=1.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(keyCode == LEFT){
		rotZ+=1.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(keyCode == RIGHT){
		rotZ-=1.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(key=='a'){
		scaleOutIn+=0.05;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(key=='s'){
		scaleOutIn-=0.05;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(key=='i' || key=='I' ){
		shiftZ+=50.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(key=='k' || key=='K' ){
		shiftZ-=50.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(key=='l' || key=='L' ){
		shiftX-=50.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
	if(key=='j' || key=='J' ){
		shiftX+=50.0;
		makeMapGraphic();
		makePathGraphic();
		makePlacesGraphic();
		makeLiveGraphic();
	}
}



void makePathGraphic(){
	pointsGraph.beginDraw();
	pointsGraph.clear();
	float _size=0.0;
	float _l=0.0;
	pointsGraph.rotateX(radians(rotX));
	pointsGraph.rotateZ(radians(rotZ));
	pointsGraph.noFill();
	if(points.size()>0){
		for(int i=0; i<points.size(); i ++){
			pointsGraph.stroke(125+(0.0063*i),125-(0.0063*i),0,100);
			PVector thisP=points.get(i);

			pointsGraph.pushMatrix();
			pointsGraph.translate(map(thisP.x,mapPointA.x,mapPointB.x,xMin,xMax) *scaleOutIn +shiftX,thisP.y, map(thisP.z,mapPointA.y,mapPointB.y,zMin,zMax) *scaleOutIn +shiftZ);
			_size=8+(0.00000035*i);
			_l=random(60,60)*scaleOutIn;
			pointsGraph.blendMode(BLEND);

			pointsGraph.push();
			pointsGraph.translate(0,-_l,0);
			pointsGraph.strokeWeight(_size);
			pointsGraph.point(0,0,0);
			pointsGraph.pop();
			pointsGraph.stroke(0+(125.0063*i),125-(0.0063*i),0,100);
			pointsGraph.strokeWeight(1.0);
			pointsGraph.line(0,0,0,-_l);
			pointsGraph.popMatrix();


			if(i>1){
				PVector thisPL=points.get(i-1);
				pointsGraph.stroke(255-(i*0.0025),0+(i*0.0025),50+(i*0.0025));
				pointsGraph.strokeWeight(0.5);
				pointsGraph.line(map(thisP.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn +shiftX,thisP.y, map(thisP.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn +shiftZ,
				map(thisPL.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn +shiftX,thisPL.y, map(thisPL.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn + shiftZ);
			}
		}
	}
	pointsGraph.endDraw();
}

int nearIndex=0;
PVector nearPoint= new PVector(0,0);
PVector nearPointR = new PVector(0,0);
void comparePoints(){
	float mY = map (mouseY,0,height,zMin,zMax);
	float mX = map (mouseX,0,width,xMin,xMax);
	PVector mU= new PVector(mX,height-150,mY);
	if(points.size()>0){
		for(int i=0;i<points.size();i++){
			
			PVector thisP = new PVector(points.get(i).x, height-150,points.get(i).z);
			PVector thisPR = thisP;
			 
			thisP= new PVector(map(thisP.x,mapPointA.x,mapPointB.x,xMin,xMax),thisP.y,map(thisP.z,mapPointA.y,mapPointB.y,zMin,zMax));
			
			if(mU.dist(thisP)<60){
				nearIndex=i;
				nearPoint=thisP;
				nearPointR = thisPR;
			}
		}
	}
}





PImage mapZH;
PImage mapZHrzd;
PGraphics mapZH_Gen;
ArrayList<PVector> pointsMapGenNature = new ArrayList<PVector>();
ArrayList<PVector> pointsMapGenHuman = new ArrayList<PVector>();
ArrayList<PVector> pointsMapGenWater = new ArrayList<PVector>();
void loadMap(){
	mapZH = loadImage("maps/satellite_zurich_bw.png");
	mapZHrzd= mapZH;
	mapZHrzd.resize(width,height);

	mapZH_Gen = createGraphics(width,height,P3D);
}
float brr=0;
void generateMapGraphic(){
	int step = int(15 + (1/scaleOutIn));
	// PVector thisMouse=new PVector
	for(int x=0;x<mapZHrzd.width-step;x+=step){
		for(int y=0;y<mapZHrzd.height-step;y+=step){
			int loc = x+y * mapZHrzd.width;
			color currColor = mapZHrzd.pixels[loc];
			float howBright= brightness(currColor);
			float _x = map(x, 0, width,xMin,xMax);
			float _y = map(y, 0, height,zMin,zMax);


			// for satellite image
			if(howBright<=92 && howBright>=88 ){
				pointsMapGenNature.add(new PVector(_x,height-150,_y));
			}
			if(howBright<50 ){
				pointsMapGenHuman.add(new PVector(_x,height-150,_y));
			}
			if(howBright>120){
				pointsMapGenWater.add(new PVector(_x,height-150,_y));
			}
		}
	}

}

void makeMapGraphic(){
	mapZH_Gen.beginDraw();
	mapZH_Gen.clear();
	mapZH_Gen.rotateX(radians(rotX));
	mapZH_Gen.rotateZ(radians(rotZ));
	mapZH_Gen.fill(50,50,200);
	mapZH_Gen.noStroke();

	if(pointsMapGenWater.size() > 0){
		for(int i = 0; i < pointsMapGenWater.size(); i ++){
			PVector thisP=pointsMapGenWater.get(i);
			thisP = new PVector(thisP.x*scaleOutIn +shiftX,thisP.y,thisP.z*scaleOutIn + shiftZ);
			mapZH_Gen.pushMatrix();
			mapZH_Gen.translate(thisP.x,thisP.y,thisP.z);
			mapZH_Gen.pushMatrix();
			mapZH_Gen.rotateX(radians(90));
			mapZH_Gen.textSize(12);
			mapZH_Gen.text("water",-8,0);
			mapZH_Gen.popMatrix();
			mapZH_Gen.popMatrix();
		}
	}

	mapZH_Gen.fill(180,180,180,15);
	mapZH_Gen.noStroke();
	mapZH_Gen.strokeWeight(0.5);
	float _lboxHeight=random(10,75);
	if(pointsMapGenHuman.size() > 0){
		for(int i = 0; i < pointsMapGenHuman.size(); i ++){
			PVector thisP=pointsMapGenHuman.get(i);
			thisP = new PVector(thisP.x*scaleOutIn +shiftX,thisP.y,thisP.z*scaleOutIn +shiftZ);
			mapZH_Gen.pushMatrix();
			_lboxHeight=random(10,75);
			mapZH_Gen.translate(thisP.x,thisP.y-_lboxHeight/2,thisP.z);
			mapZH_Gen.box(10,_lboxHeight,10);
			mapZH_Gen.popMatrix();
		}
	}
	mapZH_Gen.fill(140,255,140);
	mapZH_Gen.noStroke();
	if(pointsMapGenNature.size() > 0){
		for(int i = 0; i < pointsMapGenNature.size(); i ++){
			PVector thisP=pointsMapGenNature.get(i);
			thisP = new PVector(thisP.x*scaleOutIn +shiftX,thisP.y,thisP.z*scaleOutIn+shiftZ);
			mapZH_Gen.pushMatrix();
			mapZH_Gen.translate(thisP.x,thisP.y,thisP.z);
			mapZH_Gen.box(5,50,5);
			mapZH_Gen.popMatrix();
		}
	}

	mapZH_Gen.endDraw();
}

void displayMap(){
	image(mapZH_Gen, 0, 0, width, height);
}

PGraphics cursorGraph;
PGraphics focusPoint;
void createCursorGraphic(){
	cursorGraph = createGraphics(width,height,P3D);
	focusPoint = createGraphics(width,height,P3D);
	placesGraphic = createGraphics(width,height,P3D);
	livePosGraphic = createGraphics(width,height,P3D);
}

void customCursor(){
	float mY = map (mouseY,0,height,zMin,zMax)*scaleOutIn +shiftZ;
	float mX = map (mouseX,0,width,xMin,xMax)*scaleOutIn +shiftX;
	cursorGraph.beginDraw();
	cursorGraph.clear();
	cursorGraph.push();
	cursorGraph.rotateX(radians(rotX));
	cursorGraph.rotateZ(radians(rotZ));
	cursorGraph.noFill();
	cursorGraph.strokeWeight(0.75);
	cursorGraph.stroke(255,4,206);
	cursorGraph.line(mX,height-150,zMin,mX,height-150,height*4);
	cursorGraph.line(xMin,height-150,mY,xMax,height-150,mY);
	cursorGraph.pop();
	cursorGraph.endDraw();
	image(cursorGraph,0,0,width,height);
}

void displayFocusPoint(){
	
  	softenPos = new PVector( softenPos.x*0.85 + nearPoint.x*0.15 , height-150,softenPos.z*0.85 + nearPoint.z*0.15);
	focusPoint.beginDraw();

	focusPoint.clear();
	focusPoint.rotateX(radians(rotX));
	focusPoint.rotateZ(radians(rotZ));
	
	focusPoint.pushMatrix();
	focusPoint.translate(softenPos.x*scaleOutIn +shiftX,height-150,softenPos.z*scaleOutIn + shiftZ);
	focusPoint.stroke(255,0,0);
	focusPoint.strokeWeight(2);
	focusPoint.noFill();
	focusPoint.push();
	focusPoint.rotateX(radians(-rotX));	
	focusPoint.rotateZ(radians(-rotZ));
	focusPoint.ellipse(0,-15,120,120);
	focusPoint.pop();
	focusPoint.popMatrix();
	focusPoint.pushMatrix();
	focusPoint.translate(softenPos.x*scaleOutIn +shiftX,height-650,softenPos.z*scaleOutIn + shiftZ);
	focusPoint.fill(255,0,0);
	focusPoint.noStroke();
	focusPoint.textSize(24);
	focusPoint.textAlign(CENTER,CENTER);
	focusPoint.push();
	focusPoint.rotateX(radians(-rotX));
	focusPoint.rotateZ(radians(-rotZ));
	focusPoint.text("Tracked Point # " + nearIndex,0,0);
	focusPoint.pop();
	focusPoint.popMatrix();
	focusPoint.stroke(255,0,0);
	focusPoint.strokeWeight(1);
	focusPoint.line(softenPos.x*scaleOutIn +shiftX,height-620,softenPos.z*scaleOutIn + shiftZ,softenPos.x*scaleOutIn+shiftX,height-240,softenPos.z*scaleOutIn + shiftZ);

	focusPoint.endDraw();
	image(focusPoint,0,0,width,height);
	fill(0,200,100);
	textAlign(LEFT,TOP);
	textSize(16);
	if(mouseX>width/2){
		text("longitude : " + nearPointR.x+" , latitude : "+nearPointR.z, 50,200);
	}else{
		text("longitude : " + nearPointR.x+" , latitude : "+nearPointR.z, 50,200);	
	}
}

PGraphics placesGraphic;
void places(){


}


// ---------------- updating the list of places
PVector [] places ;
String [] placesLabel;

void updatePlaces(){

	String [] lines = loadStrings("placesList/places.csv");
	places= new PVector[lines.length];
	placesLabel= new String[lines.length];
	int _indx=0;
    for (String line : lines) {
          String[] pieces = split(line, ',');
         	for(int i = 0; i< pieces.length;i++){
         		if(i==0){
         			placesLabel[_indx]=pieces[i];
         			places[_indx] = new PVector( float(pieces[i+2]), height-150, float(pieces[i+1])) ;
         		}
         	}
         	_indx++;
    }
}

void makePlacesGraphic(){
	placesGraphic.beginDraw();
	placesGraphic.clear();
	placesGraphic.rotateX(radians(rotX));
	placesGraphic.rotateZ(radians(rotZ));
	for (int i=0; i < places.length;i++){
		PVector thisPlace = new PVector(places[i].x, height-150, places[i].z);
		placesGraphic.stroke(0,100,255);
		placesGraphic.strokeWeight(15);
		placesGraphic.point(map(thisPlace.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn +shiftX,thisPlace.y-100,map(thisPlace.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn + shiftZ);
		placesGraphic.strokeWeight(4);
		placesGraphic.point(map(thisPlace.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn +shiftX,thisPlace.y,map(thisPlace.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn + shiftZ);
		placesGraphic.strokeWeight(2);
		placesGraphic.line(map(thisPlace.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn+shiftX,thisPlace.y-100,map(thisPlace.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn + shiftZ,
			map(thisPlace.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn+shiftX,thisPlace.y,map(thisPlace.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn +shiftZ
			);
		placesGraphic.push();
		placesGraphic.translate(map(thisPlace.x,mapPointA.x,mapPointB.x,xMin,xMax)*scaleOutIn+shiftX, thisPlace.y-100,map(thisPlace.z,mapPointA.y,mapPointB.y,zMin,zMax)*scaleOutIn +shiftZ);
		placesGraphic.rotateX(radians(-rotX));
		placesGraphic.rotateZ(radians(-rotZ));
		placesGraphic.fill(0,100,255);
		placesGraphic.textSize(16);
		placesGraphic.text(placesLabel[i], -25,-40);
		placesGraphic.pop();



	}
			placesGraphic.endDraw();

}
void displayPlaces(){
	image(placesGraphic,0,0,width,height);
}


//  references
// https://mapstyle.withgoogle.com/
//  https://maps.googleapis.com/maps/api/staticmap?key=YOUR_API_KEY&center=47.3678172663858,8.554274323600279&zoom=13&format=png&maptype=roadmap&style=element:labels%7Cvisibility:off&style=feature:administrative%7Celement:geometry%7Cvisibility:off&style=feature:administrative.land_parcel%7Cvisibility:off&style=feature:administrative.neighborhood%7Cvisibility:off&style=feature:landscape.man_made%7Celement:geometry%7Ccolor:0xdbffed&style=feature:landscape.natural%7Celement:geometry.fill%7Ccolor:0x89c9a7&style=feature:landscape.natural.landcover%7Celement:geometry.fill%7Ccolor:0x131715&style=feature:landscape.natural.terrain%7Celement:geometry.fill%7Ccolor:0x536e5f&style=feature:poi%7Celement:geometry%7Ccolor:0xf2feea%7Cvisibility:on&style=feature:road%7Cvisibility:off&style=feature:road%7Celement:geometry%7Cvisibility:off&style=feature:transit%7Celement:geometry%7Cvisibility:off&style=feature:water%7Celement:geometry%7Ccolor:0xfafcff&size=480x360 
// https://docs.mapbox.com/mapbox-gl-js/api/
// https://www.youtube.com/watch?v=JJatzkPcmoI
