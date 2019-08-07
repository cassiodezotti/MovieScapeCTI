import oscP5.*;
import netP5.*;
  
public class Communication{
  private OscP5 oscP5;
  private NetAddress pdAddress;
  
  public Communication(String pdIp, int pdPort, int myPort){
    this.oscP5 = new OscP5(this, myPort);
    this.pdAddress = new NetAddress(pdIp, pdPort); //localhost: "127.0.0.1" "192.168.15.16" // "192.168.15.1"
  }
  
  public void sendScene(Scene scene){
    if(!scene.activeSkeletons.isEmpty()){
      for(Skeleton skeleton:scene.activeSkeletons.values()){
        /*this.sendMessageToElenaProject(skeleton);
        this.sendKinectSkeleton(skeleton);
        this.sendGrainParameters(skeleton);
        this.sendVideoParameter(skeleton);
        this.sendSteeringWheel(skeleton);
        */
      }
    }
  }
  
  /*private void sendMessageToElenaProject(Skeleton skeleton){
    OscMessage messageToElenaProject;
    
    messageToElenaProject = new OscMessage("/centerOfMassHeightAdjusted:");
    messageToElenaProject.add(skeleton.centerOfMassHeightAdjusted);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/dispersion:");
    messageToElenaProject.add(skeleton.dispersion);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/leftHandPollock.activationDirectionCode:");
    messageToElenaProject.add(skeleton.leftHandPollock.activationDirectionCode);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/rightHandPollock.activationDirectionCode:");
    messageToElenaProject.add(skeleton.rightHandPollock.activationDirectionCode);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/leftHandRondDuBras.activatedDirectionCode:");
    messageToElenaProject.add(skeleton.leftHandRondDuBras.activatedDirectionCode);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/rightHandRondDuBras.activatedDirectionCode:");
    messageToElenaProject.add(skeleton.rightHandRondDuBras.activatedDirectionCode);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/momentum.averageFluid:");
    messageToElenaProject.add(skeleton.momentum.averageFluid);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/momentum.averageHarsh:");
    messageToElenaProject.add(skeleton.momentum.averageHarsh);
    this.oscP5.send(messageToElenaProject, pdAddress);
    
    messageToElenaProject = new OscMessage("/momentum.averageTotal:");
    messageToElenaProject.add(skeleton.momentum.averageTotal);
    this.oscP5.send(messageToElenaProject, pdAddress);
  }*/
  
  private void sendSteeringWheel(Skeleton skeleton){
    OscMessage messageToVideoSphere = new OscMessage("/steeringWheelRollStep:");
    messageToVideoSphere.add(skeleton.steeringWheel.rollStep);
    this.oscP5.send(messageToVideoSphere, pdAddress);
    messageToVideoSphere = new OscMessage("/steeringWheelPitchStep:");
    messageToVideoSphere.add(skeleton.steeringWheel.pitchStep);
    this.oscP5.send(messageToVideoSphere, pdAddress);
  }
  
  private void sendKinectSkeleton(Skeleton skeleton){ 
    OscMessage messageToPd = new OscMessage("/indexColor:");
    messageToPd.add(skeleton.indexColor);
    this.oscP5.send(messageToPd, pdAddress);
    
    messageToPd = new OscMessage("/handStates:");
    messageToPd.add(skeleton.estimatedHandRadius[0]);
    messageToPd.add(skeleton.estimatedHandRadius[1]);
    this.oscP5.send(messageToPd, pdAddress);
    
    for (int jointType = 0; jointType<25 ; jointType++){
      messageToPd = new OscMessage("/joint" + Integer.toString(jointType) + ":");
      messageToPd.add(skeleton.joints[jointType].trackingState);
      messageToPd.add(skeleton.joints[jointType].estimatedPosition.x);
      messageToPd.add(skeleton.joints[jointType].estimatedPosition.y);
      messageToPd.add(skeleton.joints[jointType].estimatedPosition.z);
      messageToPd.add(skeleton.joints[jointType].estimatedOrientation.real);
      messageToPd.add(skeleton.joints[jointType].estimatedOrientation.vector.x);
      messageToPd.add(skeleton.joints[jointType].estimatedOrientation.vector.y);
      messageToPd.add(skeleton.joints[jointType].estimatedOrientation.vector.z);
      this.oscP5.send(messageToPd, pdAddress);
    }
  }
  
  private void sendGrainParameters(Skeleton skeleton,Sphere sphere){
    PVector relativePos = skeleton.scene.floor.toFloorCoordinateSystem(skeleton.joints[SPINE_BASE].estimatedPosition);
    float realXPosition = relativePos.x;
    float realZPosition = relativePos.z;
    if(skeleton.scene.floor.isCalibrated){
      realXPosition = constrain(map((relativePos.x),-((skeleton.scene.floor.dimensions.x)/2),((skeleton.scene.floor.dimensions.x)/2),1,0),0,1);
      realZPosition = constrain(map((relativePos.z),-((skeleton.scene.floor.dimensions.z)/2),((skeleton.scene.floor.dimensions.z)/2),1,0),0,1);
    }
    OscMessage messageToPd = new OscMessage("/Ready");
    messageToPd = new OscMessage("/indexVideo");
    messageToPd.add(sphere.currentVideo);
    //println("\nindexVideo: "+sphere.currentVideo);
    this.oscP5.send(messageToPd, pdAddress);
    
    messageToPd = new OscMessage("/zPos");
    
    messageToPd.add(realZPosition);
    //println("\nzPos: "+realZPosition);
    this.oscP5.send(messageToPd, pdAddress);
        
    
    messageToPd = new OscMessage("/xPos");
    
    messageToPd.add(realXPosition);
    //println("\nXpos: "+realXPosition);
    this.oscP5.send(messageToPd, pdAddress);
    
    
    println("\n\n\n");
    
    /*messageToPd = new OscMessage("/mid_z");
    messageToPd.add(map((skeleton.joints[SPINE_BASE].estimatedPosition.z),0.4,3.5,0,1));
    this.oscP5.send(messageToPd, pdAddress);
    messageToPd = new OscMessage("/hand_left_x");
    messageToPd.add(map((skeleton.joints[HAND_LEFT].estimatedPosition.x),-1.5,1,0,1));
    this.oscP5.send(messageToPd, pdAddress);
    messageToPd = new OscMessage("/hand_left_y");
    messageToPd.add(map((skeleton.joints[HAND_LEFT].estimatedPosition.y),-1.5,1,0,1));
    this.oscP5.send(messageToPd, pdAddress);
    messageToPd = new OscMessage("/hand_right_x");
    messageToPd.add(map((skeleton.joints[HAND_RIGHT].estimatedPosition.x),-1.5,1,0,1));
    this.oscP5.send(messageToPd, pdAddress);
    messageToPd = new OscMessage("/hand_right_y");
    messageToPd.add(map((skeleton.joints[HAND_RIGHT].estimatedPosition.y),-1.5,1,0,1));
    this.oscP5.send(messageToPd, pdAddress);*/
  }
  
  private void sendVideoParameter(Skeleton skeleton){
    OscMessage messageToPd = new OscMessage("/Ready");  
    this.oscP5.send(messageToPd, pdAddress);
    messageToPd = new OscMessage("/Elastic");
    messageToPd.add((skeleton.distanceBetweenHands));
    this.oscP5.send(messageToPd,pdAddress);
  }
}
