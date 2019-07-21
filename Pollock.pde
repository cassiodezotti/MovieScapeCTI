/**
 * Pollock: Trigger Affordance that quantifies the "throwing" movement of each hand.
 */
public class Pollock{
  String whichHand;
  private Joint handJoint;
  private Joint shoulderJoint;
  private Joint headJoint;
  private Joint spineShoulderJoint;
  private PVector shoulderToHandPosition;
  private PVector shoulderToHandDirection; // Normalized shoulderToHandPosition
  private PVector shoulderToHandVelocity = new PVector(0, 0, 0);
  private float shoulderToHandSpeed = 0;
  private final float speedThreshold = 0.75;
  private boolean wasAboveSpeedThreshold = false;
  private boolean isAboveSpeedThreshold = false;
  private int activationMillis;
  private int fadeOutTime = 1000; // millisseconds
  private PVector headToHand;
  private PVector activationDirectionGlobal; // vector from head to hand normalized.
  private PVector activationDirectionRelativeToBody; // vector from head to hand normalized, relative to shoulder coordinate system.
  private final int numberOfAltitudes = 3; // max: 9
  private final int numberOfAzimuths = 4; // max: 9
  private final float azimuthDiscretization = TWO_PI/this.numberOfAzimuths; // azimuth discretization (in radians)
  private final float altitudeDiscretization = PI/(this.numberOfAltitudes+1); // azimuth discretization (in radians)
  private final int forwardIsBetweenPossibleDirections = 1; // 1:forward is between possible directions. 0:forward is a possible direction.
  private Matrix possibleDirections = new Matrix(numberOfAltitudes*numberOfAzimuths, 3);
  private Matrix projectionInEachPossibleDirectionVector = new Matrix(numberOfAltitudes*numberOfAzimuths, 1);
  private int activationDirectionIndex = 0;
  private int activationDirectionCode; // dozen: azimuth. unit: altitude.
  private int activationDirectionAltitude;
  private int activationDirectionAzimuth;
  
  Pollock(Skeleton skeleton, String whichHand){
    this.whichHand = whichHand;
    if(whichHand == "LEFT"){
      this.handJoint = skeleton.joints[HAND_LEFT];
      this.shoulderJoint = skeleton.joints[SHOULDER_LEFT];
    }else if(whichHand == "RIGHT"){
      this.handJoint = skeleton.joints[HAND_RIGHT];
      this.shoulderJoint = skeleton.joints[SHOULDER_RIGHT];
    }
    this.headJoint = skeleton.joints[HEAD];
    this.spineShoulderJoint = skeleton.joints[SPINE_SHOULDER];
    this.buildPossibleDirections();
  }
  
  /**
   * Build a Matrix containing the vectors for all possible directions of the pollock, based on the chosen number of azimuths and altitudes.
   */
  private void buildPossibleDirections(){
    int directionIndex = 0;
    for(int altitudeIndex=0; altitudeIndex<this.numberOfAltitudes; altitudeIndex++){
      for(int azimuthIndex=0; azimuthIndex<this.numberOfAzimuths; azimuthIndex++){
        this.possibleDirections.set(directionIndex, 0, sin((altitudeIndex+1)*this.altitudeDiscretization)*sin((azimuthIndex+((float)forwardIsBetweenPossibleDirections)/2)*this.azimuthDiscretization));
        this.possibleDirections.set(directionIndex, 1, cos((altitudeIndex+1)*this.altitudeDiscretization));
        this.possibleDirections.set(directionIndex, 2, sin((altitudeIndex+1)*this.altitudeDiscretization)*cos((azimuthIndex+((float)forwardIsBetweenPossibleDirections)/2)*this.azimuthDiscretization));
        directionIndex++;
      }
    }
  }
  
  /**
   * Updates the pollock calculations.
   */
  private void update(){
    this.shoulderToHandPosition = PVector.sub(this.handJoint.estimatedPosition, this.shoulderJoint.estimatedPosition);
    this.shoulderToHandDirection = PVector.div(this.shoulderToHandPosition, this.shoulderToHandPosition.mag());
    this.shoulderToHandVelocity = PVector.sub(this.handJoint.estimatedVelocity, this.shoulderJoint.estimatedVelocity);
    this.shoulderToHandSpeed = PVector.dot(this.shoulderToHandVelocity, this.shoulderToHandDirection);
    this.isAboveSpeedThreshold = this.shoulderToHandSpeed > this.speedThreshold;
    
    if(this.isAboveSpeedThreshold){
      this.headToHand = PVector.sub(this.handJoint.estimatedPosition, this.headJoint.estimatedPosition);
    } else if(this.wasAboveSpeedThreshold){ // Pollock is activated here
      this.activationMillis = millis();
      this.findDirection();
    }
    this.wasAboveSpeedThreshold = this.isAboveSpeedThreshold;
  }
  
