/*
  ToDo: JavaDoc
*/
import processing.video.*;
boolean drawSkeletonTool = true;
String userTextInput = "";
boolean gettingUserTextInput = false;
Scene scene = new Scene();
Sphere sphere;

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
  for(Skeleton skeleton:scene.activeSkeletons.values()){ 
    sphere.cameraRotX = sphere.cameraRotX + (map(skeleton.steeringWheel.position.y, 1, 1.5, PI/64, -PI/64))*sphere.transZSensibility;
    sphere.cameraRotY = sphere.cameraRotY + (skeleton.steeringWheel.yawStep)*sphere.transZSensibility;
    sphere.cameraTransZ = map(skeleton.steeringWheel.positionPercentageOfRoom.z, -1, 1, -sphere.radius/2, -2*sphere.radius);//ver porcentagem da sala, diminuir proximidade
    //cameraTransZ é negativo entao quanto aproxima tem q ficar menos negativo
    
    if (sphere.cameraTransZ > -(sphere.radius-0.2*sphere.radius)){
      sphere.transZSensibility = 0;
    }
    else if(sphere.cameraTransZ < -(sphere.radius+sphere.radius*0.4)) {
      sphere.transZSensibility = 1 ; 
    }
    else {
      //sphere.transZSensibility = map(sphere.cameraTransZ,-1*(sphere.radius/2),-sphere.radius*1.5,0,1);//ver qual é melhor
      sphere.transZSensibility = map(skeleton.steeringWheel.positionPercentageOfRoom.z,-1,1,0,1);
    }
    
    
  }
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
    if (!scene.drawScene){
      sphere.cameraRotX = ((sphere.cameraRotX - (mouseY - pmouseY)*PI/height)%TWO_PI);
      sphere.cameraRotY = ((sphere.cameraRotY + (mouseX - pmouseX)*PI/width)%TWO_PI);
    }
  }
}

void mouseWheel(MouseEvent event) {
  float zoom = event.getCount();
  println("zoom espera",sphere.cameraTransZ);
  println("Zomm real",scene.cameraTransZ);
  println("sensibilidade",sphere.transZSensibility);
  if(zoom < 0){
    scene.cameraTransZ = scene.cameraTransZ + 30;
    sphere.cameraTransZ = sphere.cameraTransZ + 10;
  }else{
    scene.cameraTransZ = scene.cameraTransZ - 30;
    sphere.cameraTransZ = sphere.cameraTransZ - 10;
  }
  
  if (sphere.cameraTransZ > -(sphere.radius/2)){
      sphere.transZSensibility = 0;
    }
    else if(sphere.cameraTransZ < -(sphere.radius+sphere.radius*0.4)) {
      sphere.transZSensibility = 1 ; 
    }
    else {
      sphere.transZSensibility = map(sphere.cameraTransZ,-1*(sphere.radius/2),-sphere.radius*1.5,0,1);
    }
}
