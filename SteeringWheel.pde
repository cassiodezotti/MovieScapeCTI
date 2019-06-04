/**
 * Abstraction of a steering wheel being grabbed by the user's hands. While grabbed (closed hands), it can be steered in 3D.
 * rollStep, pitchStep and yawStep should be used to increment the rotation each draw loop.
 */
class SteeringWheel{
  public Features features;
  public boolean grabbingSteeringWheel = false;
  public float rollAngle;
  public float rollSize;
  public float rollStep;
  public float pitchAngle;
  public float pitchSize;
  public float pitchStep;
  public float yawAngle;
  public float yawSize;
  public float yawStep;
  
  public SteeringWheel(Features features){
    this.features = features;
  }
  
  private void update(){
    //if(this.skeleton.estimatedHandRadius[0]<0.5 && this.skeleton.estimatedHandRadius[1]<0.5) this.grabbingSteeringWheel = true; else this.grabbingSteeringWheel = false;
    if(this.features.skeleton.estimatedHandRadius[0] + this.features.skeleton.estimatedHandRadius[1] < 0.75) this.grabbingSteeringWheel = true; else this.grabbingSteeringWheel = false;
    if(grabbingSteeringWheel){
      if(this.features.skeleton.scene.floor.isCalibrated){
        this.rollAngle = atan(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorY)/PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorX));
        this.rollSize = abs(sqrt(sq(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorX))+sq(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorY))));
        this.pitchAngle = atan(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorZ)/PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorY));
        this.pitchSize = abs(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorY));
        this.yawAngle = atan(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorZ)/PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorX));
        this.yawSize = abs(PVector.dot(this.features.vectorConnectingHands, this.features.skeleton.scene.floor.basisVectorX));
      } else {
        this.rollAngle = atan(this.features.vectorConnectingHands.y/this.features.vectorConnectingHands.x);
        this.rollSize = abs(sqrt(sq(this.features.vectorConnectingHands.x)+sq(this.features.vectorConnectingHands.y)));
        this.pitchAngle = atan(this.features.vectorConnectingHands.z/this.features.vectorConnectingHands.y);
        this.pitchSize = abs(this.features.vectorConnectingHands.y);
        this.yawAngle = atan(this.features.vectorConnectingHands.z/this.features.vectorConnectingHands.x);
        this.yawSize = abs(this.features.vectorConnectingHands.x);
      }
    } else {
      this.rollSize = 0;
      this.pitchSize = 0;
      this.yawSize = 0;
    }
    this.rollStep = this.rollAngle*this.rollSize/10;
    this.pitchStep = this.pitchAngle*this.pitchSize/10;
    this.yawStep = this.yawAngle*this.yawSize/10;
  }
}