  /**
   * Find the possible direction that has the largest dot product with the activation direction.   
   */
  private void findDirection(){
    this.activationDirectionGlobal = PVector.div(this.headToHand, headToHand.mag());
    this.activationDirectionRelativeToBody = new PVector(PVector.dot(this.activationDirectionGlobal, this.spineShoulderJoint.estimatedDirectionX), 
                                                         PVector.dot(this.activationDirectionGlobal, this.spineShoulderJoint.estimatedDirectionY), 
                                                         PVector.dot(this.activationDirectionGlobal, this.spineShoulderJoint.estimatedDirectionZ));
    Matrix activationDirectionRelativeToBodyVector = new Matrix(new double[] {this.activationDirectionRelativeToBody.x, this.activationDirectionRelativeToBody.y, this.activationDirectionRelativeToBody.z}, 3);
    this.projectionInEachPossibleDirectionVector = this.possibleDirections.times(activationDirectionRelativeToBodyVector);
    double max = 0;
    int possibleDirectionIndex = 0;
    for(int possibleDirectionAltitude=0; possibleDirectionAltitude<this.numberOfAltitudes; possibleDirectionAltitude++){
      for(int possibleDirectionAzimuth=0; possibleDirectionAzimuth<this.numberOfAzimuths; possibleDirectionAzimuth++){
        if(this.projectionInEachPossibleDirectionVector.get(possibleDirectionIndex, 0) > max){
          this.activationDirectionAltitude = possibleDirectionAltitude;
          this.activationDirectionAzimuth = possibleDirectionAzimuth;
          this.activationDirectionIndex = possibleDirectionIndex;
          this.activationDirectionCode = this.activationDirectionAzimuth*10 + this.activationDirectionAltitude;
          max = this.projectionInEachPossibleDirectionVector.get(possibleDirectionIndex, 0);
        }
        possibleDirectionIndex++;
      }
    }
    println("pollockCode: "+this.activationDirectionCode);
  }
  
  /**
   * Draw the representations of the pollock affordance.
   */
  private void draw(){
    //this.drawTriggerVector();
    //this.drawPossibleDirectionsInTheBody();
    this.drawPossibleDirectionsInTheOrigin();
    
    if(millis()-this.activationMillis < this.fadeOutTime){
      this.drawHeadToHandVector();
      //this.drawProjectionsInPossibleDirectionsInTheOrigin();
      //this.drawHeadToHandVectorInTheOrigin();
      this.drawActivationDirectionInTheOrigin();
    }
  }
  
  /**
   * Draw the vector from shoulder to arm. Its stroke alpha represents the velocity of the pollock.
   */
  private void drawTriggerVector(){
    pushMatrix();
    strokeWeight(5);
    stroke(0, 0, 0, max(0, min(255, map(this.shoulderToHandSpeed, 0, 2, 0, 255))));
    translate(reScaleX(this.shoulderJoint.estimatedPosition.x, "pollock.draw"),
              reScaleY(this.shoulderJoint.estimatedPosition.y, "pollock.draw"),
              reScaleZ(this.shoulderJoint.estimatedPosition.z, "pollock.draw"));
    PVector shoulderToHand = PVector.sub(this.handJoint.estimatedPosition, this.shoulderJoint.estimatedPosition);
    line(0, 0, 0, reScaleX(shoulderToHand.x, "pollock.draw"), reScaleY(shoulderToHand.y, "pollock.draw"), reScaleZ(shoulderToHand.z, "pollock.draw"));
    popMatrix();
  }
  
  /**
   * Draw the vector from head to hand, which is the direction of the activation.
   */
  private void drawHeadToHandVector(){
    pushMatrix();
    strokeWeight(5);
    stroke(0, 0, 0, 128);
    translate(reScaleX(this.headJoint.estimatedPosition.x, "pollock.draw"),
              reScaleY(this.headJoint.estimatedPosition.y, "pollock.draw"),
              reScaleZ(this.headJoint.estimatedPosition.z, "pollock.draw")); 
    line(0, 0, 0, reScaleX(this.headToHand.x, "pollock.draw"), reScaleY(this.headToHand.y, "pollock.draw"), reScaleZ(this.headToHand.z, "pollock.draw"));
    popMatrix();
  }
  
