/*
  ToDo: JavaDoc
*/
import processing.video.*;
boolean drawSkeletonTool = true;
String userTextInput = "";
boolean gettingUserTextInput = false;
Scene scene = new Scene();
Sphere sphere;

int pdPort = 12000;
int myPort = 3001;
Communication communication = new Communication("192.168.15.16", pdPort, myPort);

void setup() {
  size(500, 500, P3D);
  sphere = new Sphere(this, 0.8);
  frameRate(scene.frameRate_);
  scene.init();
}

void draw() {
  scene.update();
  
  if(scene.drawScene){
    scene.draw(); // measuredSkeletons, jointOrientation, boneRelativeOrientation, handRadius, handStates
  } else{
    // Your animation algorithm should be placed here
    sphere.display(); //video sphere
  }
  for(Skeleton skeleton:scene.activeSkeletons.values()){ //example of consulting feature
    //sphere.cameraRotX = sphere.cameraRotX + skeleton.features.steeringWheel.pitchStep;
    //PVector relative = skeleton.scene.floor.toFloorCoordinateSystem(skeleton.centerOfMass);
    //PVector relativeHead = skeleton.scene.floor.toFloorCoordinateSystem(skeleton.joints[HEAD].estimatedPosition);
    //println("\nMedia Altura: "+relative.y);
    //println("\nAltura Cabeça: "+relativeHead.y);
    sphere.cameraRotX = sphere.cameraRotX + (map(skeleton.steeringWheel.position.y, 1, 1.5, PI/64, -PI/64))*sphere.transZSensibility;
    //println("\nTranslação Volante: "+10*map(skeleton.steeringWheel.position.y, 1, 1.5, PI/64, -PI/64)*sphere.transZSensibility);
    //println("\nCaremeraX: "+sphere.cameraRotX);
    sphere.cameraRotY = sphere.cameraRotY + (skeleton.steeringWheel.yawStep)*sphere.transZSensibility;
    //println("\nRotação Volante: "+ 10*(skeleton.steeringWheel.yawStep)*sphere.transZSensibility);
    //println("\nCaremeraY: "+sphere.cameraRotY);
    sphere.cameraTransZ = map(skeleton.steeringWheel.positionPercentageOfRoom.z, -1, 1, 250, -250);
    if (sphere.cameraTransZ > 260){
      sphere.transZSensibility = 0;
    }
    else if(sphere.cameraTransZ < 0) {
      sphere.transZSensibility = 1 ; 
    }
    else {
      sphere.transZSensibility = map(skeleton.steeringWheel.positionPercentageOfRoom.z,-1.5,1,0,1);
    }
    
    communication.sendGrainParameters(skeleton,sphere);
    
  }
  communication.sendScene(scene);
}

void keyPressed(){
  if(gettingUserTextInput){
    if (keyCode == BACKSPACE) {
      if (userTextInput.length() > 0) {
        userTextInput = userTextInput.substring(0, userTextInput.length()-1);
        println(userTextInput);
      }
    } else if (keyCode == DELETE) {
      userTextInput = "";
    } else if (keyCode == RETURN || keyCode == ENTER){
      gettingUserTextInput = false;
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      userTextInput = userTextInput + key;
      println(userTextInput);
    }
  } else{
    if(key == 'f') scene.floor.manageCalibration();
    if(key == 's') scene.drawScene = !scene.drawScene;
    if(key == 'm') scene.drawMeasured = !scene.drawMeasured;
    if(key == 'b') scene.drawBoneRelativeOrientation = !scene.drawBoneRelativeOrientation;
    if(key == 'j') scene.drawJointOrientation = !scene.drawJointOrientation;
    if(key == 'h') scene.drawHandRadius = !scene.drawHandRadius;
    if(key == 'H') scene.drawHandStates = !scene.drawHandStates;
    if(key == 'p') scene.drawPollock = !scene.drawPollock;
    if(key == 'r') scene.drawRondDuBras = !scene.drawRondDuBras;
    if(key == 'c') scene.drawCenterOfMass = !scene.drawCenterOfMass;
    if(key == 'M') scene.drawMomentum = !scene.drawMomentum;
  }
}

void mouseDragged() {
  if(mouseButton == CENTER){
    scene.cameraRotX = scene.cameraRotX - (mouseY - pmouseY)*PI/height;
    scene.cameraRotY = scene.cameraRotY - (mouseX - pmouseX)*PI/width;
  }
  if(mouseButton == LEFT){
    scene.cameraTransX = scene.cameraTransX + (mouseX - pmouseX);
    scene.cameraTransY = scene.cameraTransY + (mouseY - pmouseY);
  }
}

void mouseWheel(MouseEvent event) {
  float zoom = event.getCount();
  if(zoom < 0){
    scene.cameraTransZ = scene.cameraTransZ + 30;
  }else{
    scene.cameraTransZ = scene.cameraTransZ - 30;
  }
}
