class Sphere {
  private int radius = 200;
  private int[] nClipsInLayer = {1, 7, 12, 14, 12, 7, 1};
  //private int[] nClipsInLayer = {0, 3, 7, 9, 11, 13, 11, 9, 7, 3, 0};
  private float[] startingFi = new float[nClipsInLayer.length];
  private float[] theta = new float[nClipsInLayer.length];
  private Clip[] clips;
  public float cameraRotX = 0;
  public float cameraRotY = 0;
  public float cameraTransZ = 0;
  public float transZSensibility = 1;
  public int currentVideo = 0;
  public boolean isPlaying = false;
    
  Sphere (PApplet pApplet, float clipDensity) {// clipDensity:Percentage of sphere area covered with clips.
    int totalNumberOfClips = 0;
    for (int layer=0; layer<nClipsInLayer.length; layer++){
      totalNumberOfClips+=nClipsInLayer[layer];
      this.startingFi[layer] = random(QUARTER_PI);
      this.theta[layer] = layer*PI/(nClipsInLayer.length-1);
    }
    float sumOfMovieAreas = clipDensity*PI*4*sq(this.radius);
    float areaPerMovie = sumOfMovieAreas/totalNumberOfClips;
    float movieSize = sqrt(areaPerMovie); // Average size of the video
    
    this.clips = new Clip[totalNumberOfClips];
    int clip=0;
    for (int layer = 0; layer < nClipsInLayer.length; layer++) {
      float fi = startingFi[layer]; // fi: "horizontal".
      for (float c = 0; c < nClipsInLayer[layer]; c++) {
        this.clips[clip] = new Clip(pApplet, this, movieSize, fi, this.theta[layer]);
        clip++;
        fi += TWO_PI/nClipsInLayer[layer];
      }
    }
  }
  
  public void display() {
    background(0);
    this.setCamera();
    this.isPlaying = false;
    for(Clip clip:this.clips){
      clip.display();
      if(clip.isFocus){
        this.isPlaying = true;
        this.currentVideo = clip.indexVideo;
      }
    }
    if(!isPlaying){
      this.currentVideo = 0;
    }
  }
  
  private void setCamera(){
    beginCamera();
    camera();
    translate(width/2, height/2, this.cameraTransZ);
    rotateX(this.cameraRotX);
    rotateY(this.cameraRotY);
    endCamera();
  }
}