  /**
   * Draw the vector from head to hand in the origin, which is the direction of the activation in global CSys.
   */
  private void drawHeadToHandVectorInTheOrigin(){
    pushMatrix();
    strokeWeight(5);
    stroke(0, 0, 0, 128);
    line(0, 0, 0, reScaleX(this.headToHand.x, "pollock.draw"), reScaleY(this.headToHand.y, "pollock.draw"), reScaleZ(this.headToHand.z, "pollock.draw"));
    popMatrix();
  }
  
  /**
   * Draw the activated possible direction in the origin.
   */
  private void drawActivationDirectionInTheOrigin(){
    PVector possibleDirectionActivated = new PVector((float)this.possibleDirections.get(this.activationDirectionIndex, 0), 
                                                     (float)this.possibleDirections.get(this.activationDirectionIndex, 1), 
                                                     (float)this.possibleDirections.get(this.activationDirectionIndex, 2));
    pushMatrix();
    strokeWeight(5);
    // Draw activationDirectionRelativeToBody:
    stroke(0, 0, 0, 128);
    line(0, 0, 0, reScaleX(this.activationDirectionRelativeToBody.x, "pollock.draw"), reScaleY(this.activationDirectionRelativeToBody.y, "pollock.draw"), reScaleZ(this.activationDirectionRelativeToBody.z, "pollock.draw"));
    
    stroke(100, 0, 200, 255);
    // Draw possibleDirectionActivated:
    line(0, 0, 0, reScaleX(possibleDirectionActivated.x, "pollock.draw"), reScaleY(possibleDirectionActivated.y, "pollock.draw"), reScaleZ(possibleDirectionActivated.z, "pollock.draw"));
    
    // Draw shell:
    Quaternion azimuthClockwiseRotation =      axisAngleToQuaternion(0, 1, 0, this.azimuthDiscretization/2); // clockwise half rotation
    Quaternion azimuthAntiClockwiseRotation =  axisAngleToQuaternion(0, 1, 0, -this.azimuthDiscretization/2); // clockwise half rotation
    Quaternion altitudeClockwiseRotation =     axisAngleToQuaternion(rotateVector(new PVector(possibleDirectionActivated.x, 0, possibleDirectionActivated.z), new PVector(0, 1, 0), HALF_PI), this.altitudeDiscretization/2); // clockwise half rotation
    Quaternion altitudeAntiClockwiseRotation = axisAngleToQuaternion(rotateVector(new PVector(possibleDirectionActivated.x, 0, possibleDirectionActivated.z), new PVector(0, 1, 0), HALF_PI), -this.altitudeDiscretization/2); // clockwise half rotation
    
    PVector vertex1 = rotateVector(rotateVector(possibleDirectionActivated, altitudeClockwiseRotation)    , azimuthClockwiseRotation);
    PVector vertex2 = rotateVector(rotateVector(possibleDirectionActivated, altitudeAntiClockwiseRotation), azimuthClockwiseRotation);
    PVector vertex3 = rotateVector(rotateVector(possibleDirectionActivated, altitudeAntiClockwiseRotation), azimuthAntiClockwiseRotation);
    PVector vertex4 = rotateVector(rotateVector(possibleDirectionActivated, altitudeClockwiseRotation)    , azimuthAntiClockwiseRotation);
    
    fill(100, 0, 200, 255*(1-(float)((millis()-this.activationMillis)/(float)this.fadeOutTime)));
    beginShape();
    vertex(vertex1, "drawActivationDirectionInTheOrigin");
    vertex(vertex2, "drawActivationDirectionInTheOrigin");
    vertex(vertex3, "drawActivationDirectionInTheOrigin");
    vertex(vertex4, "drawActivationDirectionInTheOrigin");
    endShape(CLOSE);
    popMatrix();
  }
  
  /**
   * Draw the possible directions in the origin, with its alpha representing the projection of the activated direction.
   */
  private void drawProjectionsInPossibleDirectionsInTheOrigin(){
    int directionIndex = 0;
    for(int altitudeIndex=0; altitudeIndex<this.numberOfAltitudes; altitudeIndex++){
      for(int azimuthIndex=0; azimuthIndex<this.numberOfAzimuths; azimuthIndex++){
        pushMatrix();
        strokeWeight(5);
        float colorIntensity = max(0, map((float)projectionInEachPossibleDirectionVector.get(directionIndex, 0), 0, 1, 0, 255));
        //println("color intensity: "+ colorIntensity);
        stroke(100, 0, 200, colorIntensity);
        PVector directionToDraw = new PVector((float) this.possibleDirections.get(directionIndex, 0), (float) this.possibleDirections.get(directionIndex, 1), (float) this.possibleDirections.get(directionIndex, 2));
        line(0, 0, 0, reScaleX(directionToDraw.x, "pollock.draw"),
                      reScaleY(directionToDraw.y, "pollock.draw"),
                      reScaleZ(directionToDraw.z, "pollock.draw"));
        directionIndex++;
        popMatrix();
      }
    }
  }
  
