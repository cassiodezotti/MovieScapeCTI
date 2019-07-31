class Clip {
  private Sphere sphere;
  private Movie movie;
  private float movieSpeed = 1;
  private float movieSize;
  private float movieAspectRatio;
  private float movieHeight;
  private float movieWidth;
  private int nOfDifferentClips = 12;
  private PVector centerDirection; // V1
  private PVector verticalDirection; // V2
  private PVector horizontalDirection; // V3
  private PVector centerPosition;
  private PVector vertex1, vertex2, vertex3, vertex4;  
  public int randomMovie = 0;
  public int indexVideo = 0;
  public boolean isFocus = false;
  
  public Clip(PApplet pApplet, Sphere sphere, float movieSize, float fi, float theta){
    this.sphere = sphere;
    this.movieSize = movieSize;
    this.centerDirection = new PVector(cos(fi) * sin(theta), -cos(theta), sin(fi) * sin(theta));
    this.verticalDirection = new PVector(cos(theta) * cos(fi), sin(theta), sin(fi)    * cos(theta));
    this.horizontalDirection = new PVector(-(sq(sin(theta))*sin(fi)+sq(cos(theta))*sin(fi)), 0, sq(cos(theta))*cos(fi)+sq(sin(theta))*cos(fi));
    this.centerPosition = PVector.mult(this.centerDirection, this.sphere.radius);
    
    this.randomMovie = (int) random(nOfDifferentClips-0.001);
    
    //this.movie = new Movie(pApplet, "silent_movie"+randomMovie+".mp4");   
    //this.movie = new Movie(pApplet, "aurora"+randomMovie+".mov");
    this.movie = new Movie(pApplet, "CTI"+randomMovie+".mp4");
    this.movie.speed(this.movieSpeed);
    this.movie.loop();
    this.movie.jump(random(this.movie.duration()));
    while(!this.movie.available()){ // Get stuck until movie is available.
      delay(50);
    }
    this.movie.read();  
    this.movie.pause();
    this.movieAspectRatio = this.movie.width/this.movie.height;
    this.movieHeight = this.movieSize*this.movieAspectRatio;
    this.movieWidth = this.movieSize/this.movieAspectRatio;
    this.vertex1 = PVector.mult(this.verticalDirection,-this.movieHeight/2).add(PVector.mult(this.horizontalDirection,-this.movieWidth/2));
    this.vertex2 = PVector.mult(this.verticalDirection,-this.movieHeight/2).add(PVector.mult(this.horizontalDirection, this.movieWidth/2));
    this.vertex3 = PVector.mult(this.verticalDirection, this.movieHeight/2).add(PVector.mult(this.horizontalDirection, this.movieWidth/2));
    this.vertex4 = PVector.mult(this.verticalDirection, this.movieHeight/2).add(PVector.mult(this.horizontalDirection,-this.movieWidth/2));
    println("clip loaded");
  }
  
  public void display(){
    PVector screenDirection = new PVector(cos(this.sphere.cameraRotY+HALF_PI)*sin(HALF_PI-this.sphere.cameraRotX), cos(HALF_PI-this.sphere.cameraRotX), sin(this.sphere.cameraRotY+HALF_PI)*sin(HALF_PI-this.sphere.cameraRotX)); // Não me pergunte, foi tentativa e erro kkk.
    float apontandoParaTelaOuNao = PVector.dot(this.centerDirection, screenDirection);
    if(apontandoParaTelaOuNao > cos(radians(10)) && this.sphere.cameraTransZ > 50){ 
      if (movie.available()) {
        this.movie.read();
      }
      this.movie.play();
      this.isFocus = true;
      this.indexVideo = (randomMovie+1);
      /*if(this.sphere.cameraTransZ > 200) this.movieSpeed = 2;
      else this.movieSpeed = 2*(this.sphere.cameraTransZ)/200;
      this.movie.speed(this.movieSpeed);*/
      
    } 
    else{
      this.movie.pause();
      this.isFocus = false;
      
    }
    pushMatrix();
    translate(this.centerPosition.x, this.centerPosition.y, this.centerPosition.z);
    noStroke();
    fill(255);
    beginShape();
    texture(this.movie);
    vertex(this.vertex1.x, this.vertex1.y, this.vertex1.z,                0,                 0);
    vertex(this.vertex2.x, this.vertex2.y, this.vertex2.z, this.movie.width,                 0);
    vertex(this.vertex3.x, this.vertex3.y, this.vertex3.z, this.movie.width, this.movie.height);
    vertex(this.vertex4.x, this.vertex4.y, this.vertex4.z,                0, this.movie.height);
    endShape(CLOSE);
    popMatrix();
  }
}