  /**
   * Draw the possible directions in the origin.
   */
  private void drawPossibleDirectionsInTheOrigin(){
    int directionIndex = 0;
    for(int altitudeIndex=0; altitudeIndex<this.numberOfAltitudes; altitudeIndex++){
      for(int azimuthIndex=0; azimuthIndex<this.numberOfAzimuths; azimuthIndex++){
        pushMatrix();
        strokeWeight(2);
        stroke(0, 0, 0, 40);
        noFill();
        PVector directionToDraw = new PVector((float) this.possibleDirections.get(directionIndex, 0), 
                                              (float) this.possibleDirections.get(directionIndex, 1), 
                                              (float) this.possibleDirections.get(directionIndex, 2));
        
        // Draw shell:
        Quaternion azimuthClockwiseRotation =      axisAngleToQuaternion(0, 1, 0, this.azimuthDiscretization/2); // clockwise half rotation
        Quaternion azimuthAntiClockwiseRotation =  axisAngleToQuaternion(0, 1, 0, -this.azimuthDiscretization/2); // clockwise half rotation
        Quaternion altitudeClockwiseRotation =     axisAngleToQuaternion(rotateVector(new PVector(directionToDraw.x, 0, directionToDraw.z), new PVector(0, 1, 0), HALF_PI), this.altitudeDiscretization/2); // clockwise half rotation
        Quaternion altitudeAntiClockwiseRotation = axisAngleToQuaternion(rotateVector(new PVector(directionToDraw.x, 0, directionToDraw.z), new PVector(0, 1, 0), HALF_PI), -this.altitudeDiscretization/2); // clockwise half rotation
        
        PVector vertex1 = rotateVector(rotateVector(directionToDraw, altitudeClockwiseRotation)    , azimuthClockwiseRotation);
        PVector vertex2 = rotateVector(rotateVector(directionToDraw, altitudeAntiClockwiseRotation), azimuthClockwiseRotation);
        PVector vertex3 = rotateVector(rotateVector(directionToDraw, altitudeAntiClockwiseRotation), azimuthAntiClockwiseRotation);
        PVector vertex4 = rotateVector(rotateVector(directionToDraw, altitudeClockwiseRotation)    , azimuthAntiClockwiseRotation);
        
        beginShape();
        vertex(vertex1, "drawActivationDirectionInTheOrigin");
        vertex(vertex2, "drawActivationDirectionInTheOrigin");
        vertex(vertex3, "drawActivationDirectionInTheOrigin");
        vertex(vertex4, "drawActivationDirectionInTheOrigin");
        endShape(CLOSE);
        popMatrix();
        directionIndex++;
      }
    }
  }
  
  /**
   * Draw the possible directions in the origin.
   */
  private void drawPossibleDirectionsInTheBody(){
    int directionIndex = 0;
    for(int altitudeIndex=0; altitudeIndex<this.numberOfAltitudes; altitudeIndex++){
      for(int azimuthIndex=0; azimuthIndex<this.numberOfAzimuths; azimuthIndex++){
        pushMatrix();
        strokeWeight(2);
        stroke(100, 0, 200, 255);
        translate(reScaleX(this.spineShoulderJoint.estimatedPosition.x, "pollock.draw"),
                  reScaleY(this.spineShoulderJoint.estimatedPosition.y, "pollock.draw"),
                  reScaleZ(this.spineShoulderJoint.estimatedPosition.z, "pollock.draw"));
        PVector directionToDraw = new PVector((float) this.possibleDirections.get(directionIndex, 0), (float) this.possibleDirections.get(directionIndex, 1), (float) this.possibleDirections.get(directionIndex, 2));
        Quaternion directionToDrawQuaternion = new Quaternion(0, directionToDraw);
        PVector relativeDirectionToDraw = qMult(qConjugate(this.spineShoulderJoint.estimatedOrientation), qMult(directionToDrawQuaternion, this.spineShoulderJoint.estimatedOrientation)).vector;
        line(0, 0, 0, reScaleX(-relativeDirectionToDraw.x, "pollock.draw"),// esse sinal de menos é gambiarra
                      reScaleY(relativeDirectionToDraw.y, "pollock.draw"),
                      reScaleZ(relativeDirectionToDraw.z, "pollock.draw"));
        directionIndex++;
        popMatrix();
      }
    }
  }
}
